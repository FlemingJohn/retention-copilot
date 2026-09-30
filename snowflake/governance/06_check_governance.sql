show masking policies in schema RETENTION_COPILOT.GOVERNANCE;

select * from table(RETENTION_COPILOT.information_schema.policy_references(
  ref_entity_name => 'RETENTION_COPILOT.RAW.CUSTOMERS',
  ref_entity_domain => 'TABLE'
));

select * from table(RETENTION_COPILOT.information_schema.policy_references(
  ref_entity_name => 'RETENTION_COPILOT.ANALYTICS.CUSTOMER_PROFILE',
  ref_entity_domain => 'TABLE'
));

select count(*) as ACTION_DECISION_LOG_COUNT from RETENTION_COPILOT.APP.ACTION_DECISION_LOG;

select * from RETENTION_COPILOT.APP.ACTION_DECISION_LOG limit 1;

select count(*) as GUARDRAIL_LOG_COUNT from RETENTION_COPILOT.APP.GUARDRAIL_LOG;

show grants to role RETENTION_COPILOT_READER;

create role if not exists MASKING_TEST_ROLE;

grant usage on database RETENTION_COPILOT to role MASKING_TEST_ROLE;

grant usage on schema RETENTION_COPILOT.RAW to role MASKING_TEST_ROLE;

grant select on table RETENTION_COPILOT.RAW.CUSTOMERS to role MASKING_TEST_ROLE;

grant usage on warehouse RETENTION_COPILOT_WH to role MASKING_TEST_ROLE;

grant role MASKING_TEST_ROLE to user FLEMINGJOHN21;

use role MASKING_TEST_ROLE;

use warehouse RETENTION_COPILOT_WH;

use secondary roles none;

select CUSTOMER_ID, LAST_NAME, EMAIL, PHONE
from RETENTION_COPILOT.RAW.CUSTOMERS
order by CUSTOMER_ID
limit 3;

use role ACCOUNTADMIN;

use warehouse RETENTION_COPILOT_WH;

select CUSTOMER_ID, LAST_NAME, EMAIL, PHONE
from RETENTION_COPILOT.RAW.CUSTOMERS
order by CUSTOMER_ID
limit 3;

drop role if exists MASKING_TEST_ROLE;
