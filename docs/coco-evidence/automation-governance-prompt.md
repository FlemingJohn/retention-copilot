You are in the DEVELOPMENT and EXECUTION phase of a hackathon project called Retention Copilot, an insurance retention tool for Suraksha General Insurance. Your working directory is the project root. Read exactly one project file first: docs/synthetic-data-brief.md. Then work only in snowflake/automation and snowflake/governance (snowflake/governance already holds 01_create_app_service_user.sql, do not touch it, number your governance files from 02). Do not read other project files. Do not spawn subagents. Do not run shell commands. Use warehouse RETENTION_COPILOT_WH as ACCOUNTADMIN. Never read anything from the GENERATOR schema.

STRICT RULE FOR THIS WHOLE RUN: everything you do in Snowflake must be ADDITIVE. Do not change, replace or drop any existing object. In particular do not change RETENTION_COPILOT.APP.CUSTOMER_OVERVIEW, APP.CALL_OVERVIEW, APP.CHURN_SEMANTIC_VIEW, APP.CALL_SEARCH, APP.RETENTION_AGENT, APP.RECORD_ACTION_DECISION, or the columns of any ANALYTICS or RAW table. A web app is being built against them right now. Do not enable any account level AI setting.

Existing pieces you may use (read columns with describe table): RAW.CALL_TRANSCRIPTS, ANALYTICS.CALL_INSIGHTS, the procedure RETENTION_COPILOT.ANALYTICS.ENRICH_CALLS(FIRST_NUMBER number, LAST_NUMBER number) which enriches the transcripts whose numeric id is in that range and skips ones already in CALL_INSIGHTS, the dynamic table ANALYTICS.CUSTOMER_PROFILE (target lag 1 day), ANALYTICS.ACTION_DECISIONS (DECISION_ID, ACTION_ID, DECISION, NOTE, PREVIOUS_STATUS, DECIDED_BY, DECIDED_AT), ANALYTICS.RECOMMENDED_ACTIONS, roles RETENTION_COPILOT_ADMIN and RETENTION_COPILOT_READER. The reader role has select on future views in the APP schema. Search Snowflake's docs with cortex search docs if you need syntax.

PART ONE, automation, files in snowflake/automation, run each in order:

01_create_call_stream.sql
  An append only stream RETENTION_COPILOT.RAW.CALL_TRANSCRIPT_STREAM on RETENTION_COPILOT.RAW.CALL_TRANSCRIPTS.

02_create_enrich_new_calls_procedure.sql
  A procedure RETENTION_COPILOT.ANALYTICS.ENRICH_NEW_CALLS() returning text, SQL scripting with the body in $$ delimiters. It consumes the stream inside the procedure (for example by inserting the stream rows into a small temporary table or a counting statement so the stream offset advances), then calls ANALYTICS.ENRICH_CALLS with a range wide enough to cover every transcript not yet in CALL_INSIGHTS, then refreshes the dynamic table ANALYTICS.CUSTOMER_PROFILE, and returns a message with how many calls were newly enriched. If the stream is empty it does nothing and says so.

03_create_enrich_new_calls_task.sql
  A TRIGGERED task RETENTION_COPILOT.ANALYTICS.ENRICH_NEW_CALLS_TASK on warehouse RETENTION_COPILOT_WH, with WHEN SYSTEM$STREAM_HAS_DATA('RETENTION_COPILOT.RAW.CALL_TRANSCRIPT_STREAM'), running the procedure above. Resume it at the end of the file so it is active.

04_test_enrich_new_calls.sql
  A tiny self cleaning test. Insert ONE new transcript into RAW.CALL_TRANSCRIPTS with TRANSCRIPT_ID 'CALL009999' for an existing customer, using the text of an existing transcript, then run the task with EXECUTE TASK (or wait for it) and show that CALL_INSIGHTS now has a row for CALL009999 with a sentiment score and topic. Then clean up completely: delete the test row from ANALYTICS.CALL_INSIGHTS and from RAW.CALL_TRANSCRIPTS, and make sure the stream is consumed so the task does not run again because of the cleanup (suspend the task before the cleanup deletes, consume the stream, then resume it). Finally show that CALL_INSIGHTS again has exactly 1,000 rows and RAW.CALL_TRANSCRIPTS 1,000 rows, and that the task state is started.

