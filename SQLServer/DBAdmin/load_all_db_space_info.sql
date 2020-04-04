USE [DB_ADMIN]
GO

/****** Object:  StoredProcedure [dbo].[load_all_db_space_info]    Script Date: 1/28/2016 9:53:07 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[load_all_db_space_info]
AS
BEGIN

	Declare @cmd varchar(100)

	-- Check space available for all databases.
	create table #dbsizes
	(
		dbname sysname,
		myfilename varchar(255),
		CurrrentSizeMB decimal (10,2),
		FreeSpaceMB decimal (10,2),
		UsedSpaceMB decimal (10,2),
		Percentfree decimal
	)

	--Define SP to check individual databases to execute against all databases.
	select @cmd = 'exec sp_msforeachdb "exec DB_ADMIN..[get_db_space_info] ''?''"'

	--Insert results into the temp table
	insert into #dbsizes exec ( @cmd )

	--Select data devices
	select 	dbname,
		getdate(),
		myfilename,
		CurrrentSizeMB,
		FreeSpaceMB,
		UsedSpaceMB,
		Percentfree 
	from #dbsizes
	where myfilename not like '%_log'

	drop table #dbsizes
END



GO


