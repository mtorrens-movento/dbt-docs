
    
    

with all_values as (

    select
        es_actual as value_field,
        count(*) as n_records

    from [wh_silver].[finanzas].[dim_bancos_dbt]
    group by es_actual

)

select *
from all_values
where value_field not in (
    0,1
)


