USE db69279;
GO

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