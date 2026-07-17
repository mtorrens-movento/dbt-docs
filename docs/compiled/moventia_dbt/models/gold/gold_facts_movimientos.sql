

WITH

silver_source AS (

    SELECT
        movement_hash_key,
        movement_occurrence_num,

        bank_code,
        bank_desc,
        company_code,
        company_desc,
        flow_code,

        movement_date,
        book_date,

        CONVERT(INT, CONVERT(CHAR(8), movement_date, 112)) AS movement_date_key,
        CONVERT(INT, CONVERT(CHAR(8), book_date, 112)) AS book_date_key,

        signed_amount,
        importe_signo_div_cuenta,
        referencia,

        hash_diff,

        first_seen_snapshot_date,
        current_valid_from,
        last_seen_snapshot_date,
        source_snapshot_date,

        is_active,

        _source_table,
        _bronze_ingestion_timestamp,
        _load_ts,
        _update_ts

    FROM [wh_silver].[finanzas].[facts_movimientos_dbt]
    WHERE is_active = 1

),

existing AS (

    

        SELECT
            CAST(NULL AS VARCHAR(64)) AS movement_hash_key,
            CAST(NULL AS VARCHAR(64)) AS hash_diff,
            CAST(NULL AS DATETIME2(6)) AS _gold_load_ts,
            CAST(NULL AS DATETIME2(6)) AS _gold_update_ts
        WHERE 1 = 0

    

),

changes AS (

    SELECT
        src.movement_hash_key,
        src.movement_occurrence_num,

        src.bank_code,
        src.bank_desc,
        src.company_code,
        src.company_desc,
        src.flow_code,

        src.movement_date,
        src.book_date,
        src.movement_date_key,
        src.book_date_key,

        src.signed_amount,
        src.importe_signo_div_cuenta,
        src.referencia,

        src.hash_diff,

        src.first_seen_snapshot_date,
        src.current_valid_from,
        src.last_seen_snapshot_date,
        src.source_snapshot_date,

        src.is_active,

        src._source_table,
        src._bronze_ingestion_timestamp,

        src._load_ts AS _silver_load_ts,
        src._update_ts AS _silver_update_ts,

        CASE
            WHEN tgt.movement_hash_key IS NULL THEN CAST(SYSDATETIME() AS DATETIME2(6))
            ELSE tgt._gold_load_ts
        END AS _gold_load_ts,

        CASE
            WHEN tgt.movement_hash_key IS NULL THEN CAST(NULL AS DATETIME2(6))
            ELSE CAST(SYSDATETIME() AS DATETIME2(6))
        END AS _gold_update_ts

    FROM silver_source AS src
    LEFT JOIN existing AS tgt
        ON src.movement_hash_key = tgt.movement_hash_key

    

)

SELECT *
FROM changes