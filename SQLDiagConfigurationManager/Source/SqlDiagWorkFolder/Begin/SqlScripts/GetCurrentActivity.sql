/*
Author: Mohamed Sharaf
http://blogs.msdn.com/mosharaf  	twitter:@mohamSharaf
Version:2.0

Comments:
GetCurrentActivity()  function is a helper function to get the current activity on SQL Server instance. 
Uses the helper function udf_GetHeadBlocker. I takes one parameter (@lightweight) if set to 1 then the function will not collect
the query plans and the database name from the query plan attributes

Version History:
1.1 fix the bug of not showing records because of the where condition on the dm_exec_plan_attributes attribute column
1.2 show the query in a better xml format (Path instead of Raw)
1.3 get the duration so far for help identifying long running queries
1.4 create a light version without executaion plans 
1.5 make the group_id hidden in the case of SQL 2005 | use Type keyword with for xml
1.6 ignore 2005, minimum version is 10 | fixing the XML conversion error for 0X0000 character
1.7 skipping getting the database name from the query plan attributes
1.8 returning back support of 2005 by removing the RG groups,  add support for API cursors. make all columns starting with small letters. 
1.9 fixing the extra character at the begining of the TSQL
2.0 fixing the maximum recursion exhasted error when a process blocks itself
2.1 fixing the blocking chain function. change the AND operator when the session is blocking itself to OR.
ToDo: add object_id for the stored procedures 
*/


/****************Helper function MSGetHeadBlocker*****************/
USE master;
GO
IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   name = 'udf_GetHeadBlocker'
                    AND type_desc = 'SQL_SCALAR_FUNCTION' )
    DROP FUNCTION dbo.udf_GetHeadBlocker
GO
CREATE FUNCTION dbo.udf_GetHeadBlocker ( @blockerID SMALLINT )
RETURNS VARCHAR(200)
AS
    BEGIN
  /*
  Author: Mohamed Sharaf
  http://blogs.msdn.com/mosharaf
  twitter:@mohamSharaf
  */
        DECLARE @result VARCHAR(200);
        WITH    blocking ( blevel, BlockChain, blocking_session_id )
                  AS ( SELECT   blevel = 1 ,
                                BlockChain = CONVERT(VARCHAR(200), ( CONVERT(VARCHAR(5), r.session_id)
                                                              + '==>'
                                                              + CONVERT(VARCHAR(5), r.blocking_session_id) )) ,
                                blocking_session_id = r.blocking_session_id
                       FROM     sys.dm_exec_requests r
                       WHERE    r.session_id = @blockerID
                       UNION ALL
                       SELECT   blevel = blevel + 1 ,
                                BlockChain = CONVERT(VARCHAR(200), ( BlockChain
                                                              + CONVERT(VARCHAR(200), ( '==>'
                                                              + CONVERT(VARCHAR(5), r2.blocking_session_id) )) )) ,
                                blocking_session_id = r2.blocking_session_id
                       FROM     sys.dm_exec_requests r2
                                JOIN blocking b ON r2.session_id = b.blocking_session_id AND r2.session_id = r2.session_id
								WHERE r2.blocking_session_id<> 0 AND r2.blocking_session_id <> r2.session_id
                     )
            SELECT  @result = BlockChain
            FROM    blocking
            WHERE   blevel = ( SELECT   MAX(blevel)
                               FROM     blocking
                             );

        RETURN @result;
    END
GO
/*******************************************************************************/

USE master;
GO
IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   name = 'udf_GetCursorQuery'
                    AND type_desc = 'SQL_SCALAR_FUNCTION' )
    DROP FUNCTION dbo.udf_GetCursorQuery
GO
CREATE FUNCTION dbo.udf_GetCursorQuery (@sessionID INT )
RETURNS XML
AS
    BEGIN
  /*
  Author: Mohamed Sharaf
  http://blogs.msdn.com/mosharaf		twitter:@mohamSharaf
    */
        DECLARE @result XML;
		SELECT @result=( SELECT SUBSTRING(stc.text,
                                                  CASE WHEN cur.statement_start_offset = 0
                                                            OR cur.statement_start_offset IS NULL
                                                       THEN 1
                                                       ELSE cur.statement_start_offset
                                                            / 2 + 1
                                                  END,
                                                  CASE WHEN cur.statement_end_offset = 0
                                                            OR cur.statement_end_offset = -1
                                                            OR cur.statement_end_offset IS NULL
                                                       THEN LEN(text)
                                                       ELSE cur.statement_end_offset
                                                            / 2
                                                  END
                                                  - CASE WHEN cur.statement_start_offset = 0
                                                              OR cur.statement_start_offset IS NULL
                                                         THEN 1
                                                         ELSE cur.statement_start_offset
                                                              / 2
                                                    END ) + 
													N'    |' + cur.properties + N' |dormant_duration: ' + CAST(cur.dormant_duration AS NVARCHAR(20)) + '|'
													 FOR XML PATH('CursorQuery')  
		
		  ) 
		  FROM sys.dm_exec_requests r 
		OUTER  APPLY sys.dm_exec_cursors(r.session_id) cur
		CROSS APPLY sys.dm_exec_sql_text(cur.sql_handle) stc
		WHERE r.session_id=@sessionID;

        RETURN @result;
    END
