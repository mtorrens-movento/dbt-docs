SELECT
    flow_code,
    COUNT(*) AS current_rows
FROM [wh_silver].[finanzas].[dim_flujos_dbt]
WHERE es_actual = 1
GROUP BY flow_code
HAVING COUNT(*) > 1