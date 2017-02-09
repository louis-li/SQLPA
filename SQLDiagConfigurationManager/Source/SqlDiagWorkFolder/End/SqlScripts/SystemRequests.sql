  select CONVERT (varchar(30), getdate(), 126) AS 'runtime', tr.os_thread_id, req.* from sys.dm_exec_requests req join sys.dm_os_workers wrk  on req.task_address = wrk.task_address 
    join sys.dm_os_threads tr on tr.worker_address=wrk.worker_address
    join sys.dm_exec_sessions sess on req.session_id=sess.session_id
    where  sess.is_user_process = 0