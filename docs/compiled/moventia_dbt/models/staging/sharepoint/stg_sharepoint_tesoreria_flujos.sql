

WITH

params AS (
    SELECT 
        MAX(TRY_CONVERT(DATE, snapshot_date)) AS snapshot_date
    FROM [lh_bronze].[sharepoint].[hist_dict_tesoreria_flujos]
),

src_raw AS (
    SELECT
        f.[Code],
        f.[Description],
        f.[_source_table],
        f.[_bronze_ingestion_timestamp],
        f.snapshot_date
    FROM [lh_bronze].[sharepoint].[hist_dict_tesoreria_flujos] AS f
    INNER JOIN params AS p
        ON TRY_CONVERT(DATE, f.snapshot_date) = p.snapshot_date
),

casting AS (
    SELECT
        NULLIF(
        LTRIM(RTRIM(TRY_CONVERT(VARCHAR(50), [Code]))),
        ''
    ) AS flow_code,
        NULLIF(
        LTRIM(RTRIM(TRY_CONVERT(VARCHAR(255), [Description]))),
        ''
    ) AS flow_desc,

        TRY_CONVERT(DATE, snapshot_date) AS source_snapshot_date,
        TRY_CONVERT(VARCHAR(255), [_source_table]) AS _source_table,
        TRY_CONVERT(DATETIME2(0), [_bronze_ingestion_timestamp]) AS _bronze_ingestion_timestamp
    FROM src_raw
),

data_quality AS (
    SELECT *
    FROM casting
    WHERE flow_code IS NOT NULL
      AND source_snapshot_date IS NOT NULL
),

dedup AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
    PARTITION BY
        flow_code
    ORDER BY
        _bronze_ingestion_timestamp DESC,
        flow_desc
) AS rn_business_key
    FROM data_quality
)

SELECT
    flow_code,
    flow_desc,
    source_snapshot_date,
    _source_table,
    _bronze_ingestion_timestamp,
    CONVERT(
    VARBINARY(32),
    HASHBYTES(
        'SHA2_256',COALESCE(TRY_CONVERT(VARCHAR(8000), flow_desc), ''))
) AS hash_diff
FROM dedup
WHERE rn_business_key = 1