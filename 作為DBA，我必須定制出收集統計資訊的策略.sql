���M����Long running SQL �P�έp��T�L���A���O���٬O���X�n�T�O�έp��T���ǽT�ʡC�@��DBA�A�ڥ����w��X�����έp��T�������A�H�ά����}���A�U���N�O�@������T�O�έp��T�ǽT�ʪ��}���A���X�Ӥ��ɤ@�U�C    

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
