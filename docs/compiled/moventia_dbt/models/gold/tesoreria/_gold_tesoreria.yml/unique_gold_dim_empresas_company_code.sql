
    
    

select
    company_code as unique_field,
    count(*) as n_records

from [wh_gold].[finanzas].[dim_empresas_dbt]
where company_code is not null
group by company_code
having count(*) > 1


