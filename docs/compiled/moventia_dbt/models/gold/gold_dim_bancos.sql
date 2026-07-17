

WITH

silver_source AS (
    SELECT
        bank_code,
        bank_desc,
        bank_group
    FROM [wh_silver].[finanzas].[dim_bancos_dbt]
    WHERE es_actual = 1
),

existing AS (

    

        SELECT
            CAST(NULL AS INT) AS bank_code,
            CAST(NULL AS VARCHAR(255)) AS bank_desc,
            CAST(NULL AS VARCHAR(100)) AS bank_group,
            CAST(NULL AS DATETIME2(0)) AS _gold_load_ts,
            CAST(NULL AS DATETIME2(0)) AS _gold_update_ts
        WHERE 1 = 0

    

),

changes AS (
    SELECT
        src.bank_code,
        src.bank_desc,
        src.bank_group,

        CASE
            WHEN tgt.bank_code IS NULL THEN CAST(SYSDATETIME() AS DATETIME2(6))
            ELSE tgt._gold_load_ts
        END AS _gold_load_ts,

        CASE
            WHEN tgt.bank_code IS NULL THEN CAST(NULL AS DATETIME2(0))
            ELSE CAST(SYSDATETIME() AS DATETIME2(6))
        END AS _gold_update_ts

    FROM silver_source AS src
    LEFT JOIN existing AS tgt
        ON src.bank_code = tgt.bank_code

    
)

SELECT *
FROM changes