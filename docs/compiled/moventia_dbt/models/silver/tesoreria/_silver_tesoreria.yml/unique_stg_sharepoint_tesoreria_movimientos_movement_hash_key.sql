
    
    

select
    movement_hash_key as unique_field,
    count(*) as n_records

from [wh_silver].[stg].[stg_sharepoint_tesoreria_movimientos]
where movement_hash_key is not null
group by movement_hash_key
having count(*) > 1


