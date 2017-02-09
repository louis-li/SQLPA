SELECT 'Information' AS [Category], 'RG_Classifier_Function' AS [Information], 
	CASE WHEN classifier_function_id = 0 
		THEN 'Default_Configuration' 
		ELSE OBJECT_SCHEMA_NAME(classifier_function_id) + '.' + OBJECT_NAME(classifier_function_id) 
	END AS classifier_function, 
	is_reconfiguration_pending
FROM 
	sys.dm_resource_governor_configuration