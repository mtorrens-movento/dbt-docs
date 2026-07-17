

WITH

src_current AS (
    SELECT
        company_code,
        company_desc
    FROM [wh_silver].[finanzas].[facts_movimientos_dbt]
    WHERE company_code IS NOT NULL
),

src_hist AS (
    SELECT
        company_code,
        company_desc
    FROM [wh_silver].[finanzas].[facts_movimientos_hist_dbt]
    WHERE company_code IS NOT NULL
),

src_union AS (
    SELECT * FROM src_current
    UNION ALL
    SELECT * FROM src_hist
),

dedup AS (
    SELECT
        company_code,
        MAX(company_desc) AS company_desc
    FROM src_union
    GROUP BY company_code
),

existing AS (

    

        SELECT
            CAST(NULL AS VARCHAR(50)) AS company_code,
            CAST(NULL AS VARCHAR(255)) AS company_desc,
            CAST(NULL AS DATETIME2(0)) AS _gold_load_ts,
            CAST(NULL AS DATETIME2(0)) AS _gold_update_ts
        WHERE 1 = 0

    

),

changes AS (
    SELECT
        src.company_code,
        src.company_desc,

        CASE
            WHEN tgt.company_code IS NULL THEN CAST(SYSDATETIME() AS DATETIME2(6))
            ELSE tgt._gold_load_ts
        END AS _gold_load_ts,

        CASE
            WHEN tgt.company_code IS NULL THEN CAST(NULL AS DATETIME2(0))
            ELSE CAST(SYSDATETIME() AS DATETIME2(6))
        END AS _gold_update_ts

    FROM dedup AS src
    LEFT JOIN existing AS tgt
        ON src.company_code = tgt.company_code

    
)

SELECT *
FROM changes