05_create_pipeline_runs_view.sql
  A view RETENTION_COPILOT.APP.PIPELINE_RUNS for a web screen, showing the most recent 50 runs of ENRICH_NEW_CALLS_TASK: TASK_NAME, STATE, SCHEDULED_TIME, COMPLETED_TIME, ERROR_MESSAGE (cut to 200 characters). Because the reader role cannot see task history itself, the view must work through the view owner's rights (a normal view owned by ACCOUNTADMIN does that). If task history cannot be read inside a view, use whichever object works and tell me.

PART TWO, governance, files in snowflake/governance, run each in order:

02_create_pii_masking_policies.sql
  Masking policies in RETENTION_COPILOT.GOVERNANCE (create schema RETENTION_COPILOT.GOVERNANCE first, in this same file or a separate one if you prefer, one job per file): one for names, one for email, one for phone, that show the real value only when IS_ROLE_IN_SESSION is true for ACCOUNTADMIN or RETENTION_COPILOT_ADMIN and otherwise show a masked value (names show the first letter and stars, email keeps the domain, phone keeps the last two digits). Use IS_ROLE_IN_SESSION, not CURRENT_ROLE.

03_apply_pii_masking.sql
  Apply the policies to the personal data columns FIRST_NAME? NO: only to LAST_NAME, EMAIL and PHONE of RETENTION_COPILOT.RAW.CUSTOMERS and, if masking policies are supported on dynamic table columns, also LAST_NAME, EMAIL and PHONE of ANALYTICS.CUSTOMER_PROFILE. Do not mask FIRST_NAME or CITY because the web app shows them. If a policy cannot be applied to the dynamic table, say so plainly in your final answer and leave it.

04_create_activity_views.sql
  Two views in the APP schema. APP.ACTION_DECISION_LOG: one row per decision from ANALYTICS.ACTION_DECISIONS joined to the action and customer for FIRST_NAME, CITY and ACTION_TYPE, columns DECISION_ID, ACTION_ID, CUSTOMER_ID, FIRST_NAME, CITY, ACTION_TYPE, DECISION, NOTE, PREVIOUS_STATUS, DECIDED_BY, DECIDED_AT, newest first. APP.GUARDRAIL_LOG: flagged requests only (GUARDRAILS_SIGNAL true) from SNOWFLAKE.ACCOUNT_USAGE.CORTEX_AI_GUARDRAILS_USAGE_HISTORY with only the columns USAGE_TIME, and a source or object column if one exists and a role if one exists, never any prompt text, newest first, limited to the latest 100. It is expected to be empty for now.

05_write_guardrails_script.sql
  DO NOT RUN THIS FILE. It holds the statement that turns on prompt injection protection for the account: ALTER ACCOUNT SET AI_SETTINGS with guardrails advanced_prompt_injection enabled true, exactly as in the Snowflake docs on Cortex AI Guardrails, and next to it the statement ALTER ACCOUNT UNSET AI_SETTINGS to turn it off. Put the two statements in this file separated by a blank line. Do not execute either. I will switch it on myself at the end because it charges credits for every token scanned.

06_check_governance.sql
  Read only checks: show masking policies in the governance schema; the policy references for the masked columns; row counts and one sample row from each new APP view; show grants to role RETENTION_COPILOT_READER (it must still have no privilege on RAW, ANALYTICS or GENERATOR); and a masking proof: create a temporary test role MASKING_TEST_ROLE, grant it usage on the database and schemas RAW and select on RAW.CUSTOMERS, grant it to the current user, run a query as that role with USE SECONDARY ROLES NONE showing the masked LAST_NAME, EMAIL and PHONE for 3 customers, then run the same query as ACCOUNTADMIN showing the real values for the same 3 customers, then drop MASKING_TEST_ROLE. Make sure the temporary role is dropped even if a step fails.

Coding rules for every file, strict: no SQL comments of any kind, one job per file, plain names with no abbreviations, upper case object names, lower case keywords, fully qualified names. Each file must run exactly as saved, except governance file 05 which must not be run. Do not change account level settings.

Final answer, short: files written, whether each ran as saved, the test and check output in full, exactly what did not work, and confirmation that nothing existing was changed and the guardrail statement was NOT executed.
