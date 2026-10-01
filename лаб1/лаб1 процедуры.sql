USE SAgency1_0;
GO

-- ============================================
-- ПРОЦЕДУРА 1: Создание нового договора
-- ============================================
CREATE PROCEDURE sp_InsertContract
    @ContractNumber NVARCHAR(50),
    @ClientID INT,
    @ObjectID INT,
    @StartDate DATE,
    @EndDate DATE,
    @MonthlyCost DECIMAL(10,2),
    @StatusID INT = 1
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Проверка дат
        IF @EndDate <= @StartDate
        BEGIN
            SELECT N'Ошибка: дата окончания должна быть позже даты начала' AS ResultMessage;
            RETURN;
        END
        
        -- Проверка существования клиента
        IF NOT EXISTS (SELECT 1 FROM Clients WHERE ClientID = @ClientID)
        BEGIN
            SELECT N'Ошибка: клиент с ID=' + CAST(@ClientID AS NVARCHAR) + N' не найден' AS ResultMessage;
            RETURN;
        END
        
        -- Проверка существования объекта
        IF NOT EXISTS (SELECT 1 FROM SecuredObjects WHERE ObjectID = @ObjectID)
        BEGIN
            SELECT N'Ошибка: объект с ID=' + CAST(@ObjectID AS NVARCHAR) + N' не найден' AS ResultMessage;
            RETURN;
        END
        
        -- Проверка уникальности номера договора
        IF EXISTS (SELECT 1 FROM Contracts WHERE ContractNumber = @ContractNumber)
        BEGIN
            SELECT N'Ошибка: договор с номером ' + @ContractNumber + N' уже существует' AS ResultMessage;
            RETURN;
        END
        
        -- Вставка договора
        INSERT INTO Contracts (ContractNumber, ClientID, ObjectID, StartDate, EndDate, MonthlyCost, StatusID)
        VALUES (@ContractNumber, @ClientID, @ObjectID, @StartDate, @EndDate, @MonthlyCost, @StatusID);
        
        SELECT N'Договор ' + @ContractNumber + N' успешно создан' AS ResultMessage;
    END TRY
    BEGIN CATCH
        SELECT N'Ошибка: ' + ERROR_MESSAGE() AS ResultMessage;
    END CATCH
END
GO

-- ============================================
-- ПРОЦЕДУРА 2: Обновление статуса договора
-- ============================================
CREATE PROCEDURE sp_UpdateContractStatus
    @ContractID INT,
    @NewStatusID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Проверка существования статуса
        IF NOT EXISTS (SELECT 1 FROM ContractStatuses WHERE StatusID = @NewStatusID)
        BEGIN
            SELECT N'Ошибка: статус с ID=' + CAST(@NewStatusID AS NVARCHAR) + N' не найден' AS ResultMessage;
            RETURN;
        END
        
        -- Проверка существования договора
        IF NOT EXISTS (SELECT 1 FROM Contracts WHERE ContractID = @ContractID)
        BEGIN
            SELECT N'Ошибка: договор с ID=' + CAST(@ContractID AS NVARCHAR) + N' не найден' AS ResultMessage;
            RETURN;
        END
        
        -- Обновление статуса
        UPDATE Contracts 
        SET StatusID = @NewStatusID 
        WHERE ContractID = @ContractID;
        
        IF @@ROWCOUNT > 0
            SELECT N'Статус договора ID=' + CAST(@ContractID AS NVARCHAR) + N' успешно обновлен' AS ResultMessage;
        ELSE
            SELECT N'Ошибка: не удалось обновить статус' AS ResultMessage;
    END TRY
    BEGIN CATCH
        SELECT N'Ошибка: ' + ERROR_MESSAGE() AS ResultMessage;
    END CATCH
END
GO

-- ============================================
-- ПРОЦЕДУРА 3: Регистрация тревожного вызова
-- ============================================
CREATE PROCEDURE sp_RegisterAlarmCall
    @ObjectID INT,
    @ReasonID INT,
    @ResponseDurationMinutes INT = NULL,
    @ResultID INT = 6
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Проверка существования объекта
        IF NOT EXISTS (SELECT 1 FROM SecuredObjects WHERE ObjectID = @ObjectID)
        BEGIN
            SELECT N'Ошибка: объект с ID=' + CAST(@ObjectID AS NVARCHAR) + N' не найден' AS ResultMessage;
            RETURN;
        END
        
        -- Проверка существования причины
        IF NOT EXISTS (SELECT 1 FROM AlarmReasons WHERE ReasonID = @ReasonID)
        BEGIN
            SELECT N'Ошибка: причина с ID=' + CAST(@ReasonID AS NVARCHAR) + N' не найдена' AS ResultMessage;
            RETURN;
        END
        
        -- Проверка существования результата
        IF NOT EXISTS (SELECT 1 FROM CallResults WHERE ResultID = @ResultID)
        BEGIN
            SELECT N'Ошибка: результат с ID=' + CAST(@ResultID AS NVARCHAR) + N' не найден' AS ResultMessage;
            RETURN;
        END
        
        -- Вставка вызова (время автоматически устанавливается GETDATE())
        INSERT INTO AlarmCalls (CallDateTime, ObjectID, ReasonID, ResponseDurationMinutes, ResultID)
        VALUES (GETDATE(), @ObjectID, @ReasonID, @ResponseDurationMinutes, @ResultID);
        
        SELECT N'Тревожный вызов для объекта ID=' + CAST(@ObjectID AS NVARCHAR) + N' успешно зарегистрирован' AS ResultMessage;
    END TRY
    BEGIN CATCH
        SELECT N'Ошибка: ' + ERROR_MESSAGE() AS ResultMessage;
    END CATCH
