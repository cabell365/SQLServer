USE DB_ADMIN
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[clean_nvarchar_max_tables]') AND type in (N'P'))
BEGIN
	Print 'DROPPING PROCEDURE [clean_nvarchar_max_tables]'
	DROP PROCEDURE [clean_nvarchar_max_tables]
END
GO

create procedure clean_nvarchar_max_tables
as

Declare @CMD varchar(500)
DECLARE @dbname sysname,  @maxcolcmd varchar(1000)

create table #maxtables (dbname sysname, tablename sysname, columnname sysname)

DECLARE db_cursor CURSOR FOR  
SELECT name 
FROM MASTER.dbo.sysdatabases 
WHERE name NOT IN ('master','model','msdb','tempdb')  

OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO  @dbname  

WHILE @@FETCH_STATUS = 0   
BEGIN   
	select @CMD = 'insert #maxtables select ' + '''' + @dbname + '''' + ', b.name, a.name from [' + @dbname + '].sys.columns a, [' + @dbname + '].sys.objects b where a.object_id = b.object_id and a.system_type_id = 231 and a.max_length = -1 and b.type = ''U'''
	exec ( @CMD )

	FETCH NEXT FROM db_cursor INTO @dbname  
END   

CLOSE db_cursor   
DEALLOCATE db_cursor

DECLARE maxcol_cursor CURSOR FOR  
select 'dbcc cleantable (' +  '''' + dbname + '''' + ',' + '''' + tablename + '''' + ')' + ' WITH NO_INFOMSGS ' + ' --' + 'nvarchar(max) column is ' + columnname from #maxtables order by dbname

OPEN maxcol_cursor   
FETCH NEXT FROM maxcol_cursor INTO  @maxcolcmd  

WHILE @@FETCH_STATUS = 0   
BEGIN 
	exec ( @maxcolcmd )
	FETCH NEXT FROM maxcol_cursor INTO  @maxcolcmd  
END

CLOSE maxcol_cursor   
DEALLOCATE maxcol_cursor

drop table #maxtables

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[clean_nvarchar_max_tables]') AND type in (N'P'))
BEGIN
	Print 'CREATED PROCEDURE [clean_nvarchar_max_tables]'
END
GO