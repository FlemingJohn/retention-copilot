use role ACCOUNTADMIN;
use warehouse RETENTION_COPILOT_WH;

create or replace table RETENTION_COPILOT.RAW.CUSTOMERS (
    CUSTOMER_ID        varchar(7)       not null,
    FIRST_NAME         varchar(100),
    LAST_NAME          varchar(100),
    EMAIL              varchar(200),
    PHONE              varchar(30),
    DATE_OF_BIRTH      date,
    ADDRESS_LINE       varchar(300),
    CITY               varchar(100),
    STATE              varchar(100),
    PINCODE            varchar(6),
    CUSTOMER_SINCE     date             not null,
    SEGMENT            varchar(10)      not null default 'Standard'
);
