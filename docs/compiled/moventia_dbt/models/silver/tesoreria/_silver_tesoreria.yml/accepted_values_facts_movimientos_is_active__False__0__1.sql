
    
    

with all_values as (

    select
        is_active as value_field,
        count(*) as n_records

    from [wh_silver].[finanzas].[facts_movimientos_dbt]
    group by is_active

)

select *
from all_values
where value_field not in (
    0,1
)


