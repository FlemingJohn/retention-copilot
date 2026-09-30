use role ACCOUNTADMIN;
use warehouse RETENTION_COPILOT_WH;

select count(*) as total_rows from RETENTION_COPILOT.ANALYTICS.CUSTOMER_PROFILE;

select count(*) as null_customer_id from RETENTION_COPILOT.ANALYTICS.CUSTOMER_PROFILE where customer_id is null;

select count(*) as duplicate_customer_id
from (select customer_id from RETENTION_COPILOT.ANALYTICS.CUSTOMER_PROFILE group by customer_id having count(*) > 1);

select is_active_at_cutoff, count(*) as customers
from RETENTION_COPILOT.ANALYTICS.CUSTOMER_PROFILE
group by is_active_at_cutoff;

select count(*) as churn_label_rows from RETENTION_COPILOT.ANALYTICS.CHURN_LABELS;

select
  round(100.0 * sum(case when churned_within_90_days then 1 else 0 end) / count(*), 2) as churn_rate_pct
from RETENTION_COPILOT.ANALYTICS.CHURN_LABELS;

select max(last_call_date) as latest_call_date from RETENTION_COPILOT.ANALYTICS.CUSTOMER_PROFILE;

select count(*) as negative_tenure from RETENTION_COPILOT.ANALYTICS.CUSTOMER_PROFILE where tenure_months < 0;

select
  sum(case when tenure_months              is null then 1 else 0 end) as null_tenure_months,
  sum(case when total_monthly_premium      is null then 1 else 0 end) as null_total_monthly_premium,
  sum(case when payments_count             is null then 1 else 0 end) as null_payments_count,
  sum(case when late_or_failed_rate        is null then 1 else 0 end) as null_late_or_failed_rate,
  sum(case when average_days_late          is null then 1 else 0 end) as null_average_days_late,
  sum(case when claims_count               is null then 1 else 0 end) as null_claims_count,
  sum(case when average_resolution_days    is null then 1 else 0 end) as null_average_resolution_days,
  sum(case when tickets_count              is null then 1 else 0 end) as null_tickets_count,
  sum(case when average_satisfaction       is null then 1 else 0 end) as null_average_satisfaction,
  sum(case when lowest_satisfaction        is null then 1 else 0 end) as null_lowest_satisfaction,
  sum(case when calls_count                is null then 1 else 0 end) as null_calls_count,
  sum(case when average_sentiment          is null then 1 else 0 end) as null_average_sentiment,
  sum(case when days_since_last_call       is null then 1 else 0 end) as null_days_since_last_call
from RETENTION_COPILOT.ANALYTICS.CUSTOMER_PROFILE;

select
  cl.churned_within_90_days,
  round(avg(cp.late_or_failed_rate), 4)      as avg_late_or_failed_rate,
  round(avg(cp.average_sentiment), 4)        as avg_sentiment,
  round(avg(cp.tickets_count), 2)            as avg_tickets,
  round(avg(cp.average_satisfaction), 4)     as avg_satisfaction,
  round(avg(cp.rival_mentions), 4)           as avg_rival_mentions,
  round(avg(cp.cancel_intent_calls), 4)      as avg_cancel_intent,
  round(avg(cp.total_monthly_premium), 2)    as avg_premium
from RETENTION_COPILOT.ANALYTICS.CHURN_LABELS cl
join RETENTION_COPILOT.ANALYTICS.CUSTOMER_PROFILE cp on cl.customer_id = cp.customer_id
group by cl.churned_within_90_days;

select
  cp.first_name, cp.last_name, cp.city, cp.segment,
  cp.active_policies, cp.total_monthly_premium, cp.late_or_failed_rate,
  cp.calls_count, cp.average_sentiment, cp.cancel_intent_calls,
  cp.tickets_count, cp.rival_mentions
from RETENTION_COPILOT.ANALYTICS.CUSTOMER_PROFILE cp
limit 3;

show dynamic tables like 'CUSTOMER_PROFILE' in schema RETENTION_COPILOT.ANALYTICS;
