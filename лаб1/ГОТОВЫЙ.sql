USE SAgency1_0;
GO

-- === ЗАПОЛНЕНИЕ СПРАВОЧНИКОВ ===
INSERT INTO ClientTypes (TypeName, Description) VALUES
(N'Физическое лицо', N'Частные клиенты'),
(N'Индивидуальный предприниматель', N'ИП'),
(N'Юридическое лицо', N'Организации');

INSERT INTO ObjectTypes (TypeName, Description) VALUES
(N'Офис', N'Офисные помещения'),
(N'Склад', N'Складские помещения'),
(N'Торговый центр', N'Торговые комплексы'),
(N'Жилой комплекс', N'Жилые дома'),
(N'Производство', N'Заводы'),
(N'Банк', N'Банковские учреждения'),
(N'Школа', N'Образовательные учреждения'),
(N'Больница', N'Медицинские учреждения');

INSERT INTO RiskCategories (CategoryLevel, CategoryName, Description, MinGuardsRequired) VALUES
(1, N'Минимальный', N'Минимальный риск', 1),
(2, N'Низкий', N'Низкий риск', 1),
(3, N'Средний', N'Средний риск', 2),
(4, N'Высокий', N'Высокий риск', 3),
(5, N'Особо высокий', N'Особо высокий риск', 4);

INSERT INTO ContractStatuses (StatusName, Description) VALUES
(N'Активен', N'Действующий'),
(N'На подписании', N'Согласование'),
(N'Завершен', N'Истек срок'),
(N'Расторгнут', N'Расторгнут'),
(N'Приостановлен', N'Приостановлен');

INSERT INTO ShiftStatuses (StatusName, Description) VALUES
(N'Запланирована', N'Запланирована'),
(N'В работе', N'В работе'),
(N'Завершена', N'Завершена'),
(N'Отменена', N'Отменена'),
(N'На замене', N'На замене');

INSERT INTO AlarmReasons (ReasonName, Description, IsEmergency) VALUES
(N'Ложное срабатывание', N'Ложная тревога', 0),
(N'Проникновение', N'Проникновение', 1),
(N'Пожарная сигнализация', N'Пожар', 1),
(N'Аварийная ситуация', N'Авария', 1),
(N'Техническая неисправность', N'Поломка', 0),
(N'Проверка связи', N'Тест', 0),
(N'Помощь клиенту', N'Помощь', 0),
(N'Нарушение периметра', N'Периметр', 1);

INSERT INTO CallResults (ResultName, Description) VALUES
(N'Нарушение устранено', N'Устранено'),
(N'Ложный вызов', N'Ложный'),
(N'Требуется вмешательство', N'Вмешательство'),
(N'Ситуация под контролем', N'Под контролем'),
(N'Передано в милицию', N'В милицию'),
(N'В обработке', N'В обработке');

INSERT INTO EmployeeRanks (RankNumber, RankName, Description, MinSalary) VALUES
(1, N'Охранник 1 разряда', N'Без оружия', 800),
(2, N'Охранник 2 разряда', N'Служебное оружие', 950),
(3, N'Охранник 3 разряда', N'Гражданское оружие', 1100),
(4, N'Старший охранник', N'Руководство группой', 1400),
(5, N'Начальник смены', N'Управление сменой', 1750),
(6, N'Начальник охраны', N'Руководство отделом', 2200);
GO

-- === ГЕНЕРАЦИЯ ДАННЫХ: КЛИЕНТЫ (550 записей) ===
DECLARE @i INT = 1;
WHILE @i <= 550
BEGIN
    INSERT INTO Clients (TypeID, ClientName, ContactPerson, Phone, Email, LegalAddress)
    VALUES (
        (@i % 3) + 1,
        CASE WHEN @i % 3 = 0 THEN N'ООО "БелСервис ' + CAST(@i AS NVARCHAR) + N'"'
             WHEN @i % 3 = 1 THEN N'ЧУП "МинскПром ' + CAST(@i AS NVARCHAR) + N'"'
             ELSE N'ОАО "БелАгро ' + CAST(@i AS NVARCHAR) + N'"' END,
        N'Директор',
        N'+37529' + RIGHT(N'0000000' + CAST(1000000 + @i AS NVARCHAR), 7),
        N'client' + CAST(@i AS NVARCHAR) + N'@belsecurity.by',
        N'г. Минск, ул. Тестовая, д. ' + CAST(@i AS NVARCHAR)
    );
    SET @i = @i + 1;
END
GO

