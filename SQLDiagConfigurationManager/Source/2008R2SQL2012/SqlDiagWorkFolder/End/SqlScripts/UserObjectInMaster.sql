	SELECT 'Database_checks' AS [Category], 'User_Objects_in_master' AS [Information], ss.name AS [Schema_Name], sao.name AS [Object_Name], sao.[type_desc] AS [Object_Type], sao.create_date, sao.modify_date 
	FROM master.sys.all_objects sao
	INNER JOIN master.sys.schemas ss ON sao.[schema_id] = ss.[schema_id]
	WHERE sao.is_ms_shipped = 0
	AND sao.[type] IN ('AF','FN','P','IF','PC','TF','TR','T','V')
	ORDER BY sao.name, sao.type_desc;