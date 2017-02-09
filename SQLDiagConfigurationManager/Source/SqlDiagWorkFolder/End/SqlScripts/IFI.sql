	DECLARE @ifi bit, @sao as smallint, @xcmd as smallint, @CMD as varchar(8000),@ErrorMessage as varchar(max)

		SELECT @sao = CAST([value] AS smallint) FROM sys.configurations WITH (NOLOCK) WHERE [name] = 'show advanced options'
		SELECT @xcmd = CAST([value] AS smallint) FROM sys.configurations WITH (NOLOCK) WHERE [name] = 'xp_cmdshell'
		IF @sao = 0
	BEGIN
		EXEC sp_configure 'show advanced options', 1; RECONFIGURE WITH OVERRIDE;
	END
	IF @xcmd = 0
	BEGIN
		EXEC sp_configure 'xp_cmdshell', 1; RECONFIGURE WITH OVERRIDE;
	END

	BEGIN TRY
		DECLARE @xp_cmdshell_output2 TABLE ([Output] VARCHAR (8000));
		SET @CMD = ('whoami /priv')
		INSERT INTO @xp_cmdshell_output2
		EXEC master.dbo.xp_cmdshell @CMD;
			
		IF EXISTS (SELECT * FROM @xp_cmdshell_output2 WHERE [Output] LIKE '%SeManageVolumePrivilege%')
		BEGIN
			SELECT 'Instance_checks' AS [Category], 'Instant_Initialization' AS [Check], '[OK]' AS [Deviation];
			SET @ifi = 1;
		END
		ELSE
		BEGIN
			SELECT 'Instance_checks' AS [Category], 'Instant_Initialization' AS [Check], '[WARNING: Instant File Initialization is disabled. This can impact data file autogrowth times]' AS [Deviation];
			SET @ifi = 0
		END
	END TRY
	BEGIN CATCH
		SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage;
		SELECT @ErrorMessage = 'IFI subsection - Error raised in TRY block. ' + ERROR_MESSAGE()
		RAISERROR (@ErrorMessage, 16, 1);
	END CATCH

	IF @xcmd = 0
	BEGIN
		EXEC sp_configure 'xp_cmdshell', 0; RECONFIGURE WITH OVERRIDE;
	END
	IF @sao = 0
	BEGIN
		EXEC sp_configure 'show advanced options', 0; RECONFIGURE WITH OVERRIDE;
	END