-- === ГЕНЕРАЦИЯ ДАННЫХ: ОХРАНЯЕМЫЕ ОБЪЕКТЫ (550 записей) ===
DECLARE @i INT = 1;
WHILE @i <= 550
BEGIN
    INSERT INTO SecuredObjects (ObjectName, Address, TypeID, CategoryID, ClientID)
    VALUES (
        N'Объект № ' + CAST(@i AS NVARCHAR),
        N'г. Минск, ул. Охраняемая, д. ' + CAST(@i AS NVARCHAR),
        (@i % 8) + 1,
        (@i % 5) + 1,
        @i
    );
    SET @i = @i + 1;
END
GO

-- === ГЕНЕРАЦИЯ ДАННЫХ: СОТРУДНИКИ (100 записей) ===
DECLARE @i INT = 1;
WHILE @i <= 100
BEGIN
    INSERT INTO SecurityEmployees (FullName, RankID, HasWeaponPermit, ContactPhone, HasMedicalClearance)
    VALUES (
        N'Сотрудник ' + CAST(@i AS NVARCHAR),
        (@i % 6) + 1,
        0,
        N'+37533' + RIGHT(N'0000000' + CAST(2000000 + @i AS NVARCHAR), 7),
        1
    );
    SET @i = @i + 1;
END
GO

-- === ГЕНЕРАЦИЯ ДАННЫХ: ДОГОВОРЫ (20500 записей) ===
DECLARE @i INT = 1;
WHILE @i <= 20500
BEGIN
    INSERT INTO Contracts (ContractNumber, ClientID, ObjectID, StartDate, EndDate, MonthlyCost, StatusID)
    VALUES (
        N'ДГ-' + RIGHT(N'00000' + CAST(@i AS NVARCHAR), 5) + N'/2024',
        (@i % 550) + 1,
        (@i % 550) + 1,
        DATEADD(DAY, -(@i % 730), '2024-01-01'),
        DATEADD(DAY, 365 - (@i % 365), '2024-01-01'),
        400.00 + (@i % 50) * 50.00,
        CASE @i % 5 WHEN 0 THEN 3 WHEN 1 THEN 4 WHEN 2 THEN 2 ELSE 1 END
    );
    SET @i = @i + 1;
END
GO

-- === ГЕНЕРАЦИЯ ДАННЫХ: ГРАФИК ДЕЖУРСТВ (20500 записей) ===
DECLARE @i INT = 1;
WHILE @i <= 20500
BEGIN
    INSERT INTO DutySchedule (ObjectID, EmployeeID, DutyDate, ShiftStartTime, ShiftEndTime, StatusID)
    VALUES (
        (@i % 550) + 1,
        (@i % 100) + 1,
        DATEADD(DAY, @i % 365, '2024-01-01'),
        '08:00:00',
        '20:00:00',
        CASE @i % 4 WHEN 0 THEN 1 WHEN 1 THEN 2 WHEN 2 THEN 3 ELSE 4 END
    );
    SET @i = @i + 1;
END
GO

-- === ГЕНЕРАЦИЯ ДАННЫХ: ТРЕВОЖНЫЕ ВЫЗОВЫ (20500 записей) ===
DECLARE @i INT = 1;
WHILE @i <= 20500
BEGIN
    INSERT INTO AlarmCalls (CallDateTime, ObjectID, ReasonID, ResponseDurationMinutes, ResultID)
    VALUES (
        DATEADD(MINUTE, @i * 10, '2024-01-01 00:00:00'),
        (@i % 550) + 1,
        (@i % 8) + 1,
        (@i % 30) + 5,
        CASE @i % 6 WHEN 0 THEN 1 WHEN 1 THEN 2 WHEN 2 THEN 3 WHEN 3 THEN 4 WHEN 4 THEN 5 ELSE 6 END
    );
    SET @i = @i + 1;
END
GO

-- === ПРОВЕРКА КОЛИЧЕСТВА ЗАПИСЕЙ ===
SELECT 'Clients' AS Таблица, COUNT(*) AS Записей FROM Clients
UNION ALL SELECT 'SecuredObjects', COUNT(*) FROM SecuredObjects
UNION ALL SELECT 'SecurityEmployees', COUNT(*) FROM SecurityEmployees
UNION ALL SELECT 'Contracts', COUNT(*) FROM Contracts
UNION ALL SELECT 'DutySchedule', COUNT(*) FROM DutySchedule
UNION ALL SELECT 'AlarmCalls', COUNT(*) FROM AlarmCalls;
GO