GO

/******************************************************************************/
IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   name = 'GetCurrentActivity'
                    AND type_desc = 'SQL_TABLE_VALUED_FUNCTION' )
    DROP FUNCTION dbo.GetCurrentActivity
GO
CREATE FUNCTION dbo.GetCurrentActivity ( @lightweight BIT = 1 )
RETURNS @activeSessions TABLE
    (
      session_id SMALLINT ,
      status NVARCHAR(60) ,
      command NVARCHAR(64) ,
      waiting_summary NVARCHAR(200) ,
      database_name NVARCHAR(128) ,
      sqlQuery XML ,
	  cursorQuery XML,
      wait_duration_ms BIGINT ,
      blocking_session_id SMALLINT ,
      blockChain VARCHAR(200) ,
      elapsed_time_ms BIGINT ,
      physical_reads_KB BIGINT ,
      logical_writes_KB BIGINT ,
      logical_reads_KB BIGINT ,
      granted_query_memory_KB INT ,
      cpu_time_ms INT ,
      host_name NVARCHAR(256) ,
      program_name NVARCHAR(256) ,
      query_plan XML ,
      fn_version VARCHAR(10)
    )
AS
    BEGIN
  /*
  Author: Mohamed Sharaf
  http://blogs.msdn.com/mosharaf		twitter:@mohamSharaf
  Version:2.0
  */
DECLARE @serverVersion VARCHAR(20),@fn_version CHAR(5);
SET @serverVersion=CAST(SERVERPROPERTY('productversion') AS VARCHAR(20));
SET @serverVersion=LEFT(@serverVersion,CHARINDEX('.',@serverVersion)-1)
SET @fn_version='2.1'; 
IF @lightweight=1
BEGIN

        INSERT  @activeSessions
                ( session_id ,
                  status ,
                  command ,
                  waiting_summary ,
                  database_name ,
                  sqlQuery ,
				  cursorQuery,
                  wait_duration_ms ,
                  blocking_session_id ,
                  blockChain ,
                  elapsed_time_ms ,
                  physical_reads_KB ,
                  logical_writes_KB ,
                  logical_reads_KB ,
                  granted_query_memory_KB ,
                  cpu_time_ms ,
                  host_name ,
                  program_name ,
                  query_plan ,
                  fn_version
                )
                SELECT  s.session_id ,
                        r.status ,
                        r.command ,
                        wt.wait_type + ' [ '
                        + CONVERT(NVARCHAR(10), wt.wait_duration_ms)
                        + ' ms ] ' + wt.resource_description AS 'waiting_summary' ,
                        '--Skipped--' AS  database_name
      --TSQL from exec_requests
                        ,
                       ( SELECT SUBSTRING(st.text,
                                                  CASE WHEN r.statement_start_offset = 0
                                                            OR r.statement_start_offset IS NULL
                                                       THEN 1
                                                       ELSE r.statement_start_offset
                                                            / 2 + 1
                                                  END,
                                                  CASE WHEN r.statement_end_offset = 0
                                                            OR r.statement_end_offset = -1
                                                            OR r.statement_end_offset IS NULL
                                                       THEN LEN(text)
                                                       ELSE r.statement_end_offset
                                                            / 2
                                                  END
                                                  - CASE WHEN r.statement_start_offset = 0
                                                              OR r.statement_start_offset IS NULL
                                                         THEN 1
                                                         ELSE r.statement_start_offset
                                                              / 2
                                                    END )  
                             FOR
                               XML PATH('sqlQuery') , TYPE
                             ) AS sQLQuery
      ---End TSQL
                        ,
						dbo.udf_GetCursorQuery(r.session_id),
                        wt.wait_duration_ms ,
                        r.blocking_session_id ,
                        dbo.udf_GetHeadBlocker(s.session_id) AS 'blockChain' ,
                        r.total_elapsed_time AS elapsed_time_ms ,
                        r.reads * 8 AS 'physical_reads_Kb' ,
                        r.writes * 8 AS 'logical_writes_kb' ,
                        r.logical_reads * 8 AS 'logical_reads_kb' ,
                        r.granted_query_memory * 8 AS 'granted_query_memory_kb' ,
                        r.cpu_time AS 'cpu_time_ms' ,
                        s.host_name ,
                        s.program_name ,
                        N'<Queryplan>skipped</Queryplan>' AS query_plan ,
                        @fn_version AS 'fn_version'
                FROM    sys.dm_exec_sessions s
                        JOIN sys.dm_exec_requests r ON s.session_id = r.session_id
                        JOIN sys.dm_exec_connections c ON s.session_id = c.session_id
                        LEFT OUTER JOIN sys.dm_os_waiting_tasks wt ON c.session_id = wt.session_id
                        OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) st
                WHERE   s.session_id <> @@SPID
        OPTION  ( RECOMPILE )
