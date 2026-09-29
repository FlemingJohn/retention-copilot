use role ACCOUNTADMIN;
use warehouse RETENTION_COPILOT_WH;

truncate table RETENTION_COPILOT.RAW.POLICIES;

insert into RETENTION_COPILOT.RAW.POLICIES
    (POLICY_ID, CUSTOMER_ID, PRODUCT_TYPE, PREMIUM_MONTHLY, COVERAGE_AMOUNT,
     START_DATE, RENEWAL_DATE, CANCELLATION_DATE, CANCELLATION_REASON)
with customer_base as (
    select
        c.CUSTOMER_ID,
        c.CUSTOMER_SINCE,
        m.MOOD,
        abs(hash(c.CUSTOMER_ID, 51)) % 100 as policy_roll
    from RETENTION_COPILOT.RAW.CUSTOMERS c
    join RETENTION_COPILOT.GENERATOR.CUSTOMER_MOOD m
        on c.CUSTOMER_ID = m.CUSTOMER_ID
),
policy_counts as (
    select
        CUSTOMER_ID,
        CUSTOMER_SINCE,
        MOOD,
        case
            when policy_roll < 50 then 1
            when policy_roll < 90 then 2
            else 3
        end as num_policies
    from customer_base
),
expanded as (
    select
        pc.CUSTOMER_ID,
        pc.CUSTOMER_SINCE,
        pc.MOOD,
        pc.num_policies,
        row_number() over (partition by pc.CUSTOMER_ID order by s.rn) as policy_seq,
        s.rn as global_rn
    from policy_counts pc
    join (select row_number() over (order by seq4()) as rn from table(generator(rowcount => 3))) s
        on s.rn <= pc.num_policies
),
numbered as (
    select
        *,
        row_number() over (order by CUSTOMER_ID, policy_seq) as policy_num
    from expanded
),
products_array as (
    select policy_num, CUSTOMER_ID, CUSTOMER_SINCE, MOOD, num_policies, policy_seq, global_rn,
        case abs(hash(CUSTOMER_ID, policy_seq, 61)) % 5
            when 0 then 'Motor'
            when 1 then 'Health'
            when 2 then 'Life'
            when 3 then 'Home'
            when 4 then 'Travel'
        end as PRODUCT_TYPE,
        case
            when abs(hash(CUSTOMER_ID, policy_seq, 71)) % 100 < 3
            then round(uniform(20000, 80000, random())::number(12,2), 2)
            else round(
                case abs(hash(CUSTOMER_ID, policy_seq, 61)) % 5
                    when 0 then uniform(800, 4000, random())
                    when 1 then uniform(500, 3000, random())
                    when 2 then uniform(1000, 5000, random())
                    when 3 then uniform(300, 2000, random())
                    when 4 then uniform(200, 1500, random())
                end::number(12,2), 2)
        end as PREMIUM_MONTHLY,
        dateadd(day,
            abs(hash(CUSTOMER_ID, policy_seq, 81)) %
                greatest(1, datediff(day, CUSTOMER_SINCE, '2026-06-30')),
            CUSTOMER_SINCE) as START_DATE
    from numbered
)
select
    'P' || lpad(policy_num::varchar, 6, '0') as POLICY_ID,
    CUSTOMER_ID,
    PRODUCT_TYPE,
    PREMIUM_MONTHLY,
    round(PREMIUM_MONTHLY * uniform(80, 200, random())::number(14,2), 2) as COVERAGE_AMOUNT,
    START_DATE,
    dateadd(year, 1, START_DATE) as RENEWAL_DATE,
    null as CANCELLATION_DATE,
    null as CANCELLATION_REASON
from products_array;
