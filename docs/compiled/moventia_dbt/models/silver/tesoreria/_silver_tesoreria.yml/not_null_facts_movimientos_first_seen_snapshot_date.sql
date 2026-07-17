
    
    



select first_seen_snapshot_date
from [wh_silver].[finanzas].[facts_movimientos_dbt]
where first_seen_snapshot_date is null


