-- Тест 1: Представление 1
SELECT TOP 10 * FROM vw_ActiveContractsDetails;

-- Тест 2: Представление 2
SELECT TOP 10 * FROM vw_ObjectAlarmStatistics ORDER BY TotalCalls DESC;

-- Тест 3: Представление 3
SELECT TOP 10 * FROM vw_CurrentDutyMap;

-- Тест 4: Процедура 1
EXEC sp_InsertContract 'ДГ-TEST-001', 10, 10, '2024-06-01', '2025-06-01', 25000.00;

-- Тест 5: Процедура 2
EXEC sp_UpdateContractStatus 1, 'Завершен';

-- Тест 6: Процедура 3
EXEC sp_RegisterAlarmCall 5, 'Тестовый вызов', 15;