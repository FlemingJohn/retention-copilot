use role ACCOUNTADMIN;
use warehouse RETENTION_COPILOT_WH;

create or replace table RETENTION_COPILOT.ANALYTICS.CHURN_SPLIT as
with ranked as (
    select
        CUSTOMER_ID,
        CHURNED_WITHIN_90_DAYS,
        row_number() over (
            partition by CHURNED_WITHIN_90_DAYS
            order by hash(CUSTOMER_ID)
        ) as rn,
        count(*) over (partition by CHURNED_WITHIN_90_DAYS) as group_size
    from RETENTION_COPILOT.ANALYTICS.CHURN_LABELS
)
select
    CUSTOMER_ID,
    case when rn <= floor(0.7 * group_size) then 'train' else 'test' end as SPLIT
from ranked;
