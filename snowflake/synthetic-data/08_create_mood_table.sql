use role ACCOUNTADMIN;
use warehouse RETENTION_COPILOT_WH;

create or replace table RETENTION_COPILOT.GENERATOR.CUSTOMER_MOOD (
    CUSTOMER_ID  varchar(7)    not null,
    MOOD         float         not null
);
