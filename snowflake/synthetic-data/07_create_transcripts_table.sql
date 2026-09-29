use role ACCOUNTADMIN;
use warehouse RETENTION_COPILOT_WH;

create or replace table RETENTION_COPILOT.RAW.CALL_TRANSCRIPTS (
    TRANSCRIPT_ID      varchar(10)      not null,
    CUSTOMER_ID        varchar(7)       not null,
    TICKET_ID          varchar(10),
    CALL_AT            timestamp_ntz    not null,
    DURATION_SECONDS   number(6,0)      not null,
    AGENT_ID           varchar(10)      not null,
    TRANSCRIPT_TEXT    varchar(16000)
);
