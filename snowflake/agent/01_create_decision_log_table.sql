use role ACCOUNTADMIN;
use warehouse RETENTION_COPILOT_WH;

create or replace table RETENTION_COPILOT.ANALYTICS.ACTION_DECISIONS (
    DECISION_ID   number autoincrement primary key,
    ACTION_ID     varchar,
    DECISION      varchar(20),
    NOTE          varchar(500),
    PREVIOUS_STATUS varchar(20),
    DECIDED_BY    varchar(100),
    DECIDED_AT    timestamp_ntz default current_timestamp()
);
