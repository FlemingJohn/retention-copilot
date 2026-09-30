You are in the EXECUTION phase of a hackathon project. Work directly and briefly. Do not spawn subagents. Do not run shell commands. Use warehouse RETENTION_COPILOT_WH as ACCOUNTADMIN.

The folder snowflake/transcript-enrichment already holds four finished SQL files. Do not edit them. Run them with the SQL tool in this order, reading each file first:

1. 01_create_call_insights_table.sql
2. 02_create_enrichment_procedure.sql (the procedure body is wrapped in $$ delimiters, run it as one statement)
3. Then run only this pilot call and nothing larger: call RETENTION_COPILOT.ANALYTICS.ENRICH_CALLS(1, 50);
4. Then run each statement of 04_check_enrichment.sql one at a time.

Do not run 03_enrich_all_calls.sql. Do not enrich more than 50 calls.

Final answer, short: whether each step ran, the number of rows inserted, and the full output of every check in 04. If a statement fails, give the exact error and stop.
