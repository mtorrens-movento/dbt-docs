-- models/staging/sharepoint/stg_sharepoint__tesoreria_bancos.sql



WITH

params AS (
    SELECT 
        MAX(TRY_CONVERT(DATE, snapshot_date)) AS snapshot_date
    FROM [lh_bronze].[sharepoint].[hist_mst_tesoreria_bancos]
),

src_raw AS (
    SELECT
        b.[Bank Code],
        b.[Bank Desc],
        b.[Bank Group],
        b.[_source_table],
        b.[_bronze_ingestion_timestamp],
        b.snapshot_date
    FROM [lh_bronze].[sharepoint].[hist_mst_tesoreria_bancos] AS b
    INNER JOIN params AS p
        ON TRY_CONVERT(DATE, b.snapshot_date) = p.snapshot_date
),

casting AS (
    SELECT
        TRY_CONVERT(INT, NULLIF(
        LTRIM(RTRIM(TRY_CONVERT(VARCHAR(100), [Bank Code]))),
        ''
    )) AS bank_code,
        NULLIF(
        LTRIM(RTRIM(TRY_CONVERT(VARCHAR(255), [Bank Desc]))),
        ''
    ) AS bank_desc,
        NULLIF(
        LTRIM(RTRIM(TRY_CONVERT(VARCHAR(100), [Bank Group]))),
        ''
    ) AS bank_group,

        TRY_CONVERT(DATE, snapshot_date) AS source_snapshot_date,
        TRY_CONVERT(VARCHAR(255), [_source_table]) AS _source_table,
        TRY_CONVERT(DATETIME2(0), [_bronze_ingestion_timestamp]) AS _bronze_ingestion_timestamp
    FROM src_raw
),

data_quality AS (
    SELECT *
    FROM casting
    WHERE bank_code IS NOT NULL
      AND source_snapshot_date IS NOT NULL
),

dedup AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
    PARTITION BY
        bank_code
    ORDER BY
        _bronze_ingestion_timestamp DESC,
        bank_desc,
        bank_group
) AS rn_business_key
    FROM data_quality
)

SELECT
    bank_code,
    bank_desc,
    bank_group,
    source_snapshot_date,
    _source_table,
    _bronze_ingestion_timestamp,
    CONVERT(
    VARBINARY(32),
    HASHBYTES(
        'SHA2_256',CONCAT(COALESCE(TRY_CONVERT(VARCHAR(8000), bank_desc), ''), '|',COALESCE(TRY_CONVERT(VARCHAR(8000), bank_group), '')))
) AS hash_diff
FROM dedup
WHERE rn_business_key = 1