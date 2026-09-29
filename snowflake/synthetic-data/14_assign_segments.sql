use role ACCOUNTADMIN;
use warehouse RETENTION_COPILOT_WH;

update RETENTION_COPILOT.RAW.CUSTOMERS c
set SEGMENT = seg.new_segment
from (
    with customer_metrics as (
        select
            p.CUSTOMER_ID,
            sum(p.PREMIUM_MONTHLY) as total_monthly_premium,
            datediff(month, c.CUSTOMER_SINCE, '2026-06-30') as tenure_months
        from RETENTION_COPILOT.RAW.POLICIES p
        join RETENTION_COPILOT.RAW.CUSTOMERS c on p.CUSTOMER_ID = c.CUSTOMER_ID
        group by p.CUSTOMER_ID, c.CUSTOMER_SINCE
    )
    select
        CUSTOMER_ID,
        case
            when total_monthly_premium >= 5000 and tenure_months >= 36 then 'Gold'
            when total_monthly_premium >= 2000 or tenure_months >= 60 then 'Silver'
            else 'Standard'
        end as new_segment
    from customer_metrics
) seg
where c.CUSTOMER_ID = seg.CUSTOMER_ID;
