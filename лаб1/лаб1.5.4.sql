USE db69279;
GO

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