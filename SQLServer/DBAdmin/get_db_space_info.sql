USE [DB_ADMIN]
GO

/****** Object:  StoredProcedure [dbo].[get_db_space_info]    Script Date: 5/18/2016 9:35:43 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



DROP PROCEDURE [dbo].[get_db_space_info]
GO
CREATE PROCEDURE [dbo].[get_db_space_info] @MyDB sysname
AS
BEGIN

--Get file size, amount used and percent used
IF db_id(@MyDB) IS NOT NULL
BEGIN
DECLARE  @CMD VARCHAR(2000)

--Build query string
SELECT @CMD = 'USE [' + @MyDB + '];' + 
'SELECT DB_NAME() AS DbName, 
	name AS FileName,
	type_desc, 
	size/128.0 AS CurrentSizeMB,  
	size/128.0 - CAST(FILEPROPERTY(name, ' + '''' + 'SpaceUsed' + '''' + ') AS INT)/128.0 AS FreeSpaceMB,
	((size/128.0) - (size/128.0 - CAST(FILEPROPERTY(name, ' + '''' + 'SpaceUsed' + '''' + ') AS INT) /128.0 )) AS UsedSpaceMB,
	((size/128.0 - CAST(FILEPROPERTY(name, ' + '''' + 'SpaceUsed' + '''' + ') AS INT)/128.0 ) / (size/128.0) * 100) AS PercentFree
FROM sys.database_files' 

	EXEC ( @CMD )

END
ELSE
	PRINT 'Database ' + @MyDB + ' does not exist!'
END



GO


