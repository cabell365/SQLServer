--Script rebuild indexes with average fragmentation > 30
EXEC [DB_ADMIN]..get_index_fragmentation @DBNAME = 'GMA', @SCRIPT = 1

--List all tables sorted by average fragmentation
EXEC [DB_ADMIN]..get_index_fragmentation @DBNAME = 'DELL_MCMDATA', @SCRIPT = 0

--Lists Indexes that might not be used
EXEC [DB_ADMIN]..[get_indexes_not_used] @DBNAME = 'GMA'
EXEC [DB_ADMIN]..[get_indexes_not_used] @DBNAME = 'DELL_MCMDATA'

--Get index usuage by database
EXEC [DB_ADMIN]..[get_index_usage] @DBNAME = 'GMA'

--Get current memory usage
EXEC [DB_ADMIN]..[get_current_memory_usage]

--Get the 20 slowest queries
EXEC [DB_ADMIN]..[get_20_slowest_queries]

--Get execution plan and sql for the current date on a particular database
EXEC [DB_ADMIN]..[get_query_plan_by_db] @DBNAME = 'GMA'

--Get execution plan and sql for a specific date on a particular database
EXEC [DB_ADMIN]..[get_query_plan_by_db] @DBNAME = 'GMA', @MYDATE = '02/03/2015'

--Get active processes
EXEC [DB_ADMIN]..[get_active_processes]

--Get database table sizes
exec DB_ADMIN..[get_db_table_sizes] 'gma'

--Get database table row counts
exec DB_ADMIN..[get_db_table_rowcounts] 'gma'

--Get space free for a database
exec DB_ADMIN..[get_db_percent_free] 'gma'

--Get max space free percent check on all database
exec DB_ADMIN..[get_db_percent_free] 30


