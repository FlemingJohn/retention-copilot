You are in the DEVELOPMENT and EXECUTION phase of a hackathon project called Retention Copilot. Your working directory is the project root. Read exactly one project file first: docs/synthetic-data-brief.md. Then work only in snowflake/customer-profile. Do not read other project files. Do not spawn subagents. Do not run shell commands. Use warehouse RETENTION_COPILOT_WH as ACCOUNTADMIN.

Already in Snowflake: RAW.CUSTOMERS, RAW.POLICIES, RAW.PAYMENTS, RAW.CLAIMS, RAW.SERVICE_TICKETS, RAW.CALL_TRANSCRIPTS, and ANALYTICS.CALL_INSIGHTS (one row per call: TRANSCRIPT_ID, CUSTOMER_ID, CALL_AT, SENTIMENT_SCORE, MAIN_TOPIC, COMPETITOR_MENTIONED, COMPLAINT_REASON, WANTS_TO_CANCEL). The cutoff date is 2026-06-30. Read a table's column names with describe table before you use it. Never use anything from GENERATOR.

Build the customer profile, the table a churn model will train on. Create these files in snowflake/customer-profile, run each, in this order:

01_create_customer_profile.sql
  A dynamic table RETENTION_COPILOT.ANALYTICS.CUSTOMER_PROFILE with target_lag of 1 day on warehouse RETENTION_COPILOT_WH, one row per customer for all 5,000 customers, describing each customer AS OF 2026-06-30. Columns:
  - identity and display: CUSTOMER_ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE, CITY, STATE, SEGMENT, CUSTOMER_SINCE, TENURE_MONTHS (months from CUSTOMER_SINCE to 2026-06-30).
  - IS_ACTIVE_AT_CUTOFF: true when the customer has at least one policy that is not cancelled on or before 2026-06-30.
  - policies, counting only policies that started on or before the cutoff and were not cancelled on or before the cutoff: ACTIVE_POLICIES, TOTAL_MONTHLY_PREMIUM, PRODUCT_COUNT, PRODUCTS_HELD (a comma separated list of the distinct product types).
  - payments due from 2026-01-01 to 2026-06-30: PAYMENTS_COUNT, LATE_PAYMENTS (status Late), FAILED_PAYMENTS (status Failed), LATE_OR_FAILED_RATE (their share of PAYMENTS_COUNT, null when there are no payments), AVERAGE_DAYS_LATE (average of PAYMENT_DATE minus DUE_DATE over the Late payments, null when none).
  - claims dated 2026-01-01 to 2026-06-30: CLAIMS_COUNT, OPEN_CLAIMS, REJECTED_CLAIMS, TOTAL_CLAIMED_AMOUNT, AVERAGE_RESOLUTION_DAYS (average days from CLAIM_DATE to RESOLUTION_DATE over resolved claims, null when none).
  - tickets opened 2026-01-01 to 2026-06-30: TICKETS_COUNT, OPEN_TICKETS, ESCALATED_TICKETS, AVERAGE_SATISFACTION (null when none), LOWEST_SATISFACTION (null when none).
  - calls from ANALYTICS.CALL_INSIGHTS dated on or before the cutoff: CALLS_COUNT, AVERAGE_SENTIMENT (null when no calls), LOWEST_SENTIMENT, NEGATIVE_CALLS (sentiment below -0.3), RIVAL_MENTIONS (calls with a non-null COMPETITOR_MENTIONED), CANCEL_INTENT_CALLS (WANTS_TO_CANCEL true), LAST_CALL_DATE, DAYS_SINCE_LAST_CALL (days from LAST_CALL_DATE to 2026-06-30, null when no calls).
  - Counts are 0 (not null) when the customer has no rows. Aggregate each source table in its own subquery or CTE by CUSTOMER_ID and left join everything to CUSTOMERS so no row is duplicated or dropped.
  - HARD RULES against leaking the future: only use rows dated on or before 2026-06-30. The only place a cancellation may be used is POLICIES.CANCELLATION_DATE on or before 2026-06-30. Never use a cancellation date or reason after 2026-06-30, and never create any column that says whether the customer later churned.

02_create_churn_labels.sql
  A separate table RETENTION_COPILOT.ANALYTICS.CHURN_LABELS with CUSTOMER_ID and CHURNED_WITHIN_90_DAYS (boolean) for customers with IS_ACTIVE_AT_CUTOFF true only: true when any of their policies has a CANCELLATION_DATE between 2026-07-01 and 2026-09-28, otherwise false. Use CREATE OR REPLACE TABLE ... AS SELECT and take the active customers from ANALYTICS.CUSTOMER_PROFILE.

03_check_customer_profile.sql
  Read only checks, each as its own statement, that run as one file:
  - rows in CUSTOMER_PROFILE (expect 5,000), rows with a null CUSTOMER_ID (0), duplicate CUSTOMER_ID (0);
  - customers with IS_ACTIVE_AT_CUTOFF true and false;
  - rows in CHURN_LABELS, and the churn rate as a percent (expect 15 to 25);
  - the latest LAST_CALL_DATE in the profile (must not be after 2026-06-30), and negative TENURE_MONTHS (0);
  - for each numeric feature column, the count of nulls;
  - for churned versus stayed customers (join CHURN_LABELS to CUSTOMER_PROFILE), the average of LATE_OR_FAILED_RATE, AVERAGE_SENTIMENT, TICKETS_COUNT, AVERAGE_SATISFACTION, RIVAL_MENTIONS, CANCEL_INTENT_CALLS and TOTAL_MONTHLY_PREMIUM (churned should be clearly worse on the first ones but the two groups must overlap, so no feature may separate them perfectly);
  - 3 sample rows with names, city, segment and the main features;
  - the dynamic table state from show dynamic tables (name, target lag, refresh mode, scheduling state).

Coding rules for every file, strict: no comments of any kind, one job per file, short files (split a long query into CTEs inside the one file, keep each file under about 150 lines), plain names, upper case object names, lower case keywords, fully qualified table names. Each file must run exactly as saved. Do not change account level settings. Do not touch other schemas.

Final answer, short: files written, whether each ran as saved, the full output of the checks, and anything you changed or that failed.
