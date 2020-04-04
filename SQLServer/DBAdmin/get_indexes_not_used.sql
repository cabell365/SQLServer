USE DB_ADMIN
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[get_indexes_not_used]') AND type in (N'P'))
BEGIN
	Print 'DROPPING PROCEDURE [get_indexes_not_used]'
	DROP PROCEDURE [get_indexes_not_used]
END
GO

CREATE PROCEDURE [get_indexes_not_used] @DBNAME sysname
AS
--Declare SQL Command variables
DECLARE @SQLCMD varchar(500)

--Query identifies indexes that are probably not used.
SELECT @SQLCMD = 'SELECT ''Database''=db_name(UsageStats.database_id),' +
	'''Table''=object_name(UsageStats.object_id), ' +
	'''Index''=Indexes.Name ' +
	'FROM ' + @DBNAME + '.sys.dm_db_index_usage_stats UsageStats ' +
	'INNER JOIN sys.indexes Indexes ' + 
	'ON Indexes.index_id = UsageStats.index_id ' +
	' AND Indexes.object_id = UsageStats.object_id '

	--SELECT @SQLCMD
	EXEC (@SQLCMD)
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[get_indexes_not_used]') AND type in (N'P'))
BEGIN
	Print 'CREATED PROCEDURE [get_indexes_not_used]'
END
GO