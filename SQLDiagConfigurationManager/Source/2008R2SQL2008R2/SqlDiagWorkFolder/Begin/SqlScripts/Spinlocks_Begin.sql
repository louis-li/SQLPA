	SELECT name, collisions, spins, spins_per_collision, sleep_time, backoffs
	FROM sys.dm_os_spinlock_stats;


--;WITH cteSpinlocks1 AS (SELECT name, collisions, spins, spins_per_collision, sleep_time, backoffs FROM #tblSpinlocksBefore),
--	cteSpinlocks2 AS (SELECT name, collisions, spins, spins_per_collision, sleep_time, backoffs FROM #tblSpinlocksAfter)
--SELECT DISTINCT t1.name,
--		(t2.collisions-t1.collisions) AS collisions,
--		(t2.spins-t1.spins) AS spins,
--		(t2.spins_per_collision-t1.spins_per_collision) AS spins_per_collision,
--		(t2.sleep_time-t1.sleep_time) AS sleep_time,
--		(t2.backoffs-t1.backoffs) AS backoffs,
--		100.0 * (t2.spins-t1.spins) / SUM(t2.spins-t1.spins) OVER() AS spins_pct,
--		ROW_NUMBER() OVER(ORDER BY t2.spins DESC) AS rn
--FROM cteSpinlocks1 t1 INNER JOIN cteSpinlocks2 t2 ON t1.name = t2.name
--GROUP BY t1.name, t1.collisions, t2.collisions, t1.spins, t2.spins, t1.spins_per_collision, t2.spins_per_collision, t1.sleep_time, t2.sleep_time, t1.backoffs, t2.backoffs
--HAVING (t2.spins-t1.spins) > 0
--ORDER BY spins DESC;
