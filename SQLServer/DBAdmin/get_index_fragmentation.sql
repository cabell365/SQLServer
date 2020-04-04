USE [DB_ADMIN]
GO

/****** Object:  StoredProcedure [dbo].[get_index_fragmentation]    Script Date: 10/7/2015 9:13:42 AM ******/
DROP PROCEDURE [dbo].[get_index_fragmentation]
GO

/****** Object:  StoredProcedure [dbo].[get_index_fragmentation]    Script Date: 10/7/2015 9:13:42 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[get_index_fragmentation] @DBNAME sysname, @SCRIPT int = 0
AS
--Declare db id and SQL Command variables
Declare @DBID int, @SQLCMD varchar(500)

--Get the database ID
select @DBID = DB_ID(@DBNAME)

IF @SCRIPT > 0
BEGIN
	CREATE TABLE #IDXTAB (TABNAME SYSNAME,INDEXNAME SYSNAME, INDEXTYPE SYSNAME, AVG_FRAG_IN_PCT DECIMAL)

	--Dynamically build the SQL to script index rebuild command for the database passed
	SELECT  @SQLCMD = 'INSERT #IDXTAB SELECT OBJECT_NAME(ind.OBJECT_ID,' + STR(@DBID,2,0) + ') AS TableName, ' +
		'ind.name AS IndexName, indexstats.index_type_desc AS IndexType, ' +
		'indexstats.avg_fragmentation_in_percent ' +
		'FROM sys.dm_db_index_physical_stats(' + STR(@DBID,2,0) + ', NULL, NULL, NULL, NULL) indexstats ' +
		'INNER JOIN ' + @DBNAME + '.sys.indexes ind  ' +
		'ON ind.object_id = indexstats.object_id ' +
		'AND ind.index_id = indexstats.index_id ' +
		'WHERE indexstats.avg_fragmentation_in_percent > 29 ' +
		'and ind.name is not null ' 

	--Execute command
	EXEC (@SQLCMD)

	--Generate command to rebuild index
	SELECT 'ALTER INDEX  ' + INDEXNAME + ' ON ' + @dbname + '.dbo.' + TABNAME + ' REBUILD;' + ' --AVG_FRAG_IN_PCT= ' + STR(CAST (AVG_FRAG_IN_PCT AS INT),3,0) + '%' 
	FROM #IDXTAB
	UNION
	SELECT  'ALTER INDEX  ' + INDEXNAME + ' ON ' + @dbname + '.dbo.' + TABNAME + ' REORGANIZE;' + ' --AVG_FRAG_IN_PCT= ' + STR(CAST (AVG_FRAG_IN_PCT AS INT),3,0) + '%'
	FROM #IDXTAB
	ORDER BY 1

	--Drop temp table
	DROP TABLE #IDXTAB
END
ELSE
BEGIN
	--Dynamically build the SQL for the database passed to display AVG_FRAG_IN_PCT for all tables
	SELECT  @SQLCMD = 'SELECT OBJECT_NAME(ind.OBJECT_ID,' + STR(@DBID,2,0) + ') AS TableName, ' +
		'ind.name AS IndexName, indexstats.index_type_desc AS IndexType, ' +
		'indexstats.avg_fragmentation_in_percent ' +
		'FROM sys.dm_db_index_physical_stats(' + STR(@DBID,2,0) + ', NULL, NULL, NULL, NULL) indexstats ' +
		'INNER JOIN ' + @DBNAME + '.sys.indexes ind  ' +
		'ON ind.object_id = indexstats.object_id ' +
		'AND ind.index_id = indexstats.index_id ' +
		'ORDER BY indexstats.avg_fragmentation_in_percent DESC; ' 

	--SELECT  @SQLCMD
	--Execute command
	EXEC (@SQLCMD)
END






GO


