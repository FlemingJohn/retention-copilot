use role ACCOUNTADMIN;
use warehouse RETENTION_COPILOT_WH;

create or replace table RETENTION_COPILOT.RAW.SERVICE_TICKETS (
    TICKET_ID            varchar(10)      not null,
    CUSTOMER_ID          varchar(7)       not null,
    CHANNEL              varchar(20)      not null,
    CATEGORY             varchar(50)      not null,
    PRIORITY             varchar(10)      not null,
    STATUS               varchar(15)      not null,
    OPENED_AT            timestamp_ntz    not null,
    RESOLVED_AT          timestamp_ntz,
    SATISFACTION_SCORE   number(3,1)
);
