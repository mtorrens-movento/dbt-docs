SELECT
    hist_version_key,
    hist_valid_from,
    hist_valid_to
FROM [wh_silver].[finanzas].[facts_movimientos_hist_dbt]
WHERE hist_valid_to < hist_valid_from