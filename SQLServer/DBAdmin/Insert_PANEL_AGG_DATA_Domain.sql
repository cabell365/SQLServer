use DB_ADMIN
go

IF OBJECT_ID('Insert_PANEL_AGG_DATA_Domain','P') IS NOT NULL
BEGIN
	DROP PROCEDURE Insert_PANEL_AGG_DATA_Domain
END
GO

CREATE PROCEDURE Insert_PANEL_AGG_DATA_Domain @NUMDAYS INT = NULL, @TOPNUM INT = NULL
AS

BEGIN TRY
	INSERT INTO [PANEL_AGG_DATA].[dbo].[Domain]
	SELECT [Name] FROM 
		[GMA].[dbo].[Domain]
		EXCEPT
	SELECT [Name] FROM
		[PANEL_AGG_DATA].[dbo].[Domain]
  END TRY

--Catch error message and rollback the transaction
BEGIN CATCH
	--Display error messages
	SELECT ERROR_LINE() AS 'LINE NUMBER',
		ERROR_NUMBER() AS 'ERROR NUMBER',
		ERROR_MESSAGE() AS 'ERROR MESSAGE'
END CATCH

GO