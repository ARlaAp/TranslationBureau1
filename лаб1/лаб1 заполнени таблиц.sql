USE SAgencyDB;
GO

-- ============================================
-- ЭТАП 1. ЗАПОЛНЕНИЕ ВСЕХ СПРАВОЧНИКОВ
-- ============================================

-- 1. Типы клиентов
INSERT INTO ClientTypes (TypeName, Description) VALUES
('Физическое лицо', 'Частные клиенты'),
('Индивидуальный предприниматель', 'ИП'),
('Юридическое лицо', 'Организации и компании');
GO

-- 2. Типы охраняемых объектов
INSERT INTO ObjectTypes (TypeName, Description) VALUES
('Офис', 'Офисные помещения'), 
('Склад', 'Складские помещения'),
('Торговый центр', 'Торговые комплексы'), 
('Жилой комплекс', 'Жилые дома'),
('Производство', 'Производственные объекты'), 
('Банк', 'Банковские учреждения'),
('Школа', 'Образовательные учреждения'), 
('Больница', 'Медицинские учреждения');
GO

-- 3. Категории риска
INSERT INTO RiskCategories (CategoryLevel, CategoryName, Description, MinGuardsRequired) VALUES
(1, 'Минимальный', 'Минимальный риск', 1), 
(2, 'Низкий', 'Низкий риск', 1),
(3, 'Средний', 'Средний риск', 2), 
(4, 'Высокий', 'Высокий риск', 3),
(5, 'Особо высокий', 'Особо высокий риск', 4);
GO

-- 4. Статусы договоров
INSERT INTO ContractStatuses (StatusName, Description) VALUES
('Активен', 'Действующий'), 
('На подписании', 'Согласование'),
('Завершен', 'Истек срок'), 
('Расторгнут', 'Досрочно расторгнут'),
('Приостановлен', 'Приостановлен');
GO

-- 5. Статусы смен
INSERT INTO ShiftStatuses (StatusName, Description) VALUES
('Запланирована', 'Запланирована'), 
('В работе', 'В работе'),
('Завершена', 'Завершена'), 
('Отменена', 'Отменена'), 
('На замене', 'На замене');
GO

-- 6. Причины тревожных вызовов
INSERT INTO AlarmReasons (ReasonName, Description, IsEmergency) VALUES
('Ложное срабатывание', 'Ложная тревога', 0), 
('Проникновение', 'Несанкционированное проникновение', 1),
('Пожарная сигнализация', 'Пожар', 1), 
('Аварийная ситуация', 'Авария', 1),
('Техническая неисправность', 'Поломка оборудования', 0), 
('Проверка связи', 'Тест системы', 0),
('Помощь клиенту', 'Запрос помощи', 0), 
('Нарушение периметра', 'Нарушение периметра', 1);
GO

-- 7. Результаты вызовов
INSERT INTO CallResults (ResultName, Description) VALUES
('Нарушение устранено', 'Устранено'), 
('Ложный вызов', 'Ложный'),
('Требуется вмешательство', 'Вмешательство'), 
('Ситуация под контролем', 'Под контролем'),
('Передано в милицию', 'В милицию'), 
('В обработке', 'В обработке');
GO

-- 8. Разряды сотрудников (реалистичные названия для охранной сферы РБ)
INSERT INTO EmployeeRanks (RankNumber, RankName, Description, MinSalary) VALUES
(1, 'Охранник 1 разряда', 'Без права ношения оружия', 800), 
(2, 'Охранник 2 разряда', 'С правом ношения служебного оружия', 950),
(3, 'Охранник 3 разряда', 'С правом ношения гражданского оружия', 1100), 
(4, 'Старший охранник', 'Руководство группой охраны', 1400),
(5, 'Начальник смены', 'Управление сменой охраны', 1750), 
(6, 'Начальник охраны', 'Руководство отделом охраны', 2200);
GO

-- ============================================
-- ЭТАП 2. ТАБЛИЦЫ НА СТОРОНЕ "ОДИН" (>= 500 записей)
-- ============================================

-- 1. Клиенты (550 записей) - белорусские компании
DECLARE @i INT = 1;
DECLARE @city NVARCHAR(50);
DECLARE @street NVARCHAR(50);

