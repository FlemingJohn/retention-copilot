create database if not exists RETENTION_COPILOT_BACKUP;

create or replace schema RETENTION_COPILOT_BACKUP.RAW clone RETENTION_COPILOT.RAW;
