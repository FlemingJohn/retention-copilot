use role ACCOUNTADMIN;
use warehouse RETENTION_COPILOT_WH;

create or replace table RETENTION_COPILOT.RAW.PAYMENTS (
    PAYMENT_ID       varchar(10)      not null,
    POLICY_ID        varchar(7)       not null,
    CUSTOMER_ID      varchar(7)       not null,
    DUE_DATE         date             not null,
    PAYMENT_DATE     date,
    AMOUNT           number(12,2)     not null,
    PAYMENT_METHOD   varchar(15),
    STATUS           varchar(15)      not null
);
