USE DB_ADMIN
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[get_index_usage]') AND type in (N'P'))
BEGIN
	Print 'DROPPING PROCEDURE [get_index_fragmentation]'
	DROP PROCEDURE [get_index_usage]
END
GO


CREATE PROCEDURE [get_index_usage] @DBNAME sysname
AS
--Declare db id and SQL Command variables
Declare @DBID int, @SQLCMD varchar(500)

--Get the database ID
select @DBID = DB_ID(@DBNAME)

--Query displays index usage.
	SELECT @SQLCMD = 'SELECT ''Database''=db_name(UsageStats.database_id), ' +
		'''Table''=object_name(UsageStats.object_id, ' + str(@DBID,3,0) + '), ' +
		'''Index''=Indexes.Name,	user_seeks,	user_scans,	user_lookups, user_updates ' +
		'FROM ' + @DBNAME + '.sys.dm_db_index_usage_stats UsageStats ' +
		'INNER JOIN ' + @DBNAME + '.sys.indexes Indexes ' +
		'ON Indexes.index_id = UsageStats.index_id ' +
		'AND Indexes.object_id = UsageStats.object_id ' +
		'AND db_name(UsageStats.database_id) = ' + '''' + @DBNAME + ''''

	--SELECT @SQLCMD
	EXEC (@SQLCMD)
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[get_index_usage]') AND type in (N'P'))
BEGIN
	Print 'CREATED PROCEDURE [get_index_usage]'
END
GO