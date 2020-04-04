USE DB_ADMIN
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[monitor_errorlog_data]') AND type in (N'U'))
BEGIN
	Print 'DROPPING TABLE [monitor_errorlog_data]'
	DROP TABLE [monitor_errorlog_data]
END
GO

CREATE TABLE monitor_errorlog_data
(
	monitor_error_id int,
	monitor_token_1 varchar(50),
	monitor_token2 varchar(50),
	monitor_message varchar(1000)
)

INSERT INTO monitor_errorlog_data
VALUES
(
	60000,
	'Autogrow',
	'timed out',
	'Autogrow has a problem automatically expanding a database on database instance'
)
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[monitor_errorlog_data]') AND type in (N'U'))
BEGIN
	Print 'CREATED TABLE [monitor_errorlog_data]'
END
GO