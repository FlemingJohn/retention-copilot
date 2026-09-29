use role ACCOUNTADMIN;
use warehouse RETENTION_COPILOT_WH;

update RETENTION_COPILOT.RAW.POLICIES p
set
    CANCELLATION_DATE = cancel_info.cancel_date,
    CANCELLATION_REASON = cancel_info.cancel_reason
from (
    with candidates as (
        select distinct
            c.CUSTOMER_ID,
            m.MOOD,
            abs(hash(c.CUSTOMER_ID, 101)) % 1000 as churn_roll
        from RETENTION_COPILOT.RAW.CUSTOMERS c
        join RETENTION_COPILOT.GENERATOR.CUSTOMER_MOOD m on c.CUSTOMER_ID = m.CUSTOMER_ID
    ),
    pre_churners as (
        select
            CUSTOMER_ID,
            MOOD,
            case
                when abs(hash(CUSTOMER_ID, 111)) % 100 < 9
                then dateadd(day, abs(hash(CUSTOMER_ID, 121)) % 7, '2026-05-11')
                else dateadd(day,
                    abs(hash(CUSTOMER_ID, 131)) % 181,
                    '2026-01-01')
            end as cancel_date,
            case abs(hash(CUSTOMER_ID, 141)) % 6
                when 0 then 'Found better premium elsewhere'
                when 1 then 'Financial difficulties'
                when 2 then 'Unhappy with claim settlement'
                when 3 then 'Policy no longer needed'
                when 4 then 'Premium too expensive after increase'
                when 5 then 'Poor customer service experience'
            end as cancel_reason
        from candidates
        where churn_roll < 80
    )
    select CUSTOMER_ID, cancel_date, cancel_reason
    from pre_churners
) cancel_info
where p.CUSTOMER_ID = cancel_info.CUSTOMER_ID
  and p.START_DATE <= cancel_info.cancel_date;
