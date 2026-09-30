use role ACCOUNTADMIN;
use warehouse RETENTION_COPILOT_WH;

create or replace table RETENTION_COPILOT.ANALYTICS.CHURN_MODEL_RESULTS (
    MODEL_NAME    varchar(200),
    SPLIT_NAME    varchar(200),
    METRIC_NAME   varchar(200),
    METRIC_VALUE  float,
    RUN_AT        timestamp
);

create or replace table RETENTION_COPILOT.ANALYTICS.CHURN_SCORES (
    CUSTOMER_ID      varchar(200),
    CHURN_PROBABILITY float,
    RISK_TIER        varchar(50),
    TOP_DRIVER_1     varchar(200),
    TOP_DRIVER_2     varchar(200),
    TOP_DRIVER_3     varchar(200),
    MODEL_NAME       varchar(200),
    IS_TEST_CUSTOMER boolean,
    SCORED_AT        timestamp
);
