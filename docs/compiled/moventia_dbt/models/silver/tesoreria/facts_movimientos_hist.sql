

WITH changes AS (

    SELECT *
    FROM [wh_silver].[stg].[int_tesoreria_movimientos_changes]
    WHERE change_type = 'CHANGED'

),

hist_rows AS (

    SELECT
        CONVERT(
            VARCHAR(64),
            HASHBYTES(
                'SHA2_256',
                CONCAT(
                    ISNULL(old_movement_hash_key, ''), '|',
                    ISNULL(old_hash_diff, ''), '|',
                    CONVERT(VARCHAR(10), old_current_valid_from, 23), '|',
                    CONVERT(VARCHAR(10), DATEADD(DAY, -1, source_snapshot_date), 23)
                )
            ),
            2
        ) AS hist_version_key,

        old_movement_hash_key AS movement_hash_key,
        old_movement_occurrence_num AS movement_occurrence_num,

        old_bank_code AS bank_code,
        old_bank_desc AS bank_desc,
        old_company_code AS company_code,
        old_company_desc AS company_desc,
        old_flow_code AS flow_code,
        old_movement_date AS movement_date,
        old_book_date AS book_date,
        old_signed_amount AS signed_amount,
        old_importe_signo_div_cuenta AS importe_signo_div_cuenta,
        old_referencia AS referencia,

        old_hash_diff AS hash_diff,

        old_current_valid_from AS hist_valid_from,
        DATEADD(DAY, -1, source_snapshot_date) AS hist_valid_to,

        old_source_snapshot_date AS source_snapshot_date,
        old_source_table AS _source_table,
        old_bronze_ingestion_timestamp AS _bronze_ingestion_timestamp,

        old_load_ts AS _load_ts,
        CAST(SYSDATETIME() AS DATETIME2(6)) AS _hist_load_ts

    FROM changes

)

SELECT *
FROM hist_rows