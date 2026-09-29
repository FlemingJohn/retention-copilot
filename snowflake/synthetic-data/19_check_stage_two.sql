use role ACCOUNTADMIN;
use warehouse RETENTION_COPILOT_WH;

select '--- ROW COUNTS ---' as check_name;
select 'PAYMENTS' as tbl, count(*) as cnt, 60000 as target from RETENTION_COPILOT.RAW.PAYMENTS
union all
select 'CLAIMS', count(*), 1500 from RETENTION_COPILOT.RAW.CLAIMS
union all
select 'SERVICE_TICKETS', count(*), 4000 from RETENTION_COPILOT.RAW.SERVICE_TICKETS;

select '--- ORPHAN CHECKS ---' as check_name;
select 'payment_missing_policy' as check_type, count(*) as cnt
from RETENTION_COPILOT.RAW.PAYMENTS pay
left join RETENTION_COPILOT.RAW.POLICIES pol on pay.POLICY_ID = pol.POLICY_ID
where pol.POLICY_ID is null
union all
select 'payment_wrong_customer', count(*)
from RETENTION_COPILOT.RAW.PAYMENTS pay
join RETENTION_COPILOT.RAW.POLICIES pol on pay.POLICY_ID = pol.POLICY_ID
where pay.CUSTOMER_ID != pol.CUSTOMER_ID
union all
select 'claim_missing_policy', count(*)
from RETENTION_COPILOT.RAW.CLAIMS cl
left join RETENTION_COPILOT.RAW.POLICIES pol on cl.POLICY_ID = pol.POLICY_ID
where pol.POLICY_ID is null
union all
select 'claim_wrong_customer', count(*)
from RETENTION_COPILOT.RAW.CLAIMS cl
join RETENTION_COPILOT.RAW.POLICIES pol on cl.POLICY_ID = pol.POLICY_ID
where cl.CUSTOMER_ID != pol.CUSTOMER_ID
union all
select 'ticket_missing_customer', count(*)
from RETENTION_COPILOT.RAW.SERVICE_TICKETS t
left join RETENTION_COPILOT.RAW.CUSTOMERS c on t.CUSTOMER_ID = c.CUSTOMER_ID
where c.CUSTOMER_ID is null;

select '--- DATES AFTER CUTOFF ---' as check_name;
select 'payments_after_cutoff' as check_type, count(*) as cnt
from RETENTION_COPILOT.RAW.PAYMENTS where DUE_DATE > '2026-06-30' or PAYMENT_DATE > '2026-06-30'
union all
select 'claims_after_cutoff', count(*)
from RETENTION_COPILOT.RAW.CLAIMS where CLAIM_DATE > '2026-06-30' or RESOLUTION_DATE > '2026-06-30'
union all
select 'tickets_after_cutoff', count(*)
from RETENTION_COPILOT.RAW.SERVICE_TICKETS where OPENED_AT > '2026-06-30 23:59:59'::timestamp_ntz or RESOLVED_AT > '2026-06-30 23:59:59'::timestamp_ntz;

select '--- EVENTS AFTER PRE-CUTOFF CANCELLATION ---' as check_name;
select 'payments_after_cancel' as check_type, count(*) as cnt
from RETENTION_COPILOT.RAW.PAYMENTS pay
join RETENTION_COPILOT.RAW.POLICIES pol on pay.POLICY_ID = pol.POLICY_ID
where pol.CANCELLATION_DATE is not null
  and pol.CANCELLATION_DATE <= '2026-06-30'
  and pay.DUE_DATE > pol.CANCELLATION_DATE
union all
select 'claims_after_cancel', count(*)
from RETENTION_COPILOT.RAW.CLAIMS cl
join RETENTION_COPILOT.RAW.POLICIES pol on cl.POLICY_ID = pol.POLICY_ID
where pol.CANCELLATION_DATE is not null
  and pol.CANCELLATION_DATE <= '2026-06-30'
  and cl.CLAIM_DATE > pol.CANCELLATION_DATE
union all
select 'tickets_after_all_cancel', count(*)
from RETENTION_COPILOT.RAW.SERVICE_TICKETS t
where not exists (
    select 1 from RETENTION_COPILOT.RAW.POLICIES p
    where p.CUSTOMER_ID = t.CUSTOMER_ID
      and p.START_DATE <= t.OPENED_AT::date
      and (p.CANCELLATION_DATE is null
           or p.CANCELLATION_DATE > '2026-06-30'
           or p.CANCELLATION_DATE >= t.OPENED_AT::date)
);

