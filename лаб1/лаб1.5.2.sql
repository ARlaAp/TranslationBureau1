USE db69279;
GO

-- Генерация клиентов 
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

-- Генерация объектов 
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

-- Генерация договоров 
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