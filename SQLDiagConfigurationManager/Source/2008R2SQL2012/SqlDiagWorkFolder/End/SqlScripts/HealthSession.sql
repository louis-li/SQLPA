DECLARE @langid smallint
SELECT @langid = lcid FROM sys.syslanguages WHERE name = @@LANGUAGE

	IF EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#SystemHealthSessionData'))
	DROP TABLE #SystemHealthSessionData;
	IF NOT EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#SystemHealthSessionData'))
	CREATE TABLE #SystemHealthSessionData (target_data XML)
		
	-- Store the XML data in a temporary table
	INSERT INTO #SystemHealthSessionData
	SELECT CAST(xet.target_data AS XML)
	FROM sys.dm_xe_session_targets xet
	INNER JOIN sys.dm_xe_sessions xe ON xe.address = xet.event_session_address
	WHERE xe.name = 'system_health'
	
	IF (SELECT COUNT(*) FROM #SystemHealthSessionData a WHERE CONVERT(VARCHAR(max), target_data) LIKE '%error_reported%') > 0
	BEGIN
			
		-- Get detailed information about all the errors reported
		;WITH cteHealthSession AS (SELECT C.query('.').value('(/event/@timestamp)[1]', 'datetime') AS EventTime,
			C.query('.').value('(/event/data[@name="error_number"]/value)[1]', 'int') AS ErrorNumber,
			C.query('.').value('(/event/data[@name="severity"]/value)[1]', 'int') AS ErrorSeverity,
			C.query('.').value('(/event/data[@name="state"]/value)[1]', 'int') AS ErrorState,
			C.query('.').value('(/event/data[@name="message"]/value)[1]', 'VARCHAR(MAX)') AS ErrorText,
			C.query('.').value('(/event/action[@name="session_id"]/value)[1]', 'int') AS SessionID,
			C.query('.').value('(/event/data[@name="category"]/text)[1]', 'VARCHAR(10)') AS ErrorCategory
			FROM #SystemHealthSessionData a
			CROSS APPLY a.target_data.nodes('/RingBufferTarget/event') AS T(C)
			WHERE C.query('.').value('(/event/@name)[1]', 'VARCHAR(500)') = 'error_reported')
		SELECT  
			EventTime AS [Logged_Date],
			ErrorNumber AS [Error_Number],
			ErrorSeverity AS [Error_Sev],
			ErrorState AS [Error_State],
			ErrorText AS [Logged_Message],
			SessionID
		FROM cteHealthSession
		ORDER BY EventTime
	END