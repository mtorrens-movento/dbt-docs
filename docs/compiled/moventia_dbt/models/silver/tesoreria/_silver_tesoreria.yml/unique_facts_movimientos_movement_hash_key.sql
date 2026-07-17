
    
    

select
    movement_hash_key as unique_field,
    count(*) as n_records

from [wh_silver].[finanzas].[facts_movimientos_dbt]
where movement_hash_key is not null
group by movement_hash_key
having count(*) > 1


