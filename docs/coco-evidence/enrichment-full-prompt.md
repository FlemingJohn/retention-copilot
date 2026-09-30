You are in the EXECUTION phase of a hackathon project. Work directly and briefly. Do not spawn subagents. Do not run shell commands. Use warehouse RETENTION_COPILOT_WH as ACCOUNTADMIN.

The folder snowflake/transcript-enrichment holds finished SQL files. Do not edit them. The procedure in file 02 was just changed so that the competitor column only keeps a known insurer name and stores null otherwise. A 50 call pilot was already enriched with the old version, so start clean. Do these steps in order with the SQL tool, reading each file first:

1. Run 02_create_enrichment_procedure.sql (the body is wrapped in $$ delimiters, run it as one statement).
2. Run: truncate table RETENTION_COPILOT.ANALYTICS.CALL_INSIGHTS;
3. Run 03_enrich_all_calls.sql, one CALL statement at a time, and record the seconds each call takes.
4. Run each statement of 04_check_enrichment.sql one at a time.
5. Also run this extra read-only query and show its output: select COMPETITOR_MENTIONED, count(*) as calls from RETENTION_COPILOT.ANALYTICS.CALL_INSIGHTS group by 1 order by 2 desc;

Final answer, short: whether each step ran, the rows inserted by each call and the seconds, and the full output of every check and the extra query. If a statement fails, give the exact error and stop.
