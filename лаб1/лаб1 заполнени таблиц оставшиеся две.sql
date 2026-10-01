USE SAgency1_0;
GO

-- ============================================
-- 1. ГРАФИК ДЕЖУРСТВ (20500 записей)
-- ============================================
DECLARE @i INT = 1;
WHILE @i <= 20500
BEGIN
    INSERT INTO DutySchedule (ObjectID, EmployeeID, DutyDate, ShiftStartTime, ShiftEndTime, StatusID)
    VALUES (
        (@i % 550) + 1,   -- ObjectID: 1-550 (теперь точно существует!)
        (@i % 100) + 1,   -- EmployeeID: 1-100
        DATEADD(DAY, @i % 365, '2024-01-01'),
        '08:00:00',       -- Начало смены (всегда меньше конца)
        '20:00:00',       -- Конец смены (всегда больше начала)
        CASE @i % 4 
            WHEN 0 THEN 1  -- Запланирована
            WHEN 1 THEN 2  -- В работе
            WHEN 2 THEN 3  -- Завершена
            ELSE 4         -- Отменена
        END
    );
    SET @i = @i + 1;
END
GO

-- ============================================
-- 2. ТРЕВОЖНЫЕ ВЫЗОВЫ (20500 записей)
-- ============================================
DECLARE @i INT = 1;
WHILE @i <= 20500
BEGIN
    INSERT INTO AlarmCalls (CallDateTime, ObjectID, ReasonID, ResponseDurationMinutes, ResultID)
    VALUES (
        DATEADD(MINUTE, @i * 10, '2024-01-01 00:00:00'),
        (@i % 550) + 1,   -- ObjectID: 1-550
        (@i % 8) + 1,     -- ReasonID: 1-8
        (@i % 30) + 5,    -- ResponseDuration: 5-34 мин
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

-- ============================================
-- ПРОВЕРКА РЕЗУЛЬТАТА
-- ============================================
SELECT 'DutySchedule' AS Таблица, COUNT(*) AS Записей FROM DutySchedule
UNION ALL SELECT 'AlarmCalls', COUNT(*) FROM AlarmCalls;
GO