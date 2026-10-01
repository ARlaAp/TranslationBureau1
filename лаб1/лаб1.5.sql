-- Создание таблиц на удаленном сервере
USE db69279;
GO

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