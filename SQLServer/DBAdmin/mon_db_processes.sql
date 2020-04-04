USE DB_ADMIN
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[mon_db_processes]') AND type in (N'P'))
BEGIN
	Print 'DROPPING PROCEDURE [mon_db_processes]'
	DROP PROCEDURE [mon_db_processes]
END
GO

CREATE PROCEDURE [dbo].[mon_db_processes] @dbname sysname, @myseconds int = null
AS
BEGIN

declare @timedelay char(8)
declare @mysecondsstring varchar(2)

--Default value to 10 seconds if null or > 99
if @myseconds is null
begin
	set @myseconds = 10
end

if len(@mysecondsstring) > 2
begin
	set @myseconds = 10
end

--Convert value to string and remove any spaces
set @mysecondsstring = rtrim(ltrim(str(@myseconds)))

--Set time delay value
select @timedelay = '00:00:' + case when len(@mysecondsstring) = 1 then '0' + @mysecondsstring else @mysecondsstring end

while (1 = 1)
begin

	SELECT ds.session_id, ds.login_name, ds.login_time, ds.last_request_start_time, ds.last_request_end_time, ds.total_scheduled_time, ds.total_elapsed_time, 
		ds.host_name, ds.program_name, ds.status, ds.cpu_time, ds.memory_usage, ds.reads, ds.writes, ds.logical_reads, db_name(ds.database_id), st.text, 
		do.blocking_session_id, do.wait_type, do.wait_duration_ms
	FROM sys.dm_exec_sessions ds
		INNER JOIN sys.dm_exec_connections dc ON ds.session_id = dc.session_id
		LEFT OUTER JOIN sys.dm_os_waiting_tasks do ON ds.session_id = do.session_id
		CROSS APPLY sys.dm_exec_sql_text(dc.most_recent_sql_handle) AS st
	WHERE db_name(ds.database_id) = @dbname

	WAITFOR DELAY @timedelay;
end

END

GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[mon_db_processes]') AND type in (N'P'))
BEGIN
	Print 'CREATED PROCEDURE [mon_db_processes]'
END
GO