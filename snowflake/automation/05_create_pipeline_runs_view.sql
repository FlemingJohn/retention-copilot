create or replace view RETENTION_COPILOT.APP.PIPELINE_RUNS as
select
  NAME as TASK_NAME,
  STATE,
  SCHEDULED_TIME,
  COMPLETED_TIME,
  left(ERROR_MESSAGE, 200) as ERROR_MESSAGE
from table(RETENTION_COPILOT.information_schema.task_history(
  task_name => 'ENRICH_NEW_CALLS_TASK',
  scheduled_time_range_start => dateadd('day', -7, current_timestamp())
))
order by SCHEDULED_TIME desc
limit 50;
