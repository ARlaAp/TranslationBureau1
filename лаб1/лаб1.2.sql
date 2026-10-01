-- Создание базы данных
CREATE DATABASE SADB;
GO
USE SADB;
GO

--  Создание таблиц 
CREATE TABLE Clients (
    ClientID INT IDENTITY(1,1) PRIMARY KEY,
    ClientName NVARCHAR(200) NOT NULL,
    ContactPerson NVARCHAR(150),
    Phone NVARCHAR(20) NOT NULL,
    Email NVARCHAR(100),
    LegalAddress NVARCHAR(300),
    CONSTRAINT UQ_Clients_Phone UNIQUE (Phone)
);
GO

CREATE TABLE SecuredObjects (
    ObjectID INT IDENTITY(1,1) PRIMARY KEY,
    ObjectName NVARCHAR(200) NOT NULL,
    Address NVARCHAR(300) NOT NULL,
    ObjectType NVARCHAR(50) NOT NULL,
    RiskCategory INT NOT NULL CHECK (RiskCategory BETWEEN 1 AND 5),
    ClientID INT NOT NULL,
    CONSTRAINT FK_SecuredObjects_Clients FOREIGN KEY (ClientID) 
        REFERENCES Clients(ClientID) ON DELETE CASCADE
);
GO

CREATE TABLE Contracts (
    ContractID INT IDENTITY(1,1) PRIMARY KEY,
    ContractNumber NVARCHAR(50) NOT NULL UNIQUE,
    ClientID INT NOT NULL,
    ObjectID INT NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    MonthlyCost DECIMAL(10,2) NOT NULL CHECK (MonthlyCost > 0),
    Status NVARCHAR(30) NOT NULL DEFAULT 'Активен'
        CHECK (Status IN ('Активен', 'Завершен', 'Расторгнут', 'На подписании')),
    CONSTRAINT FK_Contracts_Clients FOREIGN KEY (ClientID) 
        REFERENCES Clients(ClientID) ON DELETE NO ACTION, 
    CONSTRAINT FK_Contracts_SecuredObjects FOREIGN KEY (ObjectID) 
        REFERENCES SecuredObjects(ObjectID) ON DELETE CASCADE,
    CONSTRAINT CHK_Dates CHECK (EndDate > StartDate)
);
GO

CREATE TABLE AlarmCalls (
    CallID INT IDENTITY(1,1) PRIMARY KEY,
    CallDateTime DATETIME NOT NULL DEFAULT GETDATE(),
    ObjectID INT NOT NULL,
    Reason NVARCHAR(200) NOT NULL,
    ResponseDurationMinutes INT,
    Result NVARCHAR(300),
    CONSTRAINT FK_AlarmCalls_SecuredObjects FOREIGN KEY (ObjectID) 
        REFERENCES SecuredObjects(ObjectID) ON DELETE CASCADE
);
GO

CREATE TABLE DutySchedule (
    ScheduleID INT IDENTITY(1,1) PRIMARY KEY,
    ObjectID INT NOT NULL,
    EmployeeID INT NOT NULL,
    DutyDate DATE NOT NULL,
    ShiftStartTime TIME NOT NULL,
    ShiftEndTime TIME NOT NULL,
    ShiftStatus NVARCHAR(20) NOT NULL DEFAULT 'Запланирована'
        CHECK (ShiftStatus IN ('Запланирована', 'В работе', 'Завершена', 'Отменена')),
    CONSTRAINT FK_DutySchedule_SecuredObjects FOREIGN KEY (ObjectID) 
        REFERENCES SecuredObjects(ObjectID) ON DELETE CASCADE,
    CONSTRAINT CHK_ShiftTime CHECK (ShiftEndTime > ShiftStartTime)
);
GO

-- Генерация тестовых данных
DECLARE @Counter INT = 1;
WHILE @Counter <= 550
BEGIN
    INSERT INTO Clients (ClientName, ContactPerson, Phone, Email, LegalAddress)
    VALUES (
        CASE WHEN @Counter % 3 = 0 THEN 'ООО Компания ' + CAST(@Counter AS NVARCHAR)
             WHEN @Counter % 3 = 1 THEN 'ИП Фамилия ' + CAST(@Counter AS NVARCHAR)
             ELSE 'АО Предприятие ' + CAST(@Counter AS NVARCHAR) END,
        'Контакт ' + CAST(@Counter AS NVARCHAR),
        '+7495' + RIGHT('0000000' + CAST(1000000 + @Counter AS NVARCHAR), 7),
        'c' + CAST(@Counter AS NVARCHAR) + '@test.ru',
        'г. Москва, ул. Тестовая, д. ' + CAST(@Counter AS NVARCHAR)
    );
    SET @Counter = @Counter + 1;
END
GO

DECLARE @Counter INT = 1;
WHILE @Counter <= 550
BEGIN
    INSERT INTO SecuredObjects (ObjectName, Address, ObjectType, RiskCategory, ClientID)
    VALUES (
        'Объект ' + CAST(@Counter AS NVARCHAR),
        'г. Москва, ул. Охраняемая, д. ' + CAST(@Counter AS NVARCHAR),
        CASE @Counter % 4 WHEN 0 THEN 'Склад' WHEN 1 THEN 'Офис' WHEN 2 THEN 'ТЦ' ELSE 'Жилой комплекс' END,
        (@Counter % 5) + 1,
        @Counter
    );
    SET @Counter = @Counter + 1;
