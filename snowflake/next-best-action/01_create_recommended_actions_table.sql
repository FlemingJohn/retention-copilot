create or replace table RETENTION_COPILOT.ANALYTICS.RECOMMENDED_ACTIONS (
    ACTION_ID          varchar(9),
    CUSTOMER_ID        varchar(7),
    ACTION_TYPE        varchar(60),
    CHANNEL            varchar(20),
    REASON             varchar(400),
    CONFIDENCE         varchar(10),
    STATUS             varchar(20),
    PRIORITY_RANK      number,
    REVENUE_AT_RISK    number(14, 2),
    DRAFT_MESSAGE      varchar(2000),
    DRAFT_SOURCE       varchar(20),
    CREATED_AT         timestamp_ntz default current_timestamp()
);
