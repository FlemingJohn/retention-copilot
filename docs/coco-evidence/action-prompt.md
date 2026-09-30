You are in the DEVELOPMENT and EXECUTION phase of a hackathon project called Retention Copilot, an insurance retention tool for the company Suraksha General Insurance. Your working directory is the project root. Read exactly one project file first: docs/synthetic-data-brief.md. Then work only in snowflake/next-best-action. Do not read other project files. Do not spawn subagents. Do not run shell commands. Use warehouse RETENTION_COPILOT_WH as ACCOUNTADMIN. Never read anything from the GENERATOR schema.

Already in Snowflake:
- RETENTION_COPILOT.ANALYTICS.CHURN_SCORES: CUSTOMER_ID, CHURN_PROBABILITY, RISK_TIER (High, Medium, Low), TOP_DRIVER_1..3 (plain text, empty for Low), MODEL_NAME, IS_TEST_CUSTOMER, SCORED_AT. 4,636 rows: 464 High, 927 Medium, 3,245 Low.
- RETENTION_COPILOT.ANALYTICS.CUSTOMER_PROFILE: one row per customer with FIRST_NAME, CITY, SEGMENT, TOTAL_MONTHLY_PREMIUM, ACTIVE_POLICIES, PRODUCTS_HELD, LATE_PAYMENTS, FAILED_PAYMENTS, LATE_OR_FAILED_RATE, CLAIMS_COUNT, OPEN_CLAIMS, REJECTED_CLAIMS, TICKETS_COUNT, OPEN_TICKETS, ESCALATED_TICKETS, AVERAGE_SATISFACTION, CALLS_COUNT, AVERAGE_SENTIMENT, NEGATIVE_CALLS, RIVAL_MENTIONS, CANCEL_INTENT_CALLS and more. Read a table's columns with describe table before using it.

Goal: for every customer in the Medium and High tiers (1,391 customers) create one recommended next best action with a reason, a confidence, a priority and a draft outreach message. Create these files, run each in order:

01_create_recommended_actions_table.sql
  RETENTION_COPILOT.ANALYTICS.RECOMMENDED_ACTIONS: ACTION_ID varchar (like ACT000001), CUSTOMER_ID, ACTION_TYPE varchar(60), CHANNEL varchar(20), REASON varchar(400), CONFIDENCE varchar(10), STATUS varchar(20), PRIORITY_RANK number, REVENUE_AT_RISK number(14,2), DRAFT_MESSAGE varchar(2000), DRAFT_SOURCE varchar(20) ('model' or 'template'), CREATED_AT timestamp_ntz default current_timestamp().

02_create_action_rules_view.sql
  A view RETENTION_COPILOT.ANALYTICS.ACTION_CANDIDATES for the Medium and High tier customers that applies these rules with plain readable SQL, one row per customer:
  ACTION_TYPE is the first rule that matches, in this order:
   1. RIVAL_MENTIONS > 0 or CANCEL_INTENT_CALLS > 0 -> 'Retention offer callback', channel 'Phone'
   2. ESCALATED_TICKETS > 0 or OPEN_TICKETS > 0 -> 'Escalate open ticket', channel 'Phone'
   3. REJECTED_CLAIMS > 0 or OPEN_CLAIMS > 0 -> 'Claims follow-up call', channel 'Phone'
   4. FAILED_PAYMENTS >= 2 or LATE_OR_FAILED_RATE >= 0.3 -> 'Payment plan offer', channel 'Email'
   5. AVERAGE_SENTIMENT < -0.3 or AVERAGE_SATISFACTION <= 2.5 -> 'Service recovery call', channel 'Phone'
   6. otherwise -> 'Loyalty check-in', channel 'Email'
  SIGNAL_GROUPS = the number of distinct adverse signal groups present out of four: payments (LATE_PAYMENTS + FAILED_PAYMENTS > 0), tickets (TICKETS_COUNT > 0), claims (OPEN_CLAIMS + REJECTED_CLAIMS > 0), calls (NEGATIVE_CALLS > 0 or RIVAL_MENTIONS > 0 or CANCEL_INTENT_CALLS > 0).
  CONFIDENCE: 'High' when SIGNAL_GROUPS >= 3, 'Medium' when SIGNAL_GROUPS = 2, otherwise 'Low'. A 'Loyalty check-in' is always 'Low'.
  STATUS: 'Needs review' when CONFIDENCE is 'Low', otherwise 'Pending'.
  REASON: built by SQL from the score and its drivers, in the form 'Churn risk 44% (High): 4 service tickets; 2 rival mentions; 2 calls made', leaving out empty drivers.
  REVENUE_AT_RISK = CHURN_PROBABILITY * TOTAL_MONTHLY_PREMIUM * 12.
  PRIORITY_RANK = rank by REVENUE_AT_RISK descending, 1 is the highest.
  Also expose CUSTOMER_ID, FIRST_NAME, CITY, RISK_TIER, CHURN_PROBABILITY and the three drivers.

03_create_action_writer_procedure.sql
  A stored procedure RETENTION_COPILOT.ANALYTICS.WRITE_ACTIONS(LIMIT_ROWS number) in SQL scripting with the body in $$ delimiters (there are semicolons inside). LIMIT_ROWS 0 means all rows, otherwise only the first LIMIT_ROWS by PRIORITY_RANK. It first truncates RECOMMENDED_ACTIONS, then writes the drafts in ONE set based statement into a temporary table so each model call runs exactly once, then inserts into RECOMMENDED_ACTIONS.
  Draft message: for each candidate call snowflake.cortex.complete with model 'claude-haiku-4-5' using the message list form with an options object with max_tokens 300. The prompt gives the customer's first name, city, the ACTION_TYPE, the REASON signals in words, and instructs: write a short warm outreach message from a retention manager at Suraksha General Insurance to the customer, under 90 words, plain English, no subject line, no markdown. It must NOT mention scores, probabilities, risk, churn, models, AI or data analysis. It must NOT promise a specific discount, amount or outcome, and may only offer to review options, a call, a payment plan or a follow up as fitting the ACTION_TYPE. It must not mention competitors by name. Sign off as 'Suraksha General Insurance retention team'.
  Guardrail: if the model call returns null, an error, an empty text, more than 900 characters, or the text contains any of the words churn, score, probability, risk, algorithm, model, AI (case insensitive, whole words), use a fixed template message chosen by ACTION_TYPE instead and set DRAFT_SOURCE to 'template'; otherwise 'model'.
  The procedure returns a text message with the counts of model drafts and template drafts.

04_write_actions.sql
  Calls the procedure with 30 for the pilot.

05_check_actions.sql
  Read only checks, each its own statement, running as one file: row count; rows per ACTION_TYPE; rows per CONFIDENCE and STATUS; rows per DRAFT_SOURCE; drafts containing any forbidden word (must be 0); minimum, average and maximum draft length; duplicate CUSTOMER_ID (must be 0); rows where CHANNEL, ACTION_TYPE or REASON is empty (must be 0); the sum of REVENUE_AT_RISK; and 4 complete sample rows chosen from different ACTION_TYPEs showing every column.

Run 01, 02, 03, then 04 (the 30 row pilot) then 05. Show me the pilot check output. Then STOP unless no forbidden words were found and no draft is empty: in that case also run RETENTION_COPILOT.ANALYTICS.WRITE_ACTIONS(0) once for all customers and run 05 again, and report both outputs.

Coding rules for every file, strict: no comments of any kind, one job per file, plain names with no abbreviations, upper case object names, lower case keywords, fully qualified names. Each file must run exactly as saved. Do not change account level settings. Do not touch other schemas.

Final answer, short: files written, whether each ran as saved, the pilot output, the full run output if you did it, and anything suspicious or that failed.
