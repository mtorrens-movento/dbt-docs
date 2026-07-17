SELECT
    movement_hash_key,
    COUNT(*) AS active_rows
FROM [wh_silver].[finanzas].[facts_movimientos_dbt]
WHERE is_active = 1
GROUP BY movement_hash_key
HAVING COUNT(*) > 1