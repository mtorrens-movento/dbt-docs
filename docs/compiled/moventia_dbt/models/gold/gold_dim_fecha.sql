

WITH src_current AS (

    SELECT movement_date AS fecha
    FROM [wh_silver].[finanzas].[facts_movimientos_dbt]
    WHERE movement_date IS NOT NULL

    UNION

    SELECT book_date AS fecha
    FROM [wh_silver].[finanzas].[facts_movimientos_dbt]
    WHERE book_date IS NOT NULL

),

src_hist AS (

    SELECT movement_date AS fecha
    FROM [wh_silver].[finanzas].[facts_movimientos_hist_dbt]
    WHERE movement_date IS NOT NULL

    UNION

    SELECT book_date AS fecha
    FROM [wh_silver].[finanzas].[facts_movimientos_hist_dbt]
    WHERE book_date IS NOT NULL

),

src_union AS (

    SELECT fecha FROM src_current

    UNION

    SELECT fecha FROM src_hist

),

dedup AS (

    SELECT DISTINCT
        fecha
    FROM src_union
    WHERE fecha IS NOT NULL

)

SELECT
    CONVERT(INT, CONVERT(CHAR(8), fecha, 112)) AS date_key,
    fecha,

    YEAR(fecha) AS anio,
    MONTH(fecha) AS mes,
    DAY(fecha) AS dia,

    YEAR(fecha) * 100 + MONTH(fecha) AS yyyymm,

    CASE MONTH(fecha)
        WHEN 1 THEN 'Enero'
        WHEN 2 THEN 'Febrero'
        WHEN 3 THEN 'Marzo'
        WHEN 4 THEN 'Abril'
        WHEN 5 THEN 'Mayo'
        WHEN 6 THEN 'Junio'
        WHEN 7 THEN 'Julio'
        WHEN 8 THEN 'Agosto'
        WHEN 9 THEN 'Septiembre'
        WHEN 10 THEN 'Octubre'
        WHEN 11 THEN 'Noviembre'
        WHEN 12 THEN 'Diciembre'
    END AS nombre_mes,

    DATEPART(QUARTER, fecha) AS trimestre,

    CAST(SYSDATETIME() AS DATETIME2(6)) AS _gold_load_ts

FROM dedup