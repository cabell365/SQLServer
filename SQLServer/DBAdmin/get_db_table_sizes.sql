USE DB_ADMIN
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[get_db_table_sizes]') AND type in (N'P'))
BEGIN
	Print 'DROPPING PROCEDURE [get_index_fragmentation]'
	DROP PROCEDURE [get_db_table_sizes]
END
GO


CREATE PROCEDURE [get_db_table_sizes] @MyDB sysname
AS
BEGIN

-- List all database tables and there indexes with  
-- detailed information about row count and  
-- used + reserved data space. 

IF db_id(@MyDB) IS NOT NULL
BEGIN
DECLARE  @CMD VARCHAR(2000)

--Build query string
SELECT @CMD = 'USE ' + @MyDB + 
	';SELECT SCH.name AS SchemaName 
      ,OBJ.name AS ObjName 
      ,OBJ.type_desc AS ObjType 
      ,INDX.name AS IndexName 
      ,INDX.type_desc AS IndexType 
      ,PART.partition_number AS PartitionNumber 
      ,PART.rows AS PartitionRows 
      ,STAT.row_count AS StatRowCount 
      ,STAT.used_page_count * 8  AS UsedSizeKB 
      ,STAT.reserved_page_count * 8 AS RevervedSizeKB 
FROM sys.partitions AS PART ' +
     'INNER JOIN sys.dm_db_partition_stats AS STAT 
         ON PART.partition_id = STAT.partition_id 
            AND PART.partition_number = STAT.partition_number 
     INNER JOIN sys.objects AS OBJ 
         ON STAT.object_id = OBJ.object_id 
     INNER JOIN sys.schemas AS SCH 
         ON OBJ.schema_id = SCH.schema_id 
     INNER JOIN sys.indexes AS INDX 
         ON STAT.object_id = INDX.object_id 
            AND STAT.index_id = INDX.index_id 
	AND OBJ.type_desc = ' + '''' + 'USER_TABLE' + '''' + '
ORDER BY SCH.name 
        ,OBJ.name 
        ,INDX.name 
        ,PART.partition_number'

	EXEC ( @CMD )
	--select @CMD

END
ELSE
	PRINT 'Database ' + @MyDB + ' does not exist!'
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[get_db_table_sizes]') AND type in (N'P'))
BEGIN
	Print 'CREATED PROCEDURE [get_db_table_sizes]'
END
GO