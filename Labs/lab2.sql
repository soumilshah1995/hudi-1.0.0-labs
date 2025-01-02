-- Create a table with primary key
CREATE TABLE hudi_indexed_table (
    ts BIGINT,
    uuid STRING,
    rider STRING,
    driver STRING,
    fare DOUBLE,
    city STRING
) USING HUDI
options(
    path 's3a://warehouse/default/table_name=hudi_indexed_table',
    primaryKey ='uuid',
    hoodie.write.record.merge.mode = "COMMIT_TIME_ORDERING"
)
PARTITIONED BY (city);

INSERT INTO hudi_indexed_table
VALUES
    (1695159649,'334e26e9-8355-45cc-97c6-c31daf0df330','rider-A','driver-K',19.10,'san_francisco'),
    (1695091554,'e96c4396-3fad-413a-a942-4cb36106d721','rider-C','driver-M',27.70 ,'san_francisco'),
    (1695046462,'9909a8b1-2d15-4d3d-8ec9-efc48c536a00','rider-D','driver-L',33.90 ,'san_francisco'),
    (1695332066,'1dced545-862b-4ceb-8b43-d2a568f6616b','rider-E','driver-O',93.50,'san_francisco'),
    (1695516137,'e3cf430c-889d-4015-bc98-59bdce1e530c','rider-F','driver-P',34.15,'sao_paulo'    ),
    (1695376420,'7a84095f-737f-40bc-b62f-6b69664712d2','rider-G','driver-Q',43.40 ,'sao_paulo'    ),
    (1695173887,'3eeb61f7-c2b0-4636-99bd-5d7a5a1d2c04','rider-I','driver-S',41.06 ,'chennai'      ),
    (1695115999,'c8abbe79-8d89-47ea-b4ce-4d224bae5bfa','rider-J','driver-T',17.85,'chennai');




-- BEFORE INDEX
-- Files Scanned: 3 (since Hudi is partitioned by city, all partitions are scanned).
-- Duration: Query takes more time as it needs to compute the transformation for every row.
SELECT uuid, rider FROM hudi_indexed_table WHERE from_unixtime(ts, 'yyyy-MM-dd') = '2023-10-17';


--Creating the Expression Index
-- We create a column stat expression index on ts column
CREATE INDEX idx_column_ts ON hudi_indexed_table USING column_stats(ts) OPTIONS(expr='from_unixtime', format = 'yyyy-MM-dd');

-- We run the same query again
-- number of files read: 0
SELECT uuid, rider FROM hudi_indexed_table WHERE from_unixtime(ts, 'yyyy-MM-dd') = '2023-10-17';


DROP INDEX expr_index_idx_column_ts on hudi_indexed_table;