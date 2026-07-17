



SELECT
    flow_code,
    flow_desc,

    TRY_CONVERT(DATE, dbt_valid_from) AS fecha_inicio,

    TRY_CONVERT(
        DATE,
        COALESCE(dbt_valid_to, CONVERT(DATETIME2(0), '9999-12-31'))
    ) AS fecha_fin,

    CAST(
        CASE 
            WHEN dbt_valid_to IS NULL THEN 1
            ELSE 0
        END AS BIT
    ) AS es_actual,

    hash_diff,
    source_snapshot_date,
    _source_table,
    _bronze_ingestion_timestamp,

    TRY_CONVERT(DATETIME2(0), dbt_valid_from) AS _load_ts,
    CAST(NULL AS DATETIME2(0)) AS _update_ts

FROM [wh_silver].[snapshots].[snap_dim_flujos]