WHILE @i <= 550
BEGIN
    -- Выбор города по номеру
    SET @city = CASE (@i % 10)
        WHEN 0 THEN 'г. Минск'
        WHEN 1 THEN 'г. Гомель'
        WHEN 2 THEN 'г. Могилев'
        WHEN 3 THEN 'г. Витебск'
        WHEN 4 THEN 'г. Гродно'
        WHEN 5 THEN 'г. Брест'
        WHEN 6 THEN 'г. Бобруйск'
        WHEN 7 THEN 'г. Барановичи'
        WHEN 8 THEN 'г. Борисов'
        ELSE 'г. Пинск'
    END;
    
    -- Выбор улицы
    SET @street = CASE (@i % 12)
        WHEN 0 THEN 'ул. Независимости'
        WHEN 1 THEN 'ул. Советская'
        WHEN 2 THEN 'ул. Ленина'
        WHEN 3 THEN 'ул. Кирова'
        WHEN 4 THEN 'ул. Гагарина'
        WHEN 5 THEN 'ул. Пушкина'
        WHEN 6 THEN 'ул. Октябрьская'
        WHEN 7 THEN 'ул. Интернациональная'
        WHEN 8 THEN 'ул. Карла Маркса'
        WHEN 9 THEN 'ул. Энгельса'
        WHEN 10 THEN 'пр. Независимости'
        ELSE 'ул. Первомайская'
    END;

    INSERT INTO Clients (TypeID, ClientName, ContactPerson, Phone, Email, LegalAddress)
    VALUES (
        (@i % 3) + 1,
        CASE WHEN @i % 3 = 0 THEN 'ООО "БелСервис ' + CAST(@i AS NVARCHAR) + '"'
             WHEN @i % 3 = 1 THEN 'ЧУП "МинскПром ' + CAST(@i AS NVARCHAR) + '"'
             ELSE 'ОАО "БелАгро ' + CAST(@i AS NVARCHAR) + '"' END,
        CASE (@i % 5)
            WHEN 0 THEN 'Директор Иванов А.В.'
            WHEN 1 THEN 'Директор Петров С.М.'
            WHEN 2 THEN 'Директор Сидоров И.П.'
            WHEN 3 THEN 'Директор Козлов Д.А.'
            ELSE 'Директор Новиков В.Н.'
        END,
        '+375' + 
            CASE (@i % 3)
                WHEN 0 THEN '29'  -- A1
                WHEN 1 THEN '33'  -- МТС
                ELSE '25'         -- life:)
            END + 
            RIGHT('0000000' + CAST(1000000 + @i AS NVARCHAR), 7),
        'client' + CAST(@i AS NVARCHAR) + '@belsecurity.by',
        @city + ', ' + @street + ', д. ' + CAST(@i AS NVARCHAR)
    );
    SET @i = @i + 1;
END
GO

-- 2. Охраняемые объекты (550 записей)
DECLARE @i INT = 1;
DECLARE @city NVARCHAR(50);
DECLARE @street NVARCHAR(50);

WHILE @i <= 550
BEGIN
    SET @city = CASE (@i % 10)
        WHEN 0 THEN 'г. Минск'
        WHEN 1 THEN 'г. Гомель'
        WHEN 2 THEN 'г. Могилев'
        WHEN 3 THEN 'г. Витебск'
        WHEN 4 THEN 'г. Гродно'
        WHEN 5 THEN 'г. Брест'
        WHEN 6 THEN 'г. Бобруйск'
        WHEN 7 THEN 'г. Барановичи'
        WHEN 8 THEN 'г. Борисов'
        ELSE 'г. Пинск'
    END;
    
    SET @street = CASE (@i % 12)
        WHEN 0 THEN 'ул. Независимости'
        WHEN 1 THEN 'ул. Советская'
        WHEN 2 THEN 'ул. Ленина'
        WHEN 3 THEN 'ул. Кирова'
        WHEN 4 THEN 'ул. Гагарина'
        WHEN 5 THEN 'ул. Пушкина'
        WHEN 6 THEN 'ул. Октябрьская'
        WHEN 7 THEN 'ул. Интернациональная'
        WHEN 8 THEN 'ул. Карла Маркса'
        WHEN 9 THEN 'ул. Энгельса'
        WHEN 10 THEN 'пр. Независимости'
        ELSE 'ул. Первомайская'
    END;

    INSERT INTO SecuredObjects (ObjectName, Address, TypeID, CategoryID, ClientID)
    VALUES (
        'Объект № ' + CAST(@i AS NVARCHAR),
        @city + ', ' + @street + ', д. ' + CAST(@i AS NVARCHAR),
        (@i % 8) + 1,
        (@i % 5) + 1,
        @i
    );
    SET @i = @i + 1;
