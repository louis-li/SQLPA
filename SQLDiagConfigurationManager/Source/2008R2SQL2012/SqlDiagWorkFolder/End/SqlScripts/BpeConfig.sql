DECLARE  @sqlmajorver int

SELECT @sqlmajorver = CONVERT(int, (@@microsoftversion / 0x1000000) & 0xff);

IF @sqlmajorver > 11
BEGIN
	SELECT 'Information' AS [Category], 'BP_Extension' AS [Information], 
		CASE WHEN state = 0 THEN 'BP_Extension_Disabled' 
			WHEN state = 1 THEN 'BP_Extension_is_Disabling'
			WHEN state = 3 THEN 'BP_Extension_is_Enabling'
			WHEN state = 5 THEN 'BP_Extension_Enabled'
		END AS state, 
		[path], current_size_in_kb
	FROM sys.dm_os_buffer_pool_extension_configuration
END
ELSE
BEGIN
	SELECT 'Information' AS [Category], 'BP_Extension' AS [Information], '[NA]' AS state
END;