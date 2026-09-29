create or replace resource monitor RETENTION_COPILOT_MONITOR
  with credit_quota = 100
  triggers
    on 75 percent do notify
    on 100 percent do suspend;
