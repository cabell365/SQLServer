USE DB_ADMIN
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[get_query_plan_by_db]') AND type in (N'P'))
BEGIN
	Print 'DROPPING PROCEDURE [get_query_plan_by_db]'
	DROP PROCEDURE [get_query_plan_by_db]
END
GO

CREATE PROCEDURE [get_query_plan_by_db] @DBNAME sysname, @MYDATE DATE = NULL
AS
BEGIN
	
	IF @MYDATE IS NULL
	BEGIN
		SET @MYDATE = GETDATE()
	END

	--Get Query plan and SQL executed in a specific database on a specific day
	SELECT last_execution_time, DB_NAME(st.dbid), OBJECT_NAME(st.objectid,st.dbid),query_plan, st.text 
	FROM sys.dm_exec_query_stats AS qs
		CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle)
		CROSS APPLY sys.dm_exec_sql_text(qs.plan_handle) AS st
	WHERE CONVERT(CHAR(10),last_execution_time,101) = @MYDATE
		AND  DB_NAME(st.dbid) = @DBNAME
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[get_query_plan_by_db]') AND type in (N'P'))
BEGIN
	Print 'CREATED PROCEDURE [get_query_plan_by_db]'
END
GO