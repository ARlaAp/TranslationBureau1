USE SAgency1_0;
GO

-- ============================================
-- ПРЕДСТАВЛЕНИЕ 1: Активные договоры с полной информацией
-- ============================================
CREATE VIEW vw_ActiveContractsDetails AS
SELECT 
    c.ContractNumber,
    cl.ClientName,
    ct.TypeName AS ClientType,
    so.ObjectName,
    ot.TypeName AS ObjectType,
    rc.CategoryName AS RiskCategory,
    c.StartDate,
    c.EndDate,
    c.MonthlyCost,
    cs.StatusName
FROM Contracts c
INNER JOIN Clients cl ON c.ClientID = cl.ClientID
INNER JOIN ClientTypes ct ON cl.TypeID = ct.TypeID
INNER JOIN SecuredObjects so ON c.ObjectID = so.ObjectID
INNER JOIN ObjectTypes ot ON so.TypeID = ot.TypeID
INNER JOIN RiskCategories rc ON so.CategoryID = rc.CategoryID
INNER JOIN ContractStatuses cs ON c.StatusID = cs.StatusID
WHERE cs.StatusName = N'Активен';
GO

-- ============================================
-- ПРЕДСТАВЛЕНИЕ 2: Статистика тревожных вызовов по объектам
-- ============================================
CREATE VIEW vw_ObjectAlarmStatistics AS
SELECT 
    so.ObjectName,
    so.Address,
    ot.TypeName AS ObjectType,
    rc.CategoryName AS RiskCategory,
    COUNT(ac.CallID) AS TotalCalls,
    AVG(CAST(ac.ResponseDurationMinutes AS DECIMAL(10,2))) AS AvgResponseTimeMin,
    SUM(CASE WHEN ar.IsEmergency = 1 THEN 1 ELSE 0 END) AS EmergencyCalls
FROM SecuredObjects so
INNER JOIN ObjectTypes ot ON so.TypeID = ot.TypeID
INNER JOIN RiskCategories rc ON so.CategoryID = rc.CategoryID
LEFT JOIN AlarmCalls ac ON so.ObjectID = ac.ObjectID
LEFT JOIN AlarmReasons ar ON ac.ReasonID = ar.ReasonID
GROUP BY so.ObjectName, so.Address, ot.TypeName, rc.CategoryName;
GO

-- ============================================
-- ПРЕДСТАВЛЕНИЕ 3: Сводка по клиентам и их договорам
-- ============================================
CREATE VIEW vw_ClientContractsSummary AS
SELECT 
    cl.ClientName,
    ct.TypeName AS ClientType,
    COUNT(c.ContractID) AS TotalContracts,
    SUM(CASE WHEN cs.StatusName = N'Активен' THEN 1 ELSE 0 END) AS ActiveContracts,
    SUM(CASE WHEN cs.StatusName = N'Активен' THEN c.MonthlyCost ELSE 0 END) AS TotalMonthlyRevenue
FROM Clients cl
INNER JOIN ClientTypes ct ON cl.TypeID = ct.TypeID
LEFT JOIN Contracts c ON cl.ClientID = c.ClientID
LEFT JOIN ContractStatuses cs ON c.StatusID = cs.StatusID
GROUP BY cl.ClientName, ct.TypeName;
GO

-- ============================================
-- ПРЕДСТАВЛЕНИЕ 4: Обзор графика дежурств
-- ============================================
CREATE VIEW vw_DutyScheduleOverview AS
SELECT 
    ds.DutyDate,
    se.FullName AS EmployeeName,
    er.RankName,
    so.ObjectName,
    so.Address AS ObjectAddress,
    ds.ShiftStartTime,
    ds.ShiftEndTime,
    ss.StatusName AS ShiftStatus
FROM DutySchedule ds
INNER JOIN SecurityEmployees se ON ds.EmployeeID = se.EmployeeID
INNER JOIN EmployeeRanks er ON se.RankID = er.RankID
INNER JOIN SecuredObjects so ON ds.ObjectID = so.ObjectID
INNER JOIN ShiftStatuses ss ON ds.StatusID = ss.StatusID;
GO

-- ============================================
-- ПРОВЕРКА: тестируем каждое представление
-- ============================================

-- Тест 1: Активные договоры (первые 10)
SELECT TOP 10 * FROM vw_ActiveContractsDetails;
GO

-- Тест 2: Статистика вызовов (первые 10 объектов по количеству вызовов)
SELECT TOP 10 * FROM vw_ObjectAlarmStatistics ORDER BY TotalCalls DESC;
GO

-- Тест 3: Сводка по клиентам (первые 10 по выручке)
SELECT TOP 10 * FROM vw_ClientContractsSummary ORDER BY TotalMonthlyRevenue DESC;
GO

-- Тест 4: График дежурств (первые 10 записей)
SELECT TOP 10 * FROM vw_DutyScheduleOverview;
GO