You are in the EXECUTION phase of a hackathon project. Work directly and briefly. Do not spawn subagents. Do not run shell commands. Use warehouse RETENTION_COPILOT_WH as ACCOUNTADMIN.

The folder snowflake/transcript-enrichment holds finished SQL files. Do not edit them. An earlier run enriched calls 1 to 500 and then failed on calls 501 to 750 with "String is too long and would be truncated". File 02 was just changed to cut the complaint text at 300 characters. Do these steps in order with the SQL tool, reading each file first:

1. Run 02_create_enrichment_procedure.sql (the body is wrapped in $$ delimiters, run it as one statement). Do NOT truncate the table, the first 500 rows must stay.
2. Run only these two calls, one at a time, recording the seconds each takes: call RETENTION_COPILOT.ANALYTICS.ENRICH_CALLS(501, 750); and call RETENTION_COPILOT.ANALYTICS.ENRICH_CALLS(751, 1000);
3. Run each statement of 04_check_enrichment.sql one at a time.
4. Also run these read-only queries and show their output:
   select COMPETITOR_MENTIONED, count(*) as calls from RETENTION_COPILOT.ANALYTICS.CALL_INSIGHTS group by 1 order by 2 desc;
   select max(length(COMPLAINT_REASON)) as longest_complaint, count(*) as rows_total, count(distinct TRANSCRIPT_ID) as distinct_transcripts from RETENTION_COPILOT.ANALYTICS.CALL_INSIGHTS;

Final answer, short: whether each step ran, the rows inserted by each call and the seconds, and the full output of every check and the extra queries. If a statement fails, give the exact error and stop.
