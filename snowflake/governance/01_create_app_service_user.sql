use role ACCOUNTADMIN;

create user if not exists RETENTION_COPILOT_APP
  type = service
  default_role = RETENTION_COPILOT_READER
  default_warehouse = RETENTION_COPILOT_WH
  comment = 'Service user for the Retention Copilot web app, read only role';

grant role RETENTION_COPILOT_READER to user RETENTION_COPILOT_APP;

alter user RETENTION_COPILOT_APP set authentication policy COCO_APP.PUBLIC.PAT_NO_NETWORK;

alter user RETENTION_COPILOT_APP add programmatic access token APP_TOKEN
  role_restriction = 'RETENTION_COPILOT_READER'
  days_to_expiry = 30
  comment = 'Web app token restricted to the read only role';
