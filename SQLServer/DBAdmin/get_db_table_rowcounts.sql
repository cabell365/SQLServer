USE DB_ADMIN
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[get_db_table_rowcounts]') AND type in (N'P'))
BEGIN
	Print 'DROPPING PROCEDURE [get_index_fragmentation]'
	DROP PROCEDURE [get_db_table_rowcounts]
END
GO


CREATE PROCEDURE [get_db_table_rowcounts] @MyDB sysname
AS
BEGIN

-- List all database table row counts.

IF db_id(@MyDB) IS NOT NULL
BEGIN
	DECLARE @CMD VARCHAR(2000)

	SELECT @CMD = 'USE ' + @MyDB + ';' +
		'SELECT OBJECT_NAME(a.object_id), SUM (row_count) FROM sys.dm_db_partition_stats a, sys.tables b ' + 
		' WHERE a.object_id = b.object_id and b.type = ' + '''' + 'U' + '''' +
		' AND (a.index_id=0 or a.index_id=1) GROUP BY a.object_id ORDER BY OBJECT_NAME(a.object_id); '

	EXEC ( @CMD )
	--select @CMD

END
ELSE
	PRINT 'Database ' + @MyDB + ' does not exist!'
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[get_db_table_rowcounts]') AND type in (N'P'))
BEGIN
	Print 'CREATED PROCEDURE [get_db_table_rowcounts]'
END
GO