use role ACCOUNTADMIN;
use warehouse RETENTION_COPILOT_WH;

create or replace table RETENTION_COPILOT.GENERATOR.CALL_PLAN (
    PLAN_ID          number(6,0)      not null,
    CUSTOMER_ID      varchar(7)       not null,
    CALL_AT          timestamp_ntz    not null,
    AGENT_ID         varchar(10)      not null,
    AGENT_NAME       varchar(50)      not null,
    TOPIC            varchar(60)      not null,
    STYLE            varchar(20)      not null,
    COMPETITOR       varchar(30)      default '',
    TONE             varchar(200)     not null,
    DURATION_TARGET  varchar(10)      not null,
    POLICY_ID        varchar(7)       not null,
    PRODUCT_TYPE     varchar(20)      not null,
    PREMIUM_MONTHLY  number(10,0)     not null
);

insert into RETENTION_COPILOT.GENERATOR.CALL_PLAN
with eligible as (
    select
        c.CUSTOMER_ID,
        m.MOOD,
        min(case when p.CANCELLATION_DATE is not null and p.CANCELLATION_DATE <= '2026-06-30'
            then p.CANCELLATION_DATE end) as earliest_cancel
    from RETENTION_COPILOT.RAW.CUSTOMERS c
    join RETENTION_COPILOT.GENERATOR.CUSTOMER_MOOD m on m.CUSTOMER_ID = c.CUSTOMER_ID
    join RETENTION_COPILOT.RAW.POLICIES p on p.CUSTOMER_ID = c.CUSTOMER_ID
    where p.CANCELLATION_DATE is null or p.CANCELLATION_DATE >= '2026-01-01'
    group by c.CUSTOMER_ID, m.MOOD
),
call_count as (
    select
        CUSTOMER_ID,
        MOOD,
        earliest_cancel,
        case
            when uniform(0::float, 1::float, random()) < (0.10 + 0.25 * MOOD) then
                case
                    when uniform(0::float, 1::float, random()) < (0.05 + 0.15 * MOOD) then 3
                    else 2
                end
            else 1
        end as num_calls
    from eligible
    where uniform(0::float, 1::float, random()) < (0.15 + 0.25 * MOOD)
),
expanded as (
    select
        CUSTOMER_ID,
        MOOD,
        earliest_cancel,
        row_number() over (partition by CUSTOMER_ID order by seq4()) as call_seq
    from call_count,
    lateral flatten(input => array_generate_range(0, num_calls))
),
with_dates as (
    select
        CUSTOMER_ID,
        MOOD,
        earliest_cancel,
        call_seq,
        dateadd('day',
            abs(hash(CUSTOMER_ID || '-' || call_seq::varchar || '-date')) %
                greatest(datediff('day', '2026-01-01', coalesce(earliest_cancel, '2026-06-30')), 1),
            '2026-01-01'::date
        ) as call_date
    from expanded
),
has_claim as (
    select distinct CUSTOMER_ID from RETENTION_COPILOT.RAW.CLAIMS
),
has_late as (
    select CUSTOMER_ID, count(*) as late_cnt
    from RETENTION_COPILOT.RAW.PAYMENTS
    where STATUS in ('Late', 'Failed')
    and DUE_DATE >= '2025-10-01'
    group by CUSTOMER_ID
),
planned as (
    select
        d.CUSTOMER_ID,
        d.MOOD,
        d.call_seq,
        d.call_date,
        pol.POLICY_ID,
        pol.PRODUCT_TYPE,
        round(pol.PREMIUM_MONTHLY)::number(10,0) as PREMIUM_MONTHLY,
        'A' || lpad((abs(hash(d.CUSTOMER_ID || '-' || d.call_seq::varchar || '-agent')) % 50 + 1)::varchar, 4, '0') as AGENT_ID,
        case abs(hash(d.CUSTOMER_ID || '-' || d.call_seq::varchar || '-name')) % 30 + 1
            when 1 then 'Aarav' when 2 then 'Vivaan' when 3 then 'Aditya'
            when 4 then 'Vihaan' when 5 then 'Arjun' when 6 then 'Reyansh'
            when 7 then 'Sai' when 8 then 'Arnav' when 9 then 'Dhruv'
            when 10 then 'Kabir' when 11 then 'Ananya' when 12 then 'Diya'
            when 13 then 'Aadhya' when 14 then 'Priya' when 15 then 'Meera'
            when 16 then 'Ishaan' when 17 then 'Rohan' when 18 then 'Neha'
            when 19 then 'Kavya' when 20 then 'Riya' when 21 then 'Amit'
            when 22 then 'Pooja' when 23 then 'Sneha' when 24 then 'Rahul'
            when 25 then 'Deepak' when 26 then 'Shreya' when 27 then 'Tanvi'
            when 28 then 'Nikhil' when 29 then 'Ritika' when 30 then 'Vikram'
        end as AGENT_NAME,
        case
            when hc.CUSTOMER_ID is not null and uniform(0::float, 1::float, random()) < 0.60
                then case uniform(1, 2, random())
                    when 1 then 'claim status enquiry'
                    else 'claim rejected or delayed'
                end
            when hl.late_cnt is not null and hl.late_cnt >= 2 and uniform(0::float, 1::float, random()) < 0.50
                then 'payment or billing problem'
            else case uniform(1, 8, random())
                when 1 then 'premium increase at renewal'
                when 2 then 'claim status enquiry'
                when 3 then 'payment or billing problem'
                when 4 then 'add a family member or change a policy'
                when 5 then 'general product question'
                when 6 then 'thanks and praise'
                when 7 then 'asking how to cancel'
                when 8 then 'premium increase at renewal'
            end
        end as TOPIC,
        case uniform(1, 10, random())
            when 1 then 'formal'
            when 2 then 'formal'
            when 3 then 'casual'
            when 4 then 'casual'
            when 5 then 'hurried'
            when 6 then 'chatty'
            when 7 then 'hinglish'
            when 8 then 'hinglish'
            when 9 then 'hinglish'
            when 10 then 'casual'
        end as STYLE,
        case
            when uniform(0::float, 1::float, random()) < 0.03 + 0.17 * d.MOOD
                then case uniform(1, 7, random())
                    when 1 then 'LIC' when 2 then 'HDFC Life' when 3 then 'ICICI Lombard'
                    when 4 then 'Star Health' when 5 then 'Bajaj Allianz' when 6 then 'Tata AIG' when 7 then 'SBI Life'
                end
            else ''
        end as COMPETITOR,
        case
            when d.MOOD >= 0.7 then
                case uniform(1, 10, random())
                    when 1 then 'The customer is frustrated and impatient.'
                    when 2 then 'The customer is angry and raises their voice.'
                    when 3 then 'The customer is tired and wants a quick resolution.'
                    when 4 then 'The customer is upset but trying to stay polite.'
                    when 5 then 'The customer is resigned and sounds defeated.'
                    when 6 then 'The customer is irritable and keeps interrupting.'
                    when 7 then 'The customer is anxious and speaks quickly.'
                    when 8 then 'The customer is sarcastic but not shouting.'
                    when 9 then 'The customer is calm but clearly disappointed.'
                    when 10 then 'The customer is polite despite being unhappy.'
                end
            when d.MOOD >= 0.33 then
                case uniform(1, 8, random())
                    when 1 then 'The customer is neutral and businesslike.'
                    when 2 then 'The customer is mildly concerned but polite.'
                    when 3 then 'The customer is a bit impatient but cooperative.'
                    when 4 then 'The customer is calm and asks clear questions.'
                    when 5 then 'The customer is pleasant but wants answers quickly.'
                    when 6 then 'The customer is matter of fact and brief.'
                    when 7 then 'The customer is slightly worried.'
                    when 8 then 'The customer is friendly but has a complaint.'
                end
            else
                case uniform(1, 8, random())
                    when 1 then 'The customer is cheerful and relaxed.'
                    when 2 then 'The customer is happy with the service.'
                    when 3 then 'The customer is calm and patient.'
                    when 4 then 'The customer is friendly and chatty.'
                    when 5 then 'The customer is polite and straightforward.'
                    when 6 then 'The customer is appreciative and kind.'
                    when 7 then 'The customer sounds sharp and hurried despite being satisfied.'
                    when 8 then 'The customer is warm and easygoing.'
                end
        end as TONE,
        case uniform(1, 3, random())
            when 1 then 'short'
            when 2 then 'medium'
            when 3 then 'long'
        end as DURATION_TARGET
    from with_dates d
    join RETENTION_COPILOT.RAW.POLICIES pol
        on pol.CUSTOMER_ID = d.CUSTOMER_ID
        and pol.START_DATE <= d.call_date
        and (pol.CANCELLATION_DATE is null or pol.CANCELLATION_DATE > d.call_date)
    left join has_claim hc on hc.CUSTOMER_ID = d.CUSTOMER_ID
    left join has_late hl on hl.CUSTOMER_ID = d.CUSTOMER_ID
    qualify row_number() over (partition by d.CUSTOMER_ID, d.call_seq order by pol.START_DATE desc) = 1
),
with_ts as (
    select p.*,
        (call_date::varchar || ' ' ||
         lpad((abs(hash(CUSTOMER_ID || call_seq::varchar || 'h')) % 9 + 9)::varchar, 2, '0') || ':' ||
         lpad((abs(hash(CUSTOMER_ID || call_seq::varchar || 'm')) % 60)::varchar, 2, '0') || ':' ||
         lpad((abs(hash(CUSTOMER_ID || call_seq::varchar || 's')) % 60)::varchar, 2, '0')
        )::timestamp_ntz as CALL_AT
    from planned p
),
ordered as (
    select *,
        row_number() over (order by md5(CUSTOMER_ID || call_seq::varchar)) as rn
    from with_ts
)
select
    rn, CUSTOMER_ID, CALL_AT, AGENT_ID, AGENT_NAME, TOPIC, STYLE, COMPETITOR, TONE, DURATION_TARGET,
    POLICY_ID, PRODUCT_TYPE, PREMIUM_MONTHLY
from ordered
order by rn;
