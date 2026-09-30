use role ACCOUNTADMIN;
use warehouse RETENTION_COPILOT_WH;

create or replace table RETENTION_COPILOT.GENERATOR.TRANSCRIPT_USAGE (
    PLAN_ID            number(6,0)    not null,
    TRANSCRIPT_ID      varchar(10)    not null,
    MODEL              varchar(50)    not null,
    PROMPT_TOKENS      number(10,0)   not null,
    COMPLETION_TOKENS  number(10,0)   not null,
    TOTAL_TOKENS       number(10,0)   not null
);

create or replace table RETENTION_COPILOT.GENERATOR.TRANSCRIPT_DRAFTS (
    PLAN_ID   number(6,0)  not null,
    RESPONSE  variant      not null
);
