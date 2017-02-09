		SELECT 'Information' AS [Category], 'AlwaysOn_Replica_Cluster' AS [Information], replica_id, group_database_id, database_name, is_failover_ready, is_pending_secondary_suspend, 
			is_database_joined, recovery_lsn, Convert(varchar(128),truncation_lsn) as Truncation_LSN
		FROM sys.dm_hadr_database_replica_cluster_states;