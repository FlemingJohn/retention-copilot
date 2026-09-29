grant usage on database RETENTION_COPILOT to role RETENTION_COPILOT_READER;
grant usage on schema RETENTION_COPILOT.APP to role RETENTION_COPILOT_READER;
grant select on all tables in schema RETENTION_COPILOT.APP to role RETENTION_COPILOT_READER;
grant select on all views in schema RETENTION_COPILOT.APP to role RETENTION_COPILOT_READER;
grant select on future tables in schema RETENTION_COPILOT.APP to role RETENTION_COPILOT_READER;
grant select on future views in schema RETENTION_COPILOT.APP to role RETENTION_COPILOT_READER;
grant usage on warehouse RETENTION_COPILOT_WH to role RETENTION_COPILOT_READER;
