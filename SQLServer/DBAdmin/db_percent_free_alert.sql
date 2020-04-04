USE [DB_ADMIN]
GO

/****** Object:  StoredProcedure [dbo].[db_percent_free_alert]    Script Date: 5/18/2016 9:39:22 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



DROP PROCEDURE [dbo].[db_percent_free_alert]
GO
CREATE PROCEDURE [dbo].[db_percent_free_alert] @maxpercentfree int = 30
AS
BEGIN

-- Sends an alert if the percentage of db space free is less than the 
-- is less than the value passed to @maxpercentfree  

	Declare @mybody nvarchar(max),
	@myprofile_name varchar(250),
    @myrecipients varchar(250),
    @mysubject varchar(250)

	Set @myprofile_name = 'Database Alerts'
	Set @myrecipients = 'dbas@ghostery.com'
	Set @mysubject = 'SQL Server Database Space Alert for Instance ' + @@servername

	create table #dbsizes
	(
		dbname varchar(255),
		myfilename varchar(1000),
		type_desc sysname,
		CurrrentSizeMB decimal (10,2),
		FreeSpaceMB decimal (10,2),
		UsedSpaceMB decimal (10,2),
		Percentfree decimal 
	)

	Declare @cmd varchar(255)

	select @cmd = 'exec sp_msforeachdb "exec DB_ADMIN..[get_db_space_info] ''?''"'

	insert into #dbsizes exec ( @cmd )

	SET  @mybody =
	N'<H1>Databases with Less than ' + str(@maxpercentfree,3,0) + '% Free</H1>' +
	N'<table border="1">' +
    N'<tr><th>Database Name</th><th>File Name</th>' +
    N'<th>Currrent Size MB</th><th>Percent Free</th>' +
	cast ((select td = dbname, '', 
			td = myfilename, '',
			td = CurrrentSizeMB, '',
			td = Percentfree
		from #dbsizes where PercentFree < @maxpercentfree  
		FOR XML PATH('tr'), TYPE )
		as varchar(max))  +
    N'</table>' ;

	IF @mybody IS NOT NULL
	BEGIN
		EXEC msdb.dbo.sp_send_dbmail
			@profile_name = @myprofile_name,
			@recipients = @myrecipients,
			@body = @mybody,
			@subject = @mysubject,
			@body_format = 'HTML' ;
	END

	drop table #dbsizes
END





GO


