use role ACCOUNTADMIN;
use warehouse RETENTION_COPILOT_WH;

create or replace table RETENTION_COPILOT.ANALYTICS.CHURN_LABELS as
select
  cp.customer_id,
  case when exists (
    select 1
    from RETENTION_COPILOT.RAW.POLICIES p
    where p.customer_id = cp.customer_id
      and p.cancellation_date >= '2026-07-01'
      and p.cancellation_date <= '2026-09-28'
  ) then true else false end as churned_within_90_days
from RETENTION_COPILOT.ANALYTICS.CUSTOMER_PROFILE cp
where cp.is_active_at_cutoff = true;
