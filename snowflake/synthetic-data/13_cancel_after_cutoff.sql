use role ACCOUNTADMIN;
use warehouse RETENTION_COPILOT_WH;

update RETENTION_COPILOT.RAW.POLICIES p
set
    CANCELLATION_DATE = churn.cancel_date,
    CANCELLATION_REASON = churn.cancel_reason
from (
    with active_customers as (
        select distinct
            c.CUSTOMER_ID,
            m.MOOD,
            datediff(day, c.CUSTOMER_SINCE, '2026-06-30') as tenure_days
        from RETENTION_COPILOT.RAW.CUSTOMERS c
        join RETENTION_COPILOT.GENERATOR.CUSTOMER_MOOD m on c.CUSTOMER_ID = m.CUSTOMER_ID
        where c.CUSTOMER_ID not in (
            select distinct CUSTOMER_ID
            from RETENTION_COPILOT.RAW.POLICIES
            where CANCELLATION_DATE is not null
        )
    ),
    coin_flip as (
        select
            CUSTOMER_ID,
            MOOD,
            0.08
            + MOOD * 0.40
            + (1.0 - least(tenure_days / 3650.0, 1.0)) * 0.05
            as churn_prob,
            abs(hash(CUSTOMER_ID, 301)) % 10000 / 10000.0 as coin
        from active_customers
    ),
    post_churners as (
        select
            CUSTOMER_ID,
            dateadd(day,
                abs(hash(CUSTOMER_ID, 211)) % 90,
                '2026-07-01') as cancel_date,
            case abs(hash(CUSTOMER_ID, 221)) % 6
                when 0 then 'Found better premium elsewhere'
                when 1 then 'Financial difficulties'
                when 2 then 'Unhappy with claim settlement'
                when 3 then 'Policy no longer needed'
                when 4 then 'Switching to competitor'
                when 5 then 'Poor customer service experience'
            end as cancel_reason
        from coin_flip
        where coin < churn_prob
    )
    select CUSTOMER_ID, cancel_date, cancel_reason
    from post_churners
) churn
where p.CUSTOMER_ID = churn.CUSTOMER_ID
  and p.CANCELLATION_DATE is null;
