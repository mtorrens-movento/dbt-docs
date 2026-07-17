-- depends_on: [wh_silver].[finanzas].[facts_movimientos_hist_dbt]



WITH changes AS (

    SELECT *
    FROM [wh_silver].[stg].[int_tesoreria_movimientos_changes]
    WHERE change_type IN ('NEW', 'CHANGED')

),

current_rows AS (

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

        CASE
            WHEN change_type = 'NEW' THEN source_snapshot_date
            ELSE old_first_seen_snapshot_date
        END AS first_seen_snapshot_date,

        source_snapshot_date AS current_valid_from,
        source_snapshot_date AS last_seen_snapshot_date,
        source_snapshot_date,

        CAST(1 AS BIT) AS is_active,

        _source_table,
        _bronze_ingestion_timestamp,

        CASE
            WHEN change_type = 'NEW' THEN CAST(SYSDATETIME() AS DATETIME2(6))
            ELSE old_load_ts
        END AS _load_ts,

        CASE
            WHEN change_type = 'CHANGED' THEN CAST(SYSDATETIME() AS DATETIME2(6))
            ELSE CAST(NULL AS DATETIME2(6))
        END AS _update_ts

    FROM changes

)

SELECT *
FROM current_rows