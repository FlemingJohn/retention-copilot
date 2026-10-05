copy into RETENTION_COPILOT.RAW.CUSTOMERS
  from @RETENTION_COPILOT.PUBLIC.BACKUP_STAGE/customers/
  file_format = (type = parquet) match_by_column_name = case_insensitive;

copy into RETENTION_COPILOT.RAW.POLICIES
  from @RETENTION_COPILOT.PUBLIC.BACKUP_STAGE/policies/
  file_format = (type = parquet) match_by_column_name = case_insensitive;

copy into RETENTION_COPILOT.RAW.PAYMENTS
  from @RETENTION_COPILOT.PUBLIC.BACKUP_STAGE/payments/
  file_format = (type = parquet) match_by_column_name = case_insensitive;

copy into RETENTION_COPILOT.RAW.CLAIMS
  from @RETENTION_COPILOT.PUBLIC.BACKUP_STAGE/claims/
  file_format = (type = parquet) match_by_column_name = case_insensitive;

copy into RETENTION_COPILOT.RAW.SERVICE_TICKETS
  from @RETENTION_COPILOT.PUBLIC.BACKUP_STAGE/service_tickets/
  file_format = (type = parquet) match_by_column_name = case_insensitive;

copy into RETENTION_COPILOT.RAW.CALL_TRANSCRIPTS
  from @RETENTION_COPILOT.PUBLIC.BACKUP_STAGE/call_transcripts/
  file_format = (type = parquet) match_by_column_name = case_insensitive;
