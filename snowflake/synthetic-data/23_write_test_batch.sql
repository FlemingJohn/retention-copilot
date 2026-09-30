use role ACCOUNTADMIN;
use warehouse RETENTION_COPILOT_WH;

truncate table RETENTION_COPILOT.RAW.CALL_TRANSCRIPTS;
truncate table RETENTION_COPILOT.GENERATOR.TRANSCRIPT_USAGE;
truncate table RETENTION_COPILOT.GENERATOR.TRANSCRIPT_DRAFTS;

set start_ts = current_timestamp();

call RETENTION_COPILOT.GENERATOR.WRITE_TRANSCRIPT_BATCH(1, 60);

set end_ts = current_timestamp();

select datediff('second', $start_ts, $end_ts) as ELAPSED_SECONDS;