select '--- PAYMENTS BEFORE POLICY START ---' as check_name;
select count(*) as payments_before_start
from RETENTION_COPILOT.RAW.PAYMENTS pay
join RETENTION_COPILOT.RAW.POLICIES pol on pay.POLICY_ID = pol.POLICY_ID
where pay.DUE_DATE < pol.START_DATE;

select '--- LATE+FAILED RATE BY MOOD GROUP ---' as check_name;
select
    case when m.MOOD < 0.3 then 'low_mood' else 'high_mood' end as mood_group,
    count(*) as total_payments,
    round(100.0 * sum(case when pay.STATUS in ('Late','Failed') then 1 else 0 end) / count(*), 2) as late_failed_pct
from RETENTION_COPILOT.RAW.PAYMENTS pay
join RETENTION_COPILOT.GENERATOR.CUSTOMER_MOOD m on pay.CUSTOMER_ID = m.CUSTOMER_ID
where m.MOOD < 0.3 or m.MOOD > 0.7
group by case when m.MOOD < 0.3 then 'low_mood' else 'high_mood' end
order by mood_group;

select '--- AVG TICKETS AND SATISFACTION BY MOOD GROUP ---' as check_name;
with ticket_counts as (
    select
        t.CUSTOMER_ID,
        m.MOOD,
        count(*) as ticket_cnt,
        avg(t.SATISFACTION_SCORE) as avg_sat
    from RETENTION_COPILOT.RAW.SERVICE_TICKETS t
    join RETENTION_COPILOT.GENERATOR.CUSTOMER_MOOD m on t.CUSTOMER_ID = m.CUSTOMER_ID
    group by t.CUSTOMER_ID, m.MOOD
)
select
    case when MOOD < 0.3 then 'low_mood' else 'high_mood' end as mood_group,
    round(avg(ticket_cnt), 2) as avg_tickets,
    round(avg(avg_sat), 2) as avg_satisfaction
from ticket_counts
where MOOD < 0.3 or MOOD > 0.7
group by case when MOOD < 0.3 then 'low_mood' else 'high_mood' end
order by mood_group;

select '--- CLAIMS PER POLICY BY MOOD GROUP ---' as check_name;
with policy_claims as (
    select
        p.POLICY_ID,
        m.MOOD,
        count(cl.CLAIM_ID) as claim_cnt
    from RETENTION_COPILOT.RAW.POLICIES p
    join RETENTION_COPILOT.GENERATOR.CUSTOMER_MOOD m on p.CUSTOMER_ID = m.CUSTOMER_ID
    left join RETENTION_COPILOT.RAW.CLAIMS cl on p.POLICY_ID = cl.POLICY_ID
    where m.MOOD < 0.3 or m.MOOD > 0.7
    group by p.POLICY_ID, m.MOOD
)
select
    case when MOOD < 0.3 then 'low_mood' else 'high_mood' end as mood_group,
    round(avg(claim_cnt), 4) as claims_per_policy
from policy_claims
group by case when MOOD < 0.3 then 'low_mood' else 'high_mood' end
order by mood_group;

select '--- MISSING SATISFACTION PERCENTAGE ---' as check_name;
select
    round(100.0 * sum(case when SATISFACTION_SCORE is null and STATUS = 'Resolved' then 1 else 0 end)
        / nullif(sum(case when STATUS = 'Resolved' then 1 else 0 end), 0), 2) as missing_sat_pct
from RETENTION_COPILOT.RAW.SERVICE_TICKETS;

select '--- SPIKE WEEK VS NORMAL WEEK ---' as check_name;
with weekly as (
    select
        case when OPENED_AT::date between '2026-05-11' and '2026-05-17' then 'spike' else 'normal' end as week_type,
        count(*) as cnt
    from RETENTION_COPILOT.RAW.SERVICE_TICKETS
    group by week_type
)
select
    week_type,
    cnt,
    case
        when week_type = 'normal' then round(cnt / 25.0, 1)
        else cnt * 1.0
    end as per_week
from weekly
order by week_type;