END
ELSE
BEGIN
        INSERT  @activeSessions
                ( session_id ,
                  status ,
                  command ,
                  waiting_summary ,
                  database_name ,
                  sqlQuery ,
				  cursorQuery,
                  wait_duration_ms ,
                  blocking_session_id ,
                  blockChain ,
                  elapsed_time_ms ,
                  physical_reads_KB ,
                  logical_writes_KB ,
                  logical_reads_KB ,
                  granted_query_memory_KB ,
                  cpu_time_ms ,
                  host_name ,
                  program_name ,
                  query_plan ,
                  fn_version
                )
                SELECT  s.session_id ,
                        r.status ,
                        r.command ,
                        wt.wait_type + ' [ '
                        + CONVERT(NVARCHAR(10), wt.wait_duration_ms)
                        + ' ms ] ' + wt.resource_description AS 'waiting_summary' ,
                        DB_NAME(CONVERT(INT, pa.value)) AS database_name
      --TSQL from exec_requests
                        ,
                       ( SELECT SUBSTRING(st.text,
                                                  CASE WHEN r.statement_start_offset = 0
                                                            OR r.statement_start_offset IS NULL
                                                       THEN 1
                                                       ELSE r.statement_start_offset
                                                            / 2 + 1
                                                  END,
                                                  CASE WHEN r.statement_end_offset = 0
                                                            OR r.statement_end_offset = -1
                                                            OR r.statement_end_offset IS NULL
                                                       THEN LEN(text)
                                                       ELSE r.statement_end_offset
                                                            / 2
                                                  END
                                                  - CASE WHEN r.statement_start_offset = 0
                                                              OR r.statement_start_offset IS NULL
                                                         THEN 1
                                                         ELSE r.statement_start_offset
                                                              / 2
                                                    END )  
                             FOR
                               XML PATH('SQLQuery') , TYPE
                             ) AS sqlQuery
      ---End TSQL
                        ,
						dbo.udf_GetCursorQuery(r.session_id),
                        wt.wait_duration_ms ,
                        r.blocking_session_id ,
                        dbo.udf_GetHeadBlocker(s.session_id) AS 'blockChain' ,
                        r.total_elapsed_time AS elapsed_time_ms ,
                        r.reads * 8 AS 'physical_reads_Kb' ,
                        r.writes * 8 AS 'logical_writes_kb' ,
                        r.logical_reads * 8 AS 'logical_reads_kb' ,
                        r.granted_query_memory * 8 AS 'granted_query_memory_kb' ,
                        r.cpu_time AS 'cpu_time_ms' ,
                        s.host_name ,
                        s.program_name ,
                        qp.query_plan AS query_plan ,
                        @fn_version AS 'fn_version'
                FROM    sys.dm_exec_sessions s
                        JOIN sys.dm_exec_requests r ON s.session_id = r.session_id
                        JOIN sys.dm_exec_connections c ON s.session_id = c.session_id
                        LEFT OUTER JOIN sys.dm_os_waiting_tasks wt ON c.session_id = wt.session_id
                        OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) st
                        OUTER APPLY sys.dm_exec_query_plan(r.plan_handle) qp
                        OUTER APPLY sys.dm_exec_plan_attributes(plan_handle) pa
                WHERE   ( pa.attribute = 'dbid'
                          OR pa.attribute IS NULL
                        )
                        AND s.session_id <> @@SPID
        OPTION  ( RECOMPILE )
END 


        RETURN;
    END


/******************************************************************************/