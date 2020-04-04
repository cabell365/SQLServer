USE [DB_ADMIN]
GO

/****** Object:  StoredProcedure [dbo].[get_current_memory_usage]    Script Date: 7/27/2015 9:36:03 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DROP PROCEDURE [dbo].[get_current_memory_usage]
GO

CREATE PROCEDURE [dbo].[get_current_memory_usage]
AS
BEGIN
	--Gets the amount of memory in MB that SQL Server is currently using
	SELECT
		(physical_memory_in_use_kb/1024) AS Memory_usedby_Sqlserver_MB,
		(locked_page_allocations_kb/1024) AS Locked_pages_used_Sqlserver_MB,
		(total_virtual_address_space_kb/1024) AS Total_VAS_in_MB,
		process_physical_memory_low,
		process_virtual_memory_low,
		memory_utilization_percentage,
		(available_commit_limit_kb/1024) As Available_Commit_Limit_MB
		FROM sys.dm_os_process_memory;
END


GO


