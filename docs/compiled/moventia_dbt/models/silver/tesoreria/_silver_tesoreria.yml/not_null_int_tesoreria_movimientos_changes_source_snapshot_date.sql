
    
    



select source_snapshot_date
from [wh_silver].[stg].[int_tesoreria_movimientos_changes]
where source_snapshot_date is null


