use role ACCOUNTADMIN;
use warehouse RETENTION_COPILOT_WH;

select 'CUSTOMERS' as TABLE_NAME, count(*) as ROW_COUNT from RETENTION_COPILOT.RAW.CUSTOMERS
union all
select 'POLICIES', count(*) from RETENTION_COPILOT.RAW.POLICIES
union all
select 'CUSTOMER_MOOD', count(*) from RETENTION_COPILOT.GENERATOR.CUSTOMER_MOOD;

select
    round(count(distinct case when pc.CUSTOMER_ID is not null then ac.CUSTOMER_ID end) /
          count(distinct ac.CUSTOMER_ID)::float * 100, 1) as POST_CUTOFF_CHURN_RATE_PCT
from (
    select distinct CUSTOMER_ID
    from RETENTION_COPILOT.RAW.CUSTOMERS
    where CUSTOMER_ID not in (
        select distinct CUSTOMER_ID from RETENTION_COPILOT.RAW.POLICIES
        where CANCELLATION_DATE between '2026-01-01' and '2026-06-30'
    )
) ac
left join (
    select distinct CUSTOMER_ID from RETENTION_COPILOT.RAW.POLICIES
    where CANCELLATION_DATE between '2026-07-01' and '2026-09-28'
) pc on ac.CUSTOMER_ID = pc.CUSTOMER_ID;

select
    round(count(distinct CUSTOMER_ID) / 5000.0 * 100, 1) as PRE_CUTOFF_CHURN_SHARE_PCT
from RETENTION_COPILOT.RAW.POLICIES
where CANCELLATION_DATE between '2026-01-01' and '2026-06-30';

select
    CANCELLATION_DATE,
    count(*) as CANCELLATIONS
from RETENTION_COPILOT.RAW.POLICIES
where CANCELLATION_DATE between '2026-05-04' and '2026-05-24'
group by CANCELLATION_DATE
order by CANCELLATION_DATE;

select
    round(spike_avg / other_avg, 2) as SPIKE_RATIO
from (
    select
        avg(case when CANCELLATION_DATE between '2026-05-11' and '2026-05-17' then daily_cnt end) as spike_avg,
        avg(case when CANCELLATION_DATE not between '2026-05-11' and '2026-05-17' then daily_cnt end) as other_avg
    from (
        select CANCELLATION_DATE, count(*) as daily_cnt
        from RETENTION_COPILOT.RAW.POLICIES
        where CANCELLATION_DATE between '2026-01-01' and '2026-06-30'
        group by CANCELLATION_DATE
    )
);

with valid_pairs as (
    select column1 as CITY, column2 as STATE, column3 as PIN_PREFIX from values
        ('Mumbai','Maharashtra','400'),
        ('Delhi','Delhi','110'),
        ('Bengaluru','Karnataka','560'),
        ('Hyderabad','Telangana','500'),
        ('Chennai','Tamil Nadu','600'),
        ('Kolkata','West Bengal','700'),
        ('Pune','Maharashtra','411'),
        ('Ahmedabad','Gujarat','380'),
        ('Jaipur','Rajasthan','302'),
        ('Lucknow','Uttar Pradesh','226'),
        ('Surat','Gujarat','395'),
        ('Kanpur','Uttar Pradesh','208'),
        ('Nagpur','Maharashtra','440'),
        ('Indore','Madhya Pradesh','452'),
        ('Thane','Maharashtra','400'),
        ('Bhopal','Madhya Pradesh','462'),
        ('Visakhapatnam','Andhra Pradesh','530'),
        ('Patna','Bihar','800'),
        ('Vadodara','Gujarat','390'),
        ('Ghaziabad','Uttar Pradesh','201'),
        ('Ludhiana','Punjab','141'),
        ('Agra','Uttar Pradesh','282'),
        ('Nashik','Maharashtra','422'),
        ('Ranchi','Jharkhand','834'),
        ('Coimbatore','Tamil Nadu','641'),
        ('Kochi','Kerala','682'),
        ('Thiruvananthapuram','Kerala','695'),
        ('Chandigarh','Chandigarh','160'),
        ('Guwahati','Assam','781'),
        ('Bhubaneswar','Odisha','751'),
        ('Dehradun','Uttarakhand','248'),
        ('Mysuru','Karnataka','570'),
        ('Jodhpur','Rajasthan','342'),
        ('Amritsar','Punjab','143'),
        ('Raipur','Chhattisgarh','492'),
        ('Varanasi','Uttar Pradesh','221'),
        ('Rajkot','Gujarat','360'),
        ('Noida','Uttar Pradesh','201')
)
select count(*) as BAD_CITY_STATE_PAIRS
from RETENTION_COPILOT.RAW.CUSTOMERS c
where not exists (
    select 1 from valid_pairs v where v.CITY = c.CITY and v.STATE = c.STATE
);

