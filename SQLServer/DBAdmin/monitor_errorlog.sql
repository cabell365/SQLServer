USE DB_ADMIN
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[monitor_errorlog]') AND type in (N'P'))
BEGIN
	Print 'DROPPING PROCEDURE [get_index_fragmentation]'
	DROP PROCEDURE [monitor_errorlog]
END
GO


CREATE PROCEDURE [monitor_errorlog] @MyMinute int
AS
BEGIN

	--Declare variables
	DECLARE @Now datetime
	DECLARE @NowMinusMyMinute datetime
	DECLARE @MyCnt int
	DECLARE @MyMessage varchar(100)

	--Set date time for execution and execution - value of MyMinute
	SET @Now = getdate()
	SELECT  @NowMinusMyMinute = dateadd(mi,-@MyMinute,@Now)

	--Create temp table to hold data returned from procedure to read the errorlog
	Create Table #MyLog (LogDate datetime, ProcessInfo varchar(50), MyText varchar(8000))

	--INSERT INTO temp table. The command reads the error log searching for the tokens
	--'Autogrow' and 'time outs' for the time specfied and sorts in descENDing order
	INSERT INTO #MyLog exec xp_readerrorlog 0, 1, N'Autogrow', N'timed out', @NowMinus30, @Now, 'DESC';

	--Determine number of rows returned from read log command.
	SELECT @MyCnt = count(*) from #MyLog

	--Determine if a row is found. Write message to Error log that there is an issue with autogrow.
	--The message will be picked up by the alerts an alert was created for the error message id.
	IF @MyCnt > 0
	BEGIN
		SELECT @MyMessage =  N'Autogrow has a problem automatically expanding a database on database instance ' + @@servername;
		SELECT @MyMessage
		Exec xp_logevent 60000, @MyMessage, ERROR
	END

	--Drop temp table.
	Drop Table #MyLog
END
GO

--Verify that the procedure was created.
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[monitor_errorlog]') AND type in (N'P'))
BEGIN
	Print 'CREATED PROCEDURE [monitor_errorlog]'
END
GO