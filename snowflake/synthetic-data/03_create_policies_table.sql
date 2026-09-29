use role ACCOUNTADMIN;
use warehouse RETENTION_COPILOT_WH;

create or replace table RETENTION_COPILOT.RAW.POLICIES (
    POLICY_ID            varchar(7)       not null,
    CUSTOMER_ID          varchar(7)       not null,
    PRODUCT_TYPE         varchar(10)      not null,
    PREMIUM_MONTHLY      number(12,2)     not null,
    COVERAGE_AMOUNT      number(14,2)     not null,
    START_DATE           date             not null,
    RENEWAL_DATE         date,
    CANCELLATION_DATE    date,
    CANCELLATION_REASON  varchar(200)
);
