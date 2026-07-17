
    
    



select last_seen_snapshot_date
from [wh_silver].[finanzas].[facts_movimientos_dbt]
where last_seen_snapshot_date is null


