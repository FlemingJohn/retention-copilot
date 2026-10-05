copy into @RETENTION_COPILOT.PUBLIC.BACKUP_STAGE/customers/
  from RETENTION_COPILOT.RAW.CUSTOMERS
  file_format = (type = parquet) header = true overwrite = true;

copy into @RETENTION_COPILOT.PUBLIC.BACKUP_STAGE/policies/
  from RETENTION_COPILOT.RAW.POLICIES
  file_format = (type = parquet) header = true overwrite = true;

copy into @RETENTION_COPILOT.PUBLIC.BACKUP_STAGE/payments/
  from RETENTION_COPILOT.RAW.PAYMENTS
  file_format = (type = parquet) header = true overwrite = true;

copy into @RETENTION_COPILOT.PUBLIC.BACKUP_STAGE/claims/
  from RETENTION_COPILOT.RAW.CLAIMS
  file_format = (type = parquet) header = true overwrite = true;

copy into @RETENTION_COPILOT.PUBLIC.BACKUP_STAGE/service_tickets/
  from RETENTION_COPILOT.RAW.SERVICE_TICKETS
  file_format = (type = parquet) header = true overwrite = true;

copy into @RETENTION_COPILOT.PUBLIC.BACKUP_STAGE/call_transcripts/
  from RETENTION_COPILOT.RAW.CALL_TRANSCRIPTS
  file_format = (type = parquet) header = true overwrite = true;
