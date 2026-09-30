use role ACCOUNTADMIN;
use warehouse RETENTION_COPILOT_WH;

create or replace dynamic table RETENTION_COPILOT.ANALYTICS.CUSTOMER_PROFILE
  target_lag = '1 day'
  warehouse = RETENTION_COPILOT_WH
as
with policy_summary as (
  select
    customer_id,
    count(*)                                                              as active_policies,
    sum(premium_monthly)                                                  as total_monthly_premium,
    count(distinct product_type)                                          as product_count,
    listagg(distinct product_type, ', ') within group (order by product_type) as products_held
  from RETENTION_COPILOT.RAW.POLICIES
  where start_date <= '2026-06-30'
    and (cancellation_date is null or cancellation_date > '2026-06-30')
  group by customer_id
),
active_customers as (
  select distinct customer_id
  from RETENTION_COPILOT.RAW.POLICIES
  where start_date <= '2026-06-30'
    and (cancellation_date is null or cancellation_date > '2026-06-30')
),
payment_summary as (
  select
    customer_id,
    count(*)                                                                              as payments_count,
    sum(case when status = 'Late'   then 1 else 0 end)                                   as late_payments,
    sum(case when status = 'Failed' then 1 else 0 end)                                   as failed_payments,
    case when count(*) > 0
      then sum(case when status in ('Late','Failed') then 1 else 0 end)::float / count(*)
      else null end                                                                        as late_or_failed_rate,
    avg(case when status = 'Late' then datediff('day', due_date, payment_date) else null end) as average_days_late
  from RETENTION_COPILOT.RAW.PAYMENTS
  where due_date >= '2026-01-01' and due_date <= '2026-06-30'
  group by customer_id
),
claim_summary as (
  select
    customer_id,
    count(*)                                                                                  as claims_count,
    sum(case when status = 'Open'     then 1 else 0 end)                                     as open_claims,
    sum(case when status = 'Rejected' then 1 else 0 end)                                     as rejected_claims,
    sum(claim_amount)                                                                         as total_claimed_amount,
    avg(case when resolution_date is not null
             then datediff('day', claim_date, resolution_date) else null end)                 as average_resolution_days
  from RETENTION_COPILOT.RAW.CLAIMS
  where claim_date >= '2026-01-01' and claim_date <= '2026-06-30'
  group by customer_id
),
ticket_summary as (
  select
    customer_id,
    count(*)                                                     as tickets_count,
    sum(case when status = 'Open'      then 1 else 0 end)        as open_tickets,
    sum(case when status = 'Escalated' then 1 else 0 end)        as escalated_tickets,
    avg(satisfaction_score)                                      as average_satisfaction,
    min(satisfaction_score)                                      as lowest_satisfaction
  from RETENTION_COPILOT.RAW.SERVICE_TICKETS
  where date(opened_at) >= '2026-01-01' and date(opened_at) <= '2026-06-30'
  group by customer_id
),
call_summary as (
  select
    customer_id,
    count(*)                                                                  as calls_count,
    avg(sentiment_score)                                                      as average_sentiment,
    min(sentiment_score)                                                      as lowest_sentiment,
    sum(case when sentiment_score < -0.3 then 1 else 0 end)                   as negative_calls,
    sum(case when competitor_mentioned is not null then 1 else 0 end)          as rival_mentions,
    sum(case when wants_to_cancel = true then 1 else 0 end)                   as cancel_intent_calls,
    max(date(call_at))                                                        as last_call_date
  from RETENTION_COPILOT.ANALYTICS.CALL_INSIGHTS
  where date(call_at) <= '2026-06-30'
  group by customer_id
)
select
  c.customer_id,
  c.first_name,
  c.last_name,
  c.email,
  c.phone,
  c.city,
  c.state,
  c.segment,
  c.customer_since,
  datediff('month', c.customer_since, date('2026-06-30'))           as tenure_months,
  case when active_customers.customer_id is not null then true else false end     as is_active_at_cutoff,
  coalesce(policy_summary.active_policies, 0)                                  as active_policies,
  coalesce(policy_summary.total_monthly_premium, 0)                            as total_monthly_premium,
  coalesce(policy_summary.product_count, 0)                                    as product_count,
  policy_summary.products_held,
  coalesce(payment_summary.payments_count, 0)                                   as payments_count,
  coalesce(payment_summary.late_payments, 0)                                    as late_payments,
  coalesce(payment_summary.failed_payments, 0)                                  as failed_payments,
  payment_summary.late_or_failed_rate,
  payment_summary.average_days_late,
  coalesce(claim_summary.claims_count, 0)                                     as claims_count,
  coalesce(claim_summary.open_claims, 0)                                      as open_claims,
  coalesce(claim_summary.rejected_claims, 0)                                  as rejected_claims,
  coalesce(claim_summary.total_claimed_amount, 0)                             as total_claimed_amount,
  claim_summary.average_resolution_days,
  coalesce(ticket_summary.tickets_count, 0)                                    as tickets_count,
  coalesce(ticket_summary.open_tickets, 0)                                     as open_tickets,
  coalesce(ticket_summary.escalated_tickets, 0)                                as escalated_tickets,
  ticket_summary.average_satisfaction,
  ticket_summary.lowest_satisfaction,
  coalesce(call_summary.calls_count, 0)                                      as calls_count,
  call_summary.average_sentiment,
  call_summary.lowest_sentiment,
  coalesce(call_summary.negative_calls, 0)                                   as negative_calls,
  coalesce(call_summary.rival_mentions, 0)                                   as rival_mentions,
  coalesce(call_summary.cancel_intent_calls, 0)                              as cancel_intent_calls,
  call_summary.last_call_date,
  case when call_summary.last_call_date is not null
       then datediff('day', call_summary.last_call_date, date('2026-06-30'))
       else null end                                                as days_since_last_call
from RETENTION_COPILOT.RAW.CUSTOMERS c
left join active_customers on c.customer_id = active_customers.customer_id
left join policy_summary on c.customer_id = policy_summary.customer_id
left join payment_summary on c.customer_id = payment_summary.customer_id
left join claim_summary on c.customer_id = claim_summary.customer_id
left join ticket_summary on c.customer_id = ticket_summary.customer_id
left join call_summary on c.customer_id = call_summary.customer_id;
