SELECT DATEADD(MI, DATEDIFF(MI, GETUTCDATE(), GETDATE()), timestamp_utc) [DateTime], CAST(event_data AS XML) [EventData]
FROM sys.fn_xe_file_target_read_file('C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Log\Logins*.xel', NULL, NULL, NULL)
WHERE CAST(timestamp_utc AS DATETIME) >= DATEADD(MI, -15, GETUTCDATE())

CREATE TABLE #Events (
  [DateTime] DATETIME, [username] VARCHAR(255), [database_name] VARCHAR(255), [client_hostname] VARCHAR(255), [client_app_name] VARCHAR(255))
;WITH TraceFile AS (
SELECT DATEADD(MI, DATEDIFF(MI, GETUTCDATE(), GETDATE()), timestamp_utc) [DateTime], CAST(event_data AS XML) [EventData]
  FROM sys.fn_xe_file_target_read_file('C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Log\Logins*.xel', NULL, NULL, NULL)
 WHERE CAST(timestamp_utc AS DATETIME) >= DATEADD(MI, -15, GETUTCDATE()))
INSERT INTO #Events
SELECT DateTime,
       EventData.value('(/event/action[@name="username"]/value)[1]','VARCHAR(255)') username,
       EventData.value('(/event/action[@name="database_name"]/value)[1]','VARCHAR(255)') database_name,
       EventData.value('(/event/action[@name="client_hostname"]/value)[1]','VARCHAR(255)') client_hostname,
       EventData.value('(/event/action[@name="client_app_name"]/value)[1]','VARCHAR(255)') client_app_name
  FROM TraceFile
SELECT MIN(s.DateTime) DateTime, 'Login succeeded for user '''+s.username+'''. '''+s.client_hostname+''' APP: '+s.client_app_name [Message]
  FROM #Events s
  LEFT JOIN MyLogonExclusion e ON e.OriginalLogin=s.username AND e.HostName=s.client_hostname AND s.client_app_name LIKE e.ProgramName
 WHERE e.OriginalLogin IS NULL
 GROUP BY s.username, s.client_hostname, s.client_app_name
 ORDER BY 1
DROP TABLE #Events

--DROP TABLE MyLogonExclusion
--CREATE TABLE MyLogonExclusion (OriginalLogin VARCHAR(255), HostName VARCHAR(255), ProgramName VARCHAR(255))
