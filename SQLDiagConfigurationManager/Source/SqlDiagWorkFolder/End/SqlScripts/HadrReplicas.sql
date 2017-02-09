	SELECT 
		  ag.name AS ag_name, 
		  ar.replica_server_name  ,
		  ar_state.is_local AS is_ag_replica_local, 
		  ag_replica_role_desc = 
				CASE 
					  WHEN ar_state.role_desc IS NULL THEN N'<unknown>'
					  ELSE ar_state.role_desc 
				END, 
		  ag_replica_operational_state_desc = 
				CASE 
					  WHEN ar_state.operational_state_desc IS NULL THEN N'<unknown>'
					  ELSE ar_state.operational_state_desc 
				END, 
		  ag_replica_connected_state_desc = 
				CASE 
					  WHEN ar_state.connected_state_desc IS NULL THEN 
							CASE 
								  WHEN ar_state.is_local = 1 THEN N'CONNECTED'
								  ELSE N'<unknown>'
							END
					  ELSE ar_state.connected_state_desc 
				END
		  --ar.secondary_role_allow_read_desc
	FROM 

		  sys.availability_groups AS ag 
		  JOIN sys.availability_replicas AS ar 
		  ON ag.group_id = ar.group_id
	JOIN sys.dm_hadr_availability_replica_states AS ar_state 
	ON  ar.replica_id = ar_state.replica_id;