SELECT
    bank_code,
    COUNT(*) AS current_rows
FROM [wh_silver].[finanzas].[dim_bancos_dbt]
WHERE es_actual = 1
GROUP BY bank_code
HAVING COUNT(*) > 1