use role ACCOUNTADMIN;
use warehouse RETENTION_COPILOT_WH;

grant database role SNOWFLAKE.CORTEX_AGENT_USER
    to role RETENTION_COPILOT_READER;

grant usage on agent RETENTION_COPILOT.APP.RETENTION_AGENT
    to role RETENTION_COPILOT_READER;

grant usage on procedure RETENTION_COPILOT.APP.RECORD_ACTION_DECISION(varchar, varchar, varchar)
    to role RETENTION_COPILOT_READER;

grant usage on cortex search service RETENTION_COPILOT.APP.CALL_SEARCH
    to role RETENTION_COPILOT_READER;

show grants to role RETENTION_COPILOT_READER;