END
GO

-- ============================================
-- ПРОЦЕДУРА 4: Назначение дежурства сотруднику
-- ============================================
CREATE PROCEDURE sp_AssignDuty
    @ObjectID INT,
    @EmployeeID INT,
    @DutyDate DATE,
    @ShiftStartTime TIME,
    @ShiftEndTime TIME,
    @StatusID INT = 1
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Проверка времени смены
        IF @ShiftEndTime <= @ShiftStartTime
        BEGIN
            SELECT N'Ошибка: время окончания смены должно быть позже времени начала' AS ResultMessage;
            RETURN;
        END
        
        -- Проверка существования объекта
        IF NOT EXISTS (SELECT 1 FROM SecuredObjects WHERE ObjectID = @ObjectID)
        BEGIN
            SELECT N'Ошибка: объект с ID=' + CAST(@ObjectID AS NVARCHAR) + N' не найден' AS ResultMessage;
            RETURN;
        END
        
        -- Проверка существования сотрудника
        IF NOT EXISTS (SELECT 1 FROM SecurityEmployees WHERE EmployeeID = @EmployeeID)
        BEGIN
            SELECT N'Ошибка: сотрудник с ID=' + CAST(@EmployeeID AS NVARCHAR) + N' не найден' AS ResultMessage;
            RETURN;
        END
        
        -- Проверка существования статуса
        IF NOT EXISTS (SELECT 1 FROM ShiftStatuses WHERE StatusID = @StatusID)
        BEGIN
            SELECT N'Ошибка: статус с ID=' + CAST(@StatusID AS NVARCHAR) + N' не найден' AS ResultMessage;
            RETURN;
        END
        
        -- Проверка пересечения смен (сотрудник не может работать в двух местах одновременно)
        IF EXISTS (
            SELECT 1 FROM DutySchedule 
            WHERE EmployeeID = @EmployeeID 
              AND DutyDate = @DutyDate
              AND (
                  (@ShiftStartTime < ShiftEndTime AND @ShiftEndTime > ShiftStartTime)
              )
        )
        BEGIN
            SELECT N'Ошибка: у сотрудника уже есть дежурство в это время' AS ResultMessage;
            RETURN;
        END
        
        -- Вставка дежурства
        INSERT INTO DutySchedule (ObjectID, EmployeeID, DutyDate, ShiftStartTime, ShiftEndTime, StatusID)
        VALUES (@ObjectID, @EmployeeID, @DutyDate, @ShiftStartTime, @ShiftEndTime, @StatusID);
        
        SELECT N'Дежурство для сотрудника ID=' + CAST(@EmployeeID AS NVARCHAR) + N' на ' + CAST(@DutyDate AS NVARCHAR) + N' успешно назначено' AS ResultMessage;
    END TRY
    BEGIN CATCH
        SELECT N'Ошибка: ' + ERROR_MESSAGE() AS ResultMessage;
    END CATCH
END
GO

-- ============================================
-- ПРОЦЕДУРА 5: Получение статистики по клиенту
-- ============================================
CREATE PROCEDURE sp_GetClientStatistics
    @ClientID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Проверка существования клиента
        IF NOT EXISTS (SELECT 1 FROM Clients WHERE ClientID = @ClientID)
        BEGIN
            SELECT N'Ошибка: клиент с ID=' + CAST(@ClientID AS NVARCHAR) + N' не найден' AS ResultMessage;
            RETURN;
        END
        
        -- Возврат статистики
        SELECT 
            cl.ClientID,
            cl.ClientName,
            ct.TypeName AS ClientType,
            COUNT(DISTINCT c.ContractID) AS TotalContracts,
            SUM(CASE WHEN cs.StatusName = N'Активен' THEN 1 ELSE 0 END) AS ActiveContracts,
            SUM(CASE WHEN cs.StatusName = N'Активен' THEN c.MonthlyCost ELSE 0 END) AS TotalMonthlyRevenue,
            COUNT(DISTINCT ac.CallID) AS TotalAlarmCalls,
            AVG(CAST(ac.ResponseDurationMinutes AS DECIMAL(10,2))) AS AvgResponseTimeMin
        FROM Clients cl
        INNER JOIN ClientTypes ct ON cl.TypeID = ct.TypeID
        LEFT JOIN Contracts c ON cl.ClientID = c.ClientID
        LEFT JOIN ContractStatuses cs ON c.StatusID = cs.StatusID
        LEFT JOIN SecuredObjects so ON cl.ClientID = so.ClientID
        LEFT JOIN AlarmCalls ac ON so.ObjectID = ac.ObjectID
        WHERE cl.ClientID = @ClientID
        GROUP BY cl.ClientID, cl.ClientName, ct.TypeName;
    END TRY
    BEGIN CATCH
        SELECT N'Ошибка: ' + ERROR_MESSAGE() AS ResultMessage;
    END CATCH
END
GO