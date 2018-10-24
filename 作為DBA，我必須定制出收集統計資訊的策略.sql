雖然那個Long running SQL 與統計資訊無關，但是我還是提出要確保統計資訊的準確性。作為DBA，我必須定制出收集統計資訊的策略，以及相關腳本，下面就是一個關於確保統計資訊準確性的腳本，拿出來分享一下。    

SELECT OWNER,
           SEGMENT_NAME,
           CASE
             WHEN SIZE_GB < 0.5 THEN
              30
             WHEN SIZE_GB >= 0.5 AND SIZE_GB < 1 THEN
              20
             WHEN SIZE_GB >= 1 AND SIZE_GB < 5 THEN
              10
             WHEN SIZE_GB >= 5 AND SIZE_GB < 10 THEN
              5
             WHEN SIZE_GB >= 10 THEN
              1
           END AS PERCENT,
           8 AS DEGREE
      FROM (SELECT OWNER,
                   SEGMENT_NAME,
                   SUM(BYTES / 1024 / 1024 / 1024) SIZE_GB
              FROM DBA_SEGMENTS
             WHERE OWNER not in  ('SYS', 'SYSTEM', 'SYSMAN', 'DMSYS', 'OLAPSYS', 'XDB',
'EXFSYS', 'CTXSYS', 'WMSYS', 'DBSNMP', 'ORDSYS','OUTLN', 'TSMSYS', 'MDSYS')
               AND SEGMENT_NAME IN
                   (SELECT /*+ UNNEST */ DISTINCT TABLE_NAME
                      FROM DBA_TAB_STATISTICS
                     WHERE (LAST_ANALYZED IS NULL OR STALE_STATS = 'YES')
                       AND OWNER not in ('SYS','SYSTEM', 'SYSMAN', 'DMSYS', 'OLAPSYS', 'XDB',
'EXFSYS', 'CTXSYS', 'WMSYS', 'DBSNMP', 'ORDSYS','OUTLN', 'TSMSYS', 'MDSYS'))
             GROUP BY OWNER, SEGMENT_NAME);
