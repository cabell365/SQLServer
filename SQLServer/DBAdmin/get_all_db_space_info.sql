USE [DB_ADMIN]
GO

/****** Object:  StoredProcedure [dbo].[get_all_db_space_info]    Script Date: 5/18/2016 9:36:13 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


DROP  PROCEDURE [dbo].[get_all_db_space_info]
GO
CREATE PROCEDURE [dbo].[get_all_db_space_info]
AS
BEGIN

	Declare @cmd varchar(100)

	-- Check space available for all databases.
	create table #dbsizes
	(
		dbname sysname,
		myfilename varchar(255),
		type_desc sysname,
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
	select dbname, 
			myfilename,
			CurrrentSizeMB,
			Percentfree
	from #dbsizes
	where type_desc = 'ROWS'
	order by PercentFree;

	--Select log devices
	select dbname, 
			myfilename,
			CurrrentSizeMB,
			Percentfree
	from #dbsizes
	where type_desc = 'LOG'
	order by PercentFree;

	drop table #dbsizes
END




GO


