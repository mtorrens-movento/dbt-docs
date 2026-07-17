

WITH

silver_source AS (
    SELECT
        flow_code,
        flow_desc
    FROM [wh_silver].[finanzas].[dim_flujos_dbt]
    WHERE es_actual = 1
),

existing AS (

    

        SELECT
            CAST(NULL AS VARCHAR(50)) AS flow_code,
            CAST(NULL AS VARCHAR(255)) AS flow_desc,
            CAST(NULL AS DATETIME2(0)) AS _gold_load_ts,
            CAST(NULL AS DATETIME2(0)) AS _gold_update_ts
        WHERE 1 = 0

    

),

changes AS (
    SELECT
        src.flow_code,
        src.flow_desc,

        CASE
            WHEN tgt.flow_code IS NULL THEN CAST(SYSDATETIME() AS DATETIME2(6))
            ELSE tgt._gold_load_ts
        END AS _gold_load_ts,

        CASE
            WHEN tgt.flow_code IS NULL THEN CAST(NULL AS DATETIME2(0))
            ELSE CAST(SYSDATETIME() AS DATETIME2(6))
        END AS _gold_update_ts

    FROM silver_source AS src
    LEFT JOIN existing AS tgt
        ON src.flow_code = tgt.flow_code

    
)

SELECT *
FROM changes