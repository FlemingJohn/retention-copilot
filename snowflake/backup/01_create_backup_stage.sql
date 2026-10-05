create stage if not exists RETENTION_COPILOT.PUBLIC.BACKUP_STAGE
  file_format = (type = parquet);