END
GO

DECLARE @Counter INT = 1;
WHILE @Counter <= 20500
BEGIN
    INSERT INTO Contracts (ContractNumber, ClientID, ObjectID, StartDate, EndDate, MonthlyCost, Status)
    VALUES (
        'ДГ-' + RIGHT('00000' + CAST(@Counter AS NVARCHAR), 5) + '/2024',
        (@Counter % 550) + 1,
        (@Counter % 550) + 1,
        DATEADD(DAY, -(@Counter % 365), '2024-01-01'),
        DATEADD(DAY, 365 - (@Counter % 365), '2024-01-01'),
        15000.00 + (@Counter % 50) * 1000.00,
        CASE @Counter % 10 WHEN 0 THEN 'Завершен' WHEN 1 THEN 'Расторгнут' ELSE 'Активен' END
    );
    SET @Counter = @Counter + 1;
END
GO

-- Создание представлений
CREATE VIEW vw_ActiveContractsDetails AS
SELECT TOP 100 PERCENT
    c.ContractNumber, cl.ClientName, so.ObjectName, so.ObjectType, 
    c.StartDate, c.EndDate, c.MonthlyCost, c.Status
FROM Contracts c
INNER JOIN Clients cl ON c.ClientID = cl.ClientID
INNER JOIN SecuredObjects so ON c.ObjectID = so.ObjectID
WHERE c.Status = 'Активен'
ORDER BY c.EndDate ASC;
GO

CREATE VIEW vw_ObjectAlarmStatistics AS
SELECT 
    so.ObjectName, so.Address, so.RiskCategory,
    COUNT(ac.CallID) AS TotalCalls,
    AVG(CAST(ac.ResponseDurationMinutes AS DECIMAL(10,2))) AS AvgResponseTimeMin
FROM SecuredObjects so
LEFT JOIN AlarmCalls ac ON so.ObjectID = ac.ObjectID
GROUP BY so.ObjectName, so.Address, so.RiskCategory;
GO

CREATE VIEW vw_CurrentDutyMap AS
SELECT 
    ds.DutyDate, so.ObjectName, so.Address AS ObjectAddress, 
    ds.ShiftStartTime, ds.ShiftEndTime, ds.ShiftStatus
FROM DutySchedule ds
INNER JOIN SecuredObjects so ON ds.ObjectID = so.ObjectID
WHERE ds.DutyDate = CAST(GETDATE() AS DATE);
GO

-- Создание хранимых процедур
CREATE PROCEDURE sp_InsertContract
    @ContractNumber NVARCHAR(50), @ClientID INT, @ObjectID INT,
    @StartDate DATE, @EndDate DATE, @MonthlyCost DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @EndDate <= @StartDate
        BEGIN
            SELECT 'Ошибка: дата окончания позже даты начала' AS ResultMessage;
            RETURN;
        END
        INSERT INTO Contracts (ContractNumber, ClientID, ObjectID, StartDate, EndDate, MonthlyCost, Status)
        VALUES (@ContractNumber, @ClientID, @ObjectID, @StartDate, @EndDate, @MonthlyCost, 'Активен');
        SELECT 'Договор ' + @ContractNumber + ' создан' AS ResultMessage;
    END TRY
    BEGIN CATCH
        SELECT 'Ошибка: ' + ERROR_MESSAGE() AS ResultMessage;
    END CATCH
END
GO

CREATE PROCEDURE sp_UpdateContractStatus
    @ContractID INT, @NewStatus NVARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @NewStatus NOT IN ('Активен', 'Завершен', 'Расторгнут', 'На подписании')
        BEGIN
            SELECT 'Ошибка: недопустимый статус' AS ResultMessage;
            RETURN;
        END
        UPDATE Contracts SET Status = @NewStatus WHERE ContractID = @ContractID;
        IF @@ROWCOUNT > 0 SELECT 'Статус обновлен' AS ResultMessage;
        ELSE SELECT 'Ошибка: договор не найден' AS ResultMessage;
    END TRY
    BEGIN CATCH
        SELECT 'Ошибка: ' + ERROR_MESSAGE() AS ResultMessage;
    END CATCH
END
GO

CREATE PROCEDURE sp_RegisterAlarmCall
    @ObjectID INT, @Reason NVARCHAR(200), @ResponseDurationMinutes INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO AlarmCalls (CallDateTime, ObjectID, Reason, ResponseDurationMinutes, Result)
        VALUES (GETDATE(), @ObjectID, @Reason, @ResponseDurationMinutes, 'В обработке');
        SELECT 'Вызов зарегистрирован' AS ResultMessage;
    END TRY
    BEGIN CATCH
        SELECT 'Ошибка: ' + ERROR_MESSAGE() AS ResultMessage;
    END CATCH
END
GO