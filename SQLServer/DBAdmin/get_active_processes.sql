USE DB_ADMIN
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[get_active_processes]') AND type in (N'P'))
BEGIN
	Print 'DROPPING PROCEDURE [get_active_processes]'
	DROP PROCEDURE [get_active_processes]
END
GO

CREATE PROCEDURE [get_active_processes]
AS
BEGIN
	SELECT ds.session_id, ds.login_name, ds.login_time, ds.last_request_start_time, ds.last_request_end_time, ds.total_scheduled_time, ds.total_elapsed_time, 
		ds.host_name, ds.program_name, ds.status, ds.cpu_time, ds.memory_usage, ds.reads, ds.writes, ds.logical_reads, db_name(ds.database_id), st.text
	FROM sys.dm_exec_sessions ds
		INNER JOIN sys.dm_exec_connections dc ON ds.session_id = dc.session_id
		CROSS APPLY sys.dm_exec_sql_text(dc.most_recent_sql_handle) AS st
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[get_active_processes]') AND type in (N'P'))
BEGIN
	Print 'CREATED PROCEDURE [get_active_processes]'
END
GO
