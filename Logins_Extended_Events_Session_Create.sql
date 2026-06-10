DROP EVENT SESSION [Logins] ON SERVER 
GO
CREATE EVENT SESSION [Logins] ON SERVER
ADD EVENT sqlserver.login(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.username)
    WHERE ([is_cached]=(0) AND [sqlserver].[username] <> 'sa'))
ADD TARGET package0.event_file(SET filename=N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Log\Logins.xel',max_file_size=(1))
WITH (MAX_MEMORY=512 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=ON)
GO
ALTER EVENT SESSION [Logins] ON SERVER STATE = START
GO