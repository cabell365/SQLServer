drop table dbsizes
go
create table dbsizes
(
		dbname sysname,
		execdate datetime,
		myfilename varchar(255),
		CurrrentSizeMB decimal (10,2),
		FreeSpaceMB decimal (10,2),
		UsedSpaceMB decimal (10,2),
		Percentfree decimal
);