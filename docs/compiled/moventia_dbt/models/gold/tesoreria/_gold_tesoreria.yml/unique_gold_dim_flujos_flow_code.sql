
    
    

select
    flow_code as unique_field,
    count(*) as n_records

from [wh_gold].[finanzas].[dim_flujos_dbt]
where flow_code is not null
group by flow_code
having count(*) > 1


