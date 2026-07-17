
    
    

select
    date_key as unique_field,
    count(*) as n_records

from [wh_gold].[finanzas].[dim_fecha_dbt]
where date_key is not null
group by date_key
having count(*) > 1


