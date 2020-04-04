USE [DB_ADMIN]
GO

/****** Object:  StoredProcedure [dbo].[get_db_percent_free]    Script Date: 5/18/2016 9:38:51 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


DROP PROCEDURE [dbo].[get_db_percent_free]
GO
CREATE PROCEDURE [dbo].[get_db_percent_free] @maxpercentfree int
AS
BEGIN

	--Procedure uses get_db_percent_free to dtermine data files with less than X percent free
	create table #dbsizes
	(
		dbname sysname,
		myfilename sysname,
		type_desc sysname,
		CurrrentSizeMB decimal (10,2),
		FreeSpaceMB decimal (10,2),
		UsedSpaceMB decimal (10,2),
		Percentfree decimal
	)

	Declare @cmd varchar(100)

	select @cmd = 'exec sp_msforeachdb "exec DB_ADMIN..[get_db_space_info] ''?''"'

	insert into #dbsizes exec ( @cmd )

	select * from #dbsizes where PercentFree < @maxpercentfree

	drop table #dbsizes
END


GO