END
GO

-- 3. Сотрудники охраны (100 записей) - белорусские имена
DECLARE @i INT = 1;
DECLARE @firstName NVARCHAR(50);
DECLARE @lastName NVARCHAR(50);
DECLARE @patronymic NVARCHAR(50);

WHILE @i <= 100
BEGIN
    -- Имя
    SET @firstName = CASE (@i % 15)
        WHEN 0 THEN 'Александр'
        WHEN 1 THEN 'Дмитрий'
        WHEN 2 THEN 'Сергей'
        WHEN 3 THEN 'Андрей'
        WHEN 4 THEN 'Максим'
        WHEN 5 THEN 'Иван'
        WHEN 6 THEN 'Михаил'
        WHEN 7 THEN 'Николай'
        WHEN 8 THEN 'Владимир'
        WHEN 9 THEN 'Павел'
        WHEN 10 THEN 'Евгений'
        WHEN 11 THEN 'Алексей'
        WHEN 12 THEN 'Виктор'
        WHEN 13 THEN 'Олег'
        ELSE 'Юрий'
    END;
    
    -- Фамилия
    SET @lastName = CASE (@i % 20)
        WHEN 0 THEN 'Иванов'
        WHEN 1 THEN 'Петров'
        WHEN 2 THEN 'Сидоров'
        WHEN 3 THEN 'Козлов'
        WHEN 4 THEN 'Новиков'
        WHEN 5 THEN 'Морозов'
        WHEN 6 THEN 'Волков'
        WHEN 7 THEN 'Соловьев'
        WHEN 8 THEN 'Васильев'
        WHEN 9 THEN 'Зайцев'
        WHEN 10 THEN 'Павлов'
        WHEN 11 THEN 'Семенов'
        WHEN 12 THEN 'Голубев'
        WHEN 13 THEN 'Виноградов'
        WHEN 14 THEN 'Богданов'
        WHEN 15 THEN 'Воробьев'
        WHEN 16 THEN 'Федоров'
        WHEN 17 THEN 'Михайлов'
        WHEN 18 THEN 'Беляев'
        ELSE 'Тарасов'
    END;
    
    -- Отчество
    SET @patronymic = CASE (@i % 10)
        WHEN 0 THEN 'Александрович'
        WHEN 1 THEN 'Дмитриевич'
        WHEN 2 THEN 'Сергеевич'
        WHEN 3 THEN 'Андреевич'
        WHEN 4 THEN 'Максимович'
        WHEN 5 THEN 'Иванович'
        WHEN 6 THEN 'Михайлович'
        WHEN 7 THEN 'Николаевич'
        WHEN 8 THEN 'Владимирович'
        ELSE 'Павлович'
    END;

    INSERT INTO SecurityEmployees (FullName, RankID, HasWeaponPermit, ContactPhone, HasMedicalClearance)
    VALUES (
        @lastName + ' ' + @firstName + ' ' + @patronymic,
        (@i % 6) + 1,  -- RankID: 1-6
        CASE WHEN @i % 3 = 0 THEN 1 ELSE 0 END,  -- Разрешение на оружие (для 2 и 3 разряда)
        '+375' + 
            CASE (@i % 3)
                WHEN 0 THEN '29'
                WHEN 1 THEN '33'
                ELSE '25'
            END + 
            RIGHT('0000000' + CAST(2000000 + @i AS NVARCHAR), 7),
        CASE WHEN @i % 10 = 0 THEN 0 ELSE 1 END  -- Меддопуск
    );
    SET @i = @i + 1;
END
GO

-- ============================================
-- ЭТАП 3. ТАБЛИЦЫ НА СТОРОНЕ "МНОГИЕ" (>= 20000 записей)
-- ============================================

