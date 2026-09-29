use role ACCOUNTADMIN;
use warehouse RETENTION_COPILOT_WH;

truncate table RETENTION_COPILOT.RAW.PAYMENTS;

insert into RETENTION_COPILOT.RAW.PAYMENTS
    (PAYMENT_ID, POLICY_ID, CUSTOMER_ID, DUE_DATE, PAYMENT_DATE, AMOUNT, PAYMENT_METHOD, STATUS)
with policy_months as (
    select
        p.POLICY_ID,
        p.CUSTOMER_ID,
        p.PREMIUM_MONTHLY,
        p.START_DATE,
        p.CANCELLATION_DATE,
        m.MOOD,
        greatest(p.START_DATE, '2025-10-01'::date) as first_due,
        case
            when p.CANCELLATION_DATE is not null and p.CANCELLATION_DATE <= '2026-06-30'
            then p.CANCELLATION_DATE
            else '2026-06-30'::date
        end as last_possible
    from RETENTION_COPILOT.RAW.POLICIES p
    join RETENTION_COPILOT.GENERATOR.CUSTOMER_MOOD m on p.CUSTOMER_ID = m.CUSTOMER_ID
),
month_seq as (
    select row_number() over (order by seq4()) - 1 as n
    from table(generator(rowcount => 12))
),
due_dates as (
    select
        pm.POLICY_ID,
        pm.CUSTOMER_ID,
        pm.PREMIUM_MONTHLY,
        pm.MOOD,
        pm.START_DATE,
        pm.last_possible,
        dateadd(month, ms.n,
            date_from_parts(
                year(pm.first_due),
                month(pm.first_due),
                least(day(pm.START_DATE), dayofmonth(last_day(pm.first_due)))
            )
        ) as raw_due,
        least(day(pm.START_DATE),
              dayofmonth(last_day(
                  dateadd(month, ms.n, pm.first_due)
              ))) as target_day
    from policy_months pm
    cross join month_seq ms
    where dateadd(month, ms.n, pm.first_due) <= pm.last_possible
),
aligned as (
    select
        POLICY_ID,
        CUSTOMER_ID,
        PREMIUM_MONTHLY,
        MOOD,
        START_DATE,
        last_possible,
        date_from_parts(year(raw_due), month(raw_due), target_day) as DUE_DATE
    from due_dates
),
filtered as (
    select *
    from aligned
    where DUE_DATE >= START_DATE
      and DUE_DATE <= last_possible
),
with_method as (
    select
        f.*,
        case abs(hash(POLICY_ID, 201)) % 4
            when 0 then 'UPI'
            when 1 then 'Card'
            when 2 then 'NetBanking'
            when 3 then 'AutoDebit'
        end as PAYMENT_METHOD
    from filtered f
),
noise_flags as (
    select
        wm.*,
        abs(hash(CUSTOMER_ID, 301)) % 100 < 10 and MOOD > 0.7 as is_calm_high_mood,
        abs(hash(CUSTOMER_ID, 311)) % 100 < 5  and MOOD < 0.3 as is_messy_low_mood
    from with_method wm
),
payment_rolls as (
    select
        nf.*,
        abs(hash(POLICY_ID, DUE_DATE, 401)) % 1000 / 1000.0 as roll,
        0.02 + 0.10 * MOOD as base_fail_rate,
        (0.04 + 0.30 * MOOD) * case when PAYMENT_METHOD = 'AutoDebit' then 0.4 else 1.0 end as base_late_rate
    from noise_flags nf
),
with_status as (
    select
        pr.*,
        case
            when is_calm_high_mood then
                case when roll < 0.005 then 'Failed'
                     else 'Paid' end
            when is_messy_low_mood then
                case when roll < base_fail_rate then 'Failed'
                     when roll < base_fail_rate + greatest(base_late_rate, 0.15) then 'Late'
                     else 'Paid' end
            else
                case when roll < base_fail_rate then 'Failed'
                     when roll < base_fail_rate + base_late_rate then 'Late'
                     else 'Paid' end
        end as STATUS
    from payment_rolls pr
),
numbered as (
    select
        ws.*,
        row_number() over (order by CUSTOMER_ID, POLICY_ID, DUE_DATE) as rn
    from with_status ws
)
select
    'PAY' || lpad(rn::varchar, 6, '0') as PAYMENT_ID,
    POLICY_ID,
    CUSTOMER_ID,
    DUE_DATE,
    case
        when STATUS = 'Failed' then null
        when STATUS = 'Late' then
            least(
                dateadd(day, 3 + abs(hash(POLICY_ID, DUE_DATE, 501)) % 23, DUE_DATE),
                '2026-06-30'::date
            )
        else DUE_DATE
    end as PAYMENT_DATE,
    PREMIUM_MONTHLY as AMOUNT,
    PAYMENT_METHOD,
    STATUS
from numbered;
