
    
    

with all_values as (

    select
        change_type as value_field,
        count(*) as n_records

    from [wh_silver].[stg].[int_tesoreria_movimientos_changes]
    group by change_type

)

select *
from all_values
where value_field not in (
    'NEW','CHANGED'
)


