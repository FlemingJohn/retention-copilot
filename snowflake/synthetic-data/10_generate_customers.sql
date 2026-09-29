use role ACCOUNTADMIN;
use warehouse RETENTION_COPILOT_WH;

truncate table RETENTION_COPILOT.RAW.CUSTOMERS;

insert into RETENTION_COPILOT.RAW.CUSTOMERS
    (CUSTOMER_ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE,
     DATE_OF_BIRTH, ADDRESS_LINE, CITY, STATE, PINCODE,
     CUSTOMER_SINCE, SEGMENT)
with seq as (
    select row_number() over (order by seq4()) as rn
    from table(generator(rowcount => 5000))
),
persons as (
    select
        rn,
        'C' || lpad(rn::varchar, 6, '0') as cid,
        RETENTION_COPILOT.GENERATOR.GENERATE_PERSON(rn) as p,
        dateadd(day,
            abs(hash(rn, 7)) % (datediff(day, '1956-06-30', '2005-06-30') + 1),
            '1956-06-30') as dob,
        dateadd(day,
            abs(hash(rn, 13)) % (datediff(day, '2016-01-01', '2026-06-30') + 1),
            '2016-01-01') as csince
    from seq
)
select
    cid,
    p:first_name::varchar,
    p:last_name::varchar,
    case when abs(hash(rn, 17)) % 100 < 3 then null else p:email::varchar end,
    case when abs(hash(rn, 19)) % 100 < 3 then null else p:phone::varchar end,
    dob,
    p:address_line::varchar,
    p:city::varchar,
    p:state::varchar,
    p:pincode::varchar,
    csince,
    'Standard'
from persons;

truncate table RETENTION_COPILOT.GENERATOR.CUSTOMER_MOOD;

insert into RETENTION_COPILOT.GENERATOR.CUSTOMER_MOOD (CUSTOMER_ID, MOOD)
with seq as (
    select row_number() over (order by seq4()) as rn
    from table(generator(rowcount => 5000))
)
select
    'C' || lpad(rn::varchar, 6, '0'),
    least(1.0, greatest(0.0,
        power(abs(hash(rn, 31)) / power(2, 63)::float, 2.5)
    ))
from seq;
