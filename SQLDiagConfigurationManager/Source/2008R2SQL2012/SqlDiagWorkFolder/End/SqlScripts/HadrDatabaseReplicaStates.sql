		SELECT 'Information' AS [Category], 'AlwaysOn_Replicas' AS [Information], database_id, group_id, replica_id, group_database_id, is_local, synchronization_state_desc, 
			is_commit_participant, synchronization_health_desc, database_state_desc, is_suspended, suspend_reason_desc, last_sent_time, last_received_time, last_hardened_time, 
			last_redone_time, log_send_queue_size, log_send_rate, redo_queue_size, redo_rate, filestream_send_rate, last_commit_time, low_water_mark_for_ghosts 
		FROM sys.dm_hadr_database_replica_states;

