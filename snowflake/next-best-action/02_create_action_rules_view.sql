create or replace view RETENTION_COPILOT.ANALYTICS.ACTION_CANDIDATES as
with base as (
    select
        cp.CUSTOMER_ID,
        cp.FIRST_NAME,
        cp.CITY,
        cs.RISK_TIER,
        cs.CHURN_PROBABILITY,
        cs.TOP_DRIVER_1,
        cs.TOP_DRIVER_2,
        cs.TOP_DRIVER_3,
        cp.TOTAL_MONTHLY_PREMIUM,
        cp.LATE_PAYMENTS,
        cp.FAILED_PAYMENTS,
        cp.LATE_OR_FAILED_RATE,
        cp.TICKETS_COUNT,
        cp.OPEN_TICKETS,
        cp.ESCALATED_TICKETS,
        cp.CLAIMS_COUNT,
        cp.OPEN_CLAIMS,
        cp.REJECTED_CLAIMS,
        cp.AVERAGE_SATISFACTION,
        cp.AVERAGE_SENTIMENT,
        cp.CALLS_COUNT,
        cp.NEGATIVE_CALLS,
        cp.RIVAL_MENTIONS,
        cp.CANCEL_INTENT_CALLS,
        case
            when coalesce(cp.RIVAL_MENTIONS, 0) > 0
              or coalesce(cp.CANCEL_INTENT_CALLS, 0) > 0
                then 'Retention offer callback'
            when coalesce(cp.ESCALATED_TICKETS, 0) > 0
              or coalesce(cp.OPEN_TICKETS, 0) > 0
                then 'Escalate open ticket'
            when coalesce(cp.REJECTED_CLAIMS, 0) > 0
              or coalesce(cp.OPEN_CLAIMS, 0) > 0
                then 'Claims follow-up call'
            when coalesce(cp.FAILED_PAYMENTS, 0) >= 2
              or coalesce(cp.LATE_OR_FAILED_RATE, 0) >= 0.3
                then 'Payment plan offer'
            when coalesce(cp.AVERAGE_SENTIMENT, 0) < -0.3
              or coalesce(cp.AVERAGE_SATISFACTION, 5) <= 2.5
                then 'Service recovery call'
            else 'Loyalty check-in'
        end as ACTION_TYPE,
        case
            when coalesce(cp.RIVAL_MENTIONS, 0) > 0
              or coalesce(cp.CANCEL_INTENT_CALLS, 0) > 0
                then 'Phone'
            when coalesce(cp.ESCALATED_TICKETS, 0) > 0
              or coalesce(cp.OPEN_TICKETS, 0) > 0
                then 'Phone'
            when coalesce(cp.REJECTED_CLAIMS, 0) > 0
              or coalesce(cp.OPEN_CLAIMS, 0) > 0
                then 'Phone'
            when coalesce(cp.FAILED_PAYMENTS, 0) >= 2
              or coalesce(cp.LATE_OR_FAILED_RATE, 0) >= 0.3
                then 'Email'
            when coalesce(cp.AVERAGE_SENTIMENT, 0) < -0.3
              or coalesce(cp.AVERAGE_SATISFACTION, 5) <= 2.5
                then 'Phone'
            else 'Email'
        end as CHANNEL,
        (
            case when coalesce(cp.LATE_PAYMENTS, 0) + coalesce(cp.FAILED_PAYMENTS, 0) > 0 then 1 else 0 end +
            case when coalesce(cp.TICKETS_COUNT, 0) > 0 then 1 else 0 end +
            case when coalesce(cp.OPEN_CLAIMS, 0) + coalesce(cp.REJECTED_CLAIMS, 0) > 0 then 1 else 0 end +
            case when coalesce(cp.NEGATIVE_CALLS, 0) > 0
                   or coalesce(cp.RIVAL_MENTIONS, 0) > 0
                   or coalesce(cp.CANCEL_INTENT_CALLS, 0) > 0 then 1 else 0 end
        ) as SIGNAL_GROUPS,
        cs.CHURN_PROBABILITY * coalesce(cp.TOTAL_MONTHLY_PREMIUM, 0) * 12 as REVENUE_AT_RISK
    from RETENTION_COPILOT.ANALYTICS.CHURN_SCORES cs
    join RETENTION_COPILOT.ANALYTICS.CUSTOMER_PROFILE cp
        on cs.CUSTOMER_ID = cp.CUSTOMER_ID
    where cs.RISK_TIER in ('High', 'Medium')
),
ranked as (
    select
        b.*,
        case
            when b.ACTION_TYPE = 'Loyalty check-in' then 'Low'
            when b.SIGNAL_GROUPS >= 3 then 'High'
            when b.SIGNAL_GROUPS = 2 then 'Medium'
            else 'Low'
        end as CONFIDENCE,
        rank() over (order by b.REVENUE_AT_RISK desc) as PRIORITY_RANK,
        case b.ACTION_TYPE
            when 'Retention offer callback' then 'rival insurer or cancellation intent on a call'
            when 'Escalate open ticket' then 'open or escalated service ticket'
            when 'Claims follow-up call' then 'open or rejected claim'
            when 'Payment plan offer' then 'repeated failed or late payments'
            when 'Service recovery call' then 'very negative calls or low satisfaction'
            else 'no single trigger, general risk'
        end as ACTION_TRIGGER,
        'Churn risk ' || round(b.CHURN_PROBABILITY * 100)::varchar || '% (' || b.RISK_TIER || ')' ||
        '. Action trigger: ' || ACTION_TRIGGER ||
        iff(
            array_to_string(array_compact(array_construct(
                nullif(b.TOP_DRIVER_1, ''), nullif(b.TOP_DRIVER_2, ''), nullif(b.TOP_DRIVER_3, '')
            )), '; ') = '',
            '',
            '. Top signals: ' || array_to_string(array_compact(array_construct(
                nullif(b.TOP_DRIVER_1, ''), nullif(b.TOP_DRIVER_2, ''), nullif(b.TOP_DRIVER_3, '')
            )), '; ')
        ) as REASON
    from base b
)
select
    r.CUSTOMER_ID,
    r.FIRST_NAME,
    r.CITY,
    r.RISK_TIER,
    r.CHURN_PROBABILITY,
    r.TOP_DRIVER_1,
    r.TOP_DRIVER_2,
    r.TOP_DRIVER_3,
    r.ACTION_TYPE,
    r.CHANNEL,
    r.SIGNAL_GROUPS,
    r.CONFIDENCE,
    case when r.CONFIDENCE = 'Low' then 'Needs review' else 'Pending' end as STATUS,
    r.REASON,
    r.REVENUE_AT_RISK,
    r.PRIORITY_RANK,
    r.TOTAL_MONTHLY_PREMIUM,
    r.LATE_PAYMENTS,
    r.FAILED_PAYMENTS,
    r.LATE_OR_FAILED_RATE,
    r.TICKETS_COUNT,
    r.OPEN_TICKETS,
    r.ESCALATED_TICKETS,
    r.CLAIMS_COUNT,
    r.OPEN_CLAIMS,
    r.REJECTED_CLAIMS,
    r.AVERAGE_SATISFACTION,
    r.AVERAGE_SENTIMENT,
    r.CALLS_COUNT,
    r.NEGATIVE_CALLS,
    r.RIVAL_MENTIONS,
    r.CANCEL_INTENT_CALLS
from ranked r;
