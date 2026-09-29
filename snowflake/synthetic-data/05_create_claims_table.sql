use role ACCOUNTADMIN;
use warehouse RETENTION_COPILOT_WH;

create or replace table RETENTION_COPILOT.RAW.CLAIMS (
    CLAIM_ID            varchar(10)      not null,
    POLICY_ID           varchar(7)       not null,
    CUSTOMER_ID         varchar(7)       not null,
    CLAIM_DATE          date             not null,
    CLAIM_TYPE          varchar(50)      not null,
    CLAIM_AMOUNT        number(14,2)     not null,
    SETTLEMENT_AMOUNT   number(14,2),
    STATUS              varchar(20)      not null,
    RESOLUTION_DATE     date
);
