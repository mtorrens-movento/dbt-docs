
    
    

select
    hist_version_key as unique_field,
    count(*) as n_records

from [wh_silver].[finanzas].[facts_movimientos_hist_dbt]
where hist_version_key is not null
group by hist_version_key
having count(*) > 1


