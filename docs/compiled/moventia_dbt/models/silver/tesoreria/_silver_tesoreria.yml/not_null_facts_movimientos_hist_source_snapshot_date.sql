
    
    



select source_snapshot_date
from [wh_silver].[finanzas].[facts_movimientos_hist_dbt]
where source_snapshot_date is null