with valid_pins as (
    select column1 as CITY, column2 as PIN_PREFIX from values
        ('Mumbai','400'),('Delhi','110'),('Bengaluru','560'),('Hyderabad','500'),
        ('Chennai','600'),('Kolkata','700'),('Pune','411'),('Ahmedabad','380'),
        ('Jaipur','302'),('Lucknow','226'),('Surat','395'),('Kanpur','208'),
        ('Nagpur','440'),('Indore','452'),('Thane','400'),('Bhopal','462'),
        ('Visakhapatnam','530'),('Patna','800'),('Vadodara','390'),('Ghaziabad','201'),
        ('Ludhiana','141'),('Agra','282'),('Nashik','422'),('Ranchi','834'),
        ('Coimbatore','641'),('Kochi','682'),('Thiruvananthapuram','695'),
        ('Chandigarh','160'),('Guwahati','781'),('Bhubaneswar','751'),
        ('Dehradun','248'),('Mysuru','570'),('Jodhpur','342'),('Amritsar','143'),
        ('Raipur','492'),('Varanasi','221'),('Rajkot','360'),('Noida','201')
)
select count(*) as BAD_PINCODE_PREFIX
from RETENTION_COPILOT.RAW.CUSTOMERS c
left join valid_pins v on v.CITY = c.CITY and left(c.PINCODE, 3) = v.PIN_PREFIX
where v.CITY is null;

select count(distinct CITY) as DISTINCT_CITIES from RETENTION_COPILOT.RAW.CUSTOMERS;

select FIRST_NAME, LAST_NAME, CITY, STATE, PINCODE
from RETENTION_COPILOT.RAW.CUSTOMERS
limit 10;

select
    count(*) as POLICIES_STARTING_AFTER_CUTOFF
from RETENTION_COPILOT.RAW.POLICIES
where START_DATE > '2026-06-30';

select
    count(*) as ORPHAN_POLICIES
from RETENTION_COPILOT.RAW.POLICIES p
where not exists (
    select 1 from RETENTION_COPILOT.RAW.CUSTOMERS c where c.CUSTOMER_ID = p.CUSTOMER_ID
);

with active_at_cutoff as (
    select distinct c.CUSTOMER_ID, m.MOOD
    from RETENTION_COPILOT.RAW.CUSTOMERS c
    join RETENTION_COPILOT.GENERATOR.CUSTOMER_MOOD m on c.CUSTOMER_ID = m.CUSTOMER_ID
    where c.CUSTOMER_ID not in (
        select distinct CUSTOMER_ID from RETENTION_COPILOT.RAW.POLICIES
        where CANCELLATION_DATE between '2026-01-01' and '2026-06-30'
    )
),
post_churned as (
    select distinct CUSTOMER_ID from RETENTION_COPILOT.RAW.POLICIES
    where CANCELLATION_DATE between '2026-07-01' and '2026-09-28'
)
select
    case when a.MOOD < 0.3 then 'low (<0.3)' when a.MOOD > 0.7 then 'high (>0.7)' else 'mid' end as MOOD_BUCKET,
    count(*) as TOTAL,
    count(pc.CUSTOMER_ID) as CHURNED,
    round(count(pc.CUSTOMER_ID) / count(*)::float * 100, 1) as CHURN_RATE_PCT
from active_at_cutoff a
left join post_churned pc on a.CUSTOMER_ID = pc.CUSTOMER_ID
group by 1
order by 1;
