use role ACCOUNTADMIN;
use warehouse RETENTION_COPILOT_WH;

truncate table RETENTION_COPILOT.RAW.SERVICE_TICKETS;

insert into RETENTION_COPILOT.RAW.SERVICE_TICKETS
    (TICKET_ID, CUSTOMER_ID, CHANNEL, CATEGORY, PRIORITY, STATUS, OPENED_AT, RESOLVED_AT, SATISFACTION_SCORE)
with customer_window as (
    select
        c.CUSTOMER_ID,
        m.MOOD,
        max(case
            when p.CANCELLATION_DATE is null or p.CANCELLATION_DATE > '2026-06-30'
            then '2026-06-30'::date
            when p.CANCELLATION_DATE >= '2026-01-01'
            then p.CANCELLATION_DATE
        end) as active_until
    from RETENTION_COPILOT.RAW.CUSTOMERS c
    join RETENTION_COPILOT.GENERATOR.CUSTOMER_MOOD m on c.CUSTOMER_ID = m.CUSTOMER_ID
    join RETENTION_COPILOT.RAW.POLICIES p on c.CUSTOMER_ID = p.CUSTOMER_ID
    where p.START_DATE <= '2026-06-30'::date
    group by c.CUSTOMER_ID, m.MOOD
    having active_until is not null and active_until >= '2026-01-01'::date
),
slots as (
    select row_number() over (order by seq4()) - 1 as slot_num
    from table(generator(rowcount => 6))
),
expanded as (
    select
        cw.CUSTOMER_ID,
        cw.MOOD,
        cw.active_until,
        s.slot_num,
        abs(hash(cw.CUSTOMER_ID, s.slot_num, 701)) % 1000 / 1000.0 as roll,
        case s.slot_num
            when 0 then 0.24 + 0.50 * cw.MOOD
            when 1 then 0.09 + 0.45 * cw.MOOD
            when 2 then 0.02 + 0.37 * cw.MOOD
            when 3 then 0.00 + 0.24 * cw.MOOD
            when 4 then 0.00 + 0.14 * cw.MOOD
            when 5 then 0.00 + 0.09 * cw.MOOD
        end as ticket_prob
    from customer_window cw
    cross join slots s
),
tickets_base as (
    select * from expanded where roll < ticket_prob
),
with_dates as (
    select
        tb.*,
        abs(hash(CUSTOMER_ID, slot_num, 711)) % 100 < 4 as force_spike,
        case
            when abs(hash(CUSTOMER_ID, slot_num, 711)) % 100 < 4
            then dateadd(second,
                abs(hash(CUSTOMER_ID, slot_num, 721)) % (7 * 86400),
                '2026-05-11'::timestamp_ntz)
            else dateadd(second,
                abs(hash(CUSTOMER_ID, slot_num, 731)) %
                    greatest(1, datediff(second, '2026-01-01'::timestamp_ntz,
                        least(active_until::timestamp_ntz, '2026-06-30 23:59:59'::timestamp_ntz))),
                '2026-01-01'::timestamp_ntz)
        end as raw_opened
    from tickets_base tb
),
with_opened as (
    select
        wd.*,
        case
            when raw_opened::date > active_until then
                dateadd(second,
                    abs(hash(CUSTOMER_ID, slot_num, 741)) %
                        greatest(1, datediff(second, '2026-01-01'::timestamp_ntz, active_until::timestamp_ntz)),
                    '2026-01-01'::timestamp_ntz)
            else raw_opened
        end as OPENED_AT
    from with_dates wd
),
with_valid as (
    select wo.*
    from with_opened wo
    where exists (
        select 1 from RETENTION_COPILOT.RAW.POLICIES p
        where p.CUSTOMER_ID = wo.CUSTOMER_ID
          and p.START_DATE <= wo.OPENED_AT::date
          and (p.CANCELLATION_DATE is null
               or p.CANCELLATION_DATE > '2026-06-30'
               or p.CANCELLATION_DATE >= wo.OPENED_AT::date)
    )
),
with_attrs as (
    select
        wv.*,
        case abs(hash(CUSTOMER_ID, slot_num, 751)) % 4
            when 0 then 'Phone'
            when 1 then 'Email'
            when 2 then 'Chat'
            when 3 then 'App'
        end as CHANNEL,
        case
            when force_spike and abs(hash(CUSTOMER_ID, slot_num, 761)) % 100 < 60 then 'Billing'
            else case abs(hash(CUSTOMER_ID, slot_num, 761)) % 5
                when 0 then 'Billing'
                when 1 then 'Claims'
                when 2 then 'Renewal'
                when 3 then 'Policy Change'
                when 4 then 'General'
            end
        end as CATEGORY,
        case abs(hash(CUSTOMER_ID, slot_num, 771)) % 10
            when 0 then 'High'
            when 1 then 'High'
            when 2 then 'Medium'
            when 3 then 'Medium'
            when 4 then 'Medium'
            when 5 then 'Medium'
            else 'Low'
        end as PRIORITY,
        1 + abs(hash(CUSTOMER_ID, slot_num, 781)) % 120 as resolve_hours,
        abs(hash(CUSTOMER_ID, slot_num, 791)) % 100 as status_roll,
        abs(hash(CUSTOMER_ID, 801)) % 100 < 10 and MOOD > 0.7 as is_calm_high,
        abs(hash(CUSTOMER_ID, 811)) % 100 < 5  and MOOD < 0.3 as is_grumpy_low
    from with_valid wv
),
with_status as (
    select
        wa.*,
        dateadd(hour, resolve_hours, OPENED_AT) as raw_resolved,
        case
            when OPENED_AT > dateadd(day, -10, '2026-06-30'::timestamp_ntz) and status_roll < 40 then 'Open'
            when OPENED_AT > dateadd(day, -10, '2026-06-30'::timestamp_ntz) and status_roll < 50 then 'Escalated'
            when status_roll < 5 then 'Escalated'
            when status_roll < 15 then 'Open'
            else 'Resolved'
        end as STATUS
    from with_attrs wa
),
with_resolved as (
    select
        ws.*,
        case
            when STATUS = 'Resolved' and raw_resolved <= '2026-06-30 23:59:59'::timestamp_ntz
            then raw_resolved
            when STATUS = 'Resolved' and raw_resolved > '2026-06-30 23:59:59'::timestamp_ntz
            then null
            else null
        end as RESOLVED_AT,
        case
            when STATUS = 'Resolved' and raw_resolved > '2026-06-30 23:59:59'::timestamp_ntz
            then 'Open'
            else STATUS
        end as FINAL_STATUS
    from with_status ws
),
with_score as (
    select
        wr.*,
        case
            when FINAL_STATUS != 'Resolved' then null
            when abs(hash(CUSTOMER_ID, slot_num, 821)) % 100 < 8 then null
            when is_calm_high then
                least(5, greatest(1, round(4.0 + uniform(-1.0, 1.0, random()), 0)))
            when is_grumpy_low then
                least(5, greatest(1, round(2.0 + uniform(-1.0, 1.0, random()), 0)))
            else
                least(5, greatest(1, round(4.5 - 2.5 * MOOD + uniform(-1.0, 1.0, random()), 0)))
        end as SATISFACTION_SCORE
    from with_resolved wr
),
numbered as (
    select
        wsc.*,
        row_number() over (order by CUSTOMER_ID, OPENED_AT) as rn
    from with_score wsc
)
select
    'TKT' || lpad(rn::varchar, 6, '0') as TICKET_ID,
    CUSTOMER_ID,
    CHANNEL,
    CATEGORY,
    PRIORITY,
    FINAL_STATUS as STATUS,
    OPENED_AT,
    RESOLVED_AT,
    SATISFACTION_SCORE
from numbered;
