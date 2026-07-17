



WITH

latest AS (
    SELECT *
    FROM [wh_silver].[stg].[stg_sharepoint_tesoreria_movimientos]
),

current_existing AS (

    

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

classified AS (
    SELECT
        CASE
            WHEN c.movement_hash_key IS NULL THEN 'NEW'
            WHEN c.hash_diff <> l.hash_diff THEN 'CHANGED'
            ELSE 'UNCHANGED'
        END AS change_type,

        l.movement_hash_key,
        l.movement_occurrence_num,
        l.bank_code,
        l.bank_desc,
        l.company_code,
        l.company_desc,
        l.flow_code,
        l.movement_date,
        l.book_date,
        l.signed_amount,
        l.importe_signo_div_cuenta,
        l.referencia,
        l.hash_diff,
        l.source_snapshot_date,
        l._source_table,
        l._bronze_ingestion_timestamp,

        c.movement_hash_key AS old_movement_hash_key,
        c.movement_occurrence_num AS old_movement_occurrence_num,
        c.bank_code AS old_bank_code,
        c.bank_desc AS old_bank_desc,
        c.company_code AS old_company_code,
        c.company_desc AS old_company_desc,
        c.flow_code AS old_flow_code,
        c.movement_date AS old_movement_date,
        c.book_date AS old_book_date,
        c.signed_amount AS old_signed_amount,
        c.importe_signo_div_cuenta AS old_importe_signo_div_cuenta,
        c.referencia AS old_referencia,
        c.hash_diff AS old_hash_diff,
        c.first_seen_snapshot_date AS old_first_seen_snapshot_date,
        c.current_valid_from AS old_current_valid_from,
        c.last_seen_snapshot_date AS old_last_seen_snapshot_date,
        c.source_snapshot_date AS old_source_snapshot_date,
        c._source_table AS old_source_table,
        c._bronze_ingestion_timestamp AS old_bronze_ingestion_timestamp,
        c._load_ts AS old_load_ts,
        c._update_ts AS old_update_ts

    FROM latest AS l
    LEFT JOIN current_existing AS c
        ON l.movement_hash_key = c.movement_hash_key
)

SELECT *
FROM classified
WHERE change_type IN ('NEW', 'CHANGED')