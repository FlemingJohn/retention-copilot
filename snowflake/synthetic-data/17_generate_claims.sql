use role ACCOUNTADMIN;
use warehouse RETENTION_COPILOT_WH;

truncate table RETENTION_COPILOT.RAW.CLAIMS;

insert into RETENTION_COPILOT.RAW.CLAIMS
    (CLAIM_ID, POLICY_ID, CUSTOMER_ID, CLAIM_DATE, CLAIM_TYPE, CLAIM_AMOUNT, SETTLEMENT_AMOUNT, STATUS, RESOLUTION_DATE)
with eligible as (
    select
        p.POLICY_ID,
        p.CUSTOMER_ID,
        p.PRODUCT_TYPE,
        p.COVERAGE_AMOUNT,
        m.MOOD,
        greatest(p.START_DATE, '2026-01-01'::date) as window_start,
        case
            when p.CANCELLATION_DATE is not null and p.CANCELLATION_DATE <= '2026-06-30'
            then p.CANCELLATION_DATE
            else '2026-06-30'::date
        end as window_end
    from RETENTION_COPILOT.RAW.POLICIES p
    join RETENTION_COPILOT.GENERATOR.CUSTOMER_MOOD m on p.CUSTOMER_ID = m.CUSTOMER_ID
    where greatest(p.START_DATE, '2026-01-01'::date) <
          case when p.CANCELLATION_DATE is not null and p.CANCELLATION_DATE <= '2026-06-30'
               then p.CANCELLATION_DATE else '2026-06-30'::date end
),
month_seq as (
    select row_number() over (order by seq4()) - 1 as n
    from table(generator(rowcount => 6))
),
policy_months as (
    select
        e.POLICY_ID,
        e.CUSTOMER_ID,
        e.PRODUCT_TYPE,
        e.COVERAGE_AMOUNT,
        e.MOOD,
        e.window_start,
        e.window_end,
        dateadd(month, ms.n, '2026-01-01'::date) as month_start,
        least(dateadd(month, ms.n + 1, '2026-01-01'::date), e.window_end) as month_end
    from eligible e
    cross join month_seq ms
    where dateadd(month, ms.n, '2026-01-01'::date) < e.window_end
      and dateadd(month, ms.n, '2026-01-01'::date) >= e.window_start
),
with_roll as (
    select
        pm.*,
        abs(hash(POLICY_ID, month_start, 601)) % 1000 / 1000.0 as claim_roll,
        0.034 + 0.010 * MOOD as claim_prob
    from policy_months pm
),
claimants as (
    select * from with_roll where claim_roll < claim_prob
),
with_dates as (
    select
        c.*,
        dateadd(day,
            abs(hash(POLICY_ID, month_start, 611)) % greatest(1, datediff(day, month_start, month_end)),
            month_start
        ) as CLAIM_DATE,
        case PRODUCT_TYPE
            when 'Motor' then
                case abs(hash(POLICY_ID, month_start, 621)) % 3 when 0 then 'Accident' when 1 then 'Theft' else 'Third Party' end
            when 'Health' then
                case abs(hash(POLICY_ID, month_start, 621)) % 3 when 0 then 'Hospitalisation' when 1 then 'Surgery' else 'Outpatient' end
            when 'Home' then
                case abs(hash(POLICY_ID, month_start, 621)) % 3 when 0 then 'Damage' when 1 then 'Theft' else 'Natural Disaster' end
            when 'Travel' then
                case abs(hash(POLICY_ID, month_start, 621)) % 3 when 0 then 'Trip Cancellation' when 1 then 'Medical Emergency' else 'Lost Baggage' end
            when 'Life' then
                case abs(hash(POLICY_ID, month_start, 621)) % 3 when 0 then 'Maturity' when 1 then 'Death Benefit' else 'Critical Illness' end
        end as CLAIM_TYPE,
        round(
            least(
                COVERAGE_AMOUNT,
                case PRODUCT_TYPE
                    when 'Motor' then 1500000
                    when 'Health' then 2000000
                    when 'Home' then 5000000
                    when 'Travel' then 300000
                    else 10000000
                end,
                pow(10, uniform(0.0, 1.0, random())) * COVERAGE_AMOUNT * uniform(0.01, 0.15, random())
            ),
            2
        ) as CLAIM_AMOUNT
    from claimants c
),
with_status as (
    select
        wd.*,
        abs(hash(POLICY_ID, CLAIM_DATE, 631)) % 100 as status_roll,
        dateadd(day, 7 + abs(hash(POLICY_ID, CLAIM_DATE, 641)) % 54, CLAIM_DATE) as raw_resolution
    from with_dates wd
),
with_final_status as (
    select
        ws.*,
        case
            when raw_resolution > '2026-06-30'::date then 'Open'
            when status_roll < 45 then 'Settled'
            when status_roll < 70 then 'Approved'
            when status_roll < 90 then 'Rejected'
            else 'Open'
        end as STATUS,
        case
            when raw_resolution > '2026-06-30'::date then null
            when status_roll < 90 then raw_resolution
            else null
        end as RESOLUTION_DATE,
        case
            when raw_resolution <= '2026-06-30'::date and status_roll < 45
            then round(CLAIM_AMOUNT * (0.6 + uniform(0.0, 0.4, random())), 2)
            else null
        end as SETTLEMENT_AMOUNT
    from with_status ws
),
numbered as (
    select
        wfs.*,
        row_number() over (order by CUSTOMER_ID, POLICY_ID, CLAIM_DATE) as rn
    from with_final_status wfs
)
select
    'CLM' || lpad(rn::varchar, 6, '0') as CLAIM_ID,
    POLICY_ID,
    CUSTOMER_ID,
    CLAIM_DATE,
    CLAIM_TYPE,
    CLAIM_AMOUNT,
    SETTLEMENT_AMOUNT,
    STATUS,
    RESOLUTION_DATE
from numbered;
