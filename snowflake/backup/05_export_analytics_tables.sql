copy into @RETENTION_COPILOT.PUBLIC.BACKUP_STAGE/call_insights/
  from RETENTION_COPILOT.ANALYTICS.CALL_INSIGHTS
  file_format = (type = parquet) header = true overwrite = true;

copy into @RETENTION_COPILOT.PUBLIC.BACKUP_STAGE/churn_labels/
  from RETENTION_COPILOT.ANALYTICS.CHURN_LABELS
  file_format = (type = parquet) header = true overwrite = true;

copy into @RETENTION_COPILOT.PUBLIC.BACKUP_STAGE/churn_split/
  from RETENTION_COPILOT.ANALYTICS.CHURN_SPLIT
  file_format = (type = parquet) header = true overwrite = true;

copy into @RETENTION_COPILOT.PUBLIC.BACKUP_STAGE/churn_scores/
  from RETENTION_COPILOT.ANALYTICS.CHURN_SCORES
  file_format = (type = parquet) header = true overwrite = true;

copy into @RETENTION_COPILOT.PUBLIC.BACKUP_STAGE/churn_model_results/
  from RETENTION_COPILOT.ANALYTICS.CHURN_MODEL_RESULTS
  file_format = (type = parquet) header = true overwrite = true;

copy into @RETENTION_COPILOT.PUBLIC.BACKUP_STAGE/recommended_actions/
  from RETENTION_COPILOT.ANALYTICS.RECOMMENDED_ACTIONS
  file_format = (type = parquet) header = true overwrite = true;