-- 1. Договоры (20500 записей)
DECLARE @i INT = 1;
WHILE @i <= 20500
BEGIN
    INSERT INTO Contracts (ContractNumber, ClientID, ObjectID, StartDate, EndDate, MonthlyCost, StatusID)
    VALUES (
        'ДГ-' + RIGHT('00000' + CAST(@i AS NVARCHAR), 5) + '/2024',
        (@i % 550) + 1,
        (@i % 550) + 1,
        DATEADD(DAY, -(@i % 730), '2024-01-01'),
        DATEADD(DAY, 365 - (@i % 365), '2024-01-01'),
        400.00 + (@i % 50) * 50.00,  -- Стоимость в белорусских рублях (400-2850 BYN)
        CASE @i % 5 
            WHEN 0 THEN 3  -- Завершен
            WHEN 1 THEN 4  -- Расторгнут
            WHEN 2 THEN 2  -- На подписании
            ELSE 1         -- Активен
        END
    );
    SET @i = @i + 1;
END
GO

-- 2. График дежурств (20500 записей)
DECLARE @i INT = 1;
WHILE @i <= 20500
BEGIN
    INSERT INTO DutySchedule (ObjectID, EmployeeID, DutyDate, ShiftStartTime, ShiftEndTime, StatusID)
    VALUES (
        (@i % 550) + 1,  -- ObjectID: 1-550
        (@i % 100) + 1,  -- EmployeeID: 1-100
        DATEADD(DAY, @i % 365, '2024-01-01'),  -- Дата в течение года
        CASE @i % 3
            WHEN 0 THEN '08:00:00'
            WHEN 1 THEN '16:00:00'
            ELSE '00:00:00'
        END,
        CASE @i % 3
            WHEN 0 THEN '20:00:00'
            WHEN 1 THEN '08:00:00'
            ELSE '12:00:00'
        END,
        CASE @i % 5
            WHEN 0 THEN 3  -- Завершена
            WHEN 1 THEN 2  -- В работе
            WHEN 2 THEN 4  -- Отменена
            WHEN 3 THEN 5  -- На замене
            ELSE 1         -- Запланирована
        END
    );
    SET @i = @i + 1;
END
GO

-- 3. Тревожные вызовы (20500 записей)
DECLARE @i INT = 1;
WHILE @i <= 20500
BEGIN
    INSERT INTO AlarmCalls (CallDateTime, ObjectID, ReasonID, ResponseDurationMinutes, ResultID)
    VALUES (
        DATEADD(MINUTE, @i * 10, '2024-01-01 00:00:00'),
        (@i % 550) + 1,  -- ObjectID: 1-550
        (@i % 8) + 1,    -- ReasonID: 1-8
        (@i % 30) + 5,   -- ResponseDuration: 5-34 мин
        CASE @i % 6
            WHEN 0 THEN 1  -- Нарушение устранено
            WHEN 1 THEN 2  -- Ложный вызов
            WHEN 2 THEN 3  -- Требуется вмешательство
            WHEN 3 THEN 4  -- Ситуация под контролем
            WHEN 4 THEN 5  -- Передано в милицию
            ELSE 6         -- В обработке
        END
    );
    SET @i = @i + 1;
END
GO


SELECT 'ClientTypes' AS Таблица, COUNT(*) AS Количество FROM ClientTypes
UNION ALL
SELECT 'ObjectTypes', COUNT(*) FROM ObjectTypes
UNION ALL
SELECT 'RiskCategories', COUNT(*) FROM RiskCategories
UNION ALL
SELECT 'ContractStatuses', COUNT(*) FROM ContractStatuses
UNION ALL
SELECT 'ShiftStatuses', COUNT(*) FROM ShiftStatuses
UNION ALL
SELECT 'AlarmReasons', COUNT(*) FROM AlarmReasons
UNION ALL
SELECT 'CallResults', COUNT(*) FROM CallResults
UNION ALL
SELECT 'EmployeeRanks', COUNT(*) FROM EmployeeRanks
UNION ALL
SELECT 'Clients', COUNT(*) FROM Clients
UNION ALL
SELECT 'SecuredObjects', COUNT(*) FROM SecuredObjects
UNION ALL
SELECT 'SecurityEmployees', COUNT(*) FROM SecurityEmployees
UNION ALL
SELECT 'Contracts', COUNT(*) FROM Contracts
UNION ALL
SELECT 'DutySchedule', COUNT(*) FROM DutySchedule
UNION ALL
SELECT 'AlarmCalls', COUNT(*) FROM AlarmCalls;
GO