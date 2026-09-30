use role ACCOUNTADMIN;
use warehouse RETENTION_COPILOT_WH;

create or replace table RETENTION_COPILOT.ANALYTICS.CALL_INSIGHTS (
    TRANSCRIPT_ID varchar(12) not null primary key,
    CUSTOMER_ID varchar(7) not null,
    CALL_AT timestamp_ntz,
    SENTIMENT_SCORE float,
    MAIN_TOPIC varchar(60),
    COMPETITOR_MENTIONED varchar(60),
    COMPLAINT_REASON varchar(300),
    WANTS_TO_CANCEL boolean,
    ENRICHED_AT timestamp_ntz default current_timestamp()
);
