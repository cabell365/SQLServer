USE DB_ADMIN
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[get_20_slowest_queries]') AND type in (N'P'))
BEGIN
	Print 'DROPPING PROCEDURE [get_index_fragmentation]'
	DROP PROCEDURE [get_20_slowest_queries]
END
GO


CREATE PROCEDURE [get_20_slowest_queries]
AS
BEGIN

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	SELECT TOP 20
		CAST(total_elapsed_time / 1000000.0 AS DECIMAL(28, 2))
		AS [Total Elapsed Duration (s)]
		, execution_count
		, SUBSTRING (qt.text,(qs.statement_start_offset/2) + 1,
		((CASE WHEN qs.statement_end_offset = -1
		THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2
	ELSE
		qs.statement_end_offset
	END - qs.statement_start_offset)/2) + 1) AS [Individual Query]
		, qt.text AS [Parent Query]
		, DB_NAME(qt.dbid) AS DatabaseName
		, qp.query_plan
	FROM sys.dm_exec_query_stats qs
	CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
	CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
	INNER JOIN sys.dm_exec_cached_plans as cp
	on qs.plan_handle=cp.plan_handle
	ORDER BY total_elapsed_time DESC 
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[get_20_slowest_queries]') AND type in (N'P'))
BEGIN
	Print 'CREATED PROCEDURE [get_20_slowest_queries]'
END
GO