You are in the DEVELOPMENT and EXECUTION phase of a hackathon project called Retention Copilot. Your working directory is the project root. Read exactly one project file first: docs/synthetic-data-brief.md. It defines the data. Follow it closely. Do not read other project files. Do not run shell commands.

Write SQL and Python files into the folder snowflake/synthetic-data and run each with the SQL tool against the connected account as ACCOUNTADMIN, using warehouse RETENTION_COPILOT_WH. The database RETENTION_COPILOT and schemas RAW, ANALYTICS and APP already exist.

Coding rules for every file, strict:
- No comments of any kind.
- One job per file, short files. A procedure or function is its own file.
- Plain names, no abbreviations in object names.
- Safe to run twice: IF NOT EXISTS or CREATE OR REPLACE where sensible. Table creation files use CREATE OR REPLACE TABLE so a rerun starts clean.
- Upper case object names, lower case keywords.

Stage 1 covers only the schema, the six tables, the hidden mood, customers and policies. Create these files in this order and run each:

01_create_generator_schema.sql   schema RETENTION_COPILOT.GENERATOR, and grant nothing on it to the reader role.
02_create_customers_table.sql    RAW.CUSTOMERS with the columns and types in the brief.
03_create_policies_table.sql     RAW.POLICIES.
04_create_payments_table.sql     RAW.PAYMENTS.
05_create_claims_table.sql       RAW.CLAIMS.
06_create_tickets_table.sql      RAW.SERVICE_TICKETS.
07_create_transcripts_table.sql  RAW.CALL_TRANSCRIPTS.
08_create_mood_table.sql         GENERATOR.CUSTOMER_MOOD with CUSTOMER_ID and MOOD.
09_create_person_function.sql    A Python user defined function, using the faker package with the en_IN locale, that takes a whole number seed and returns an object with first name, last name, email, phone, address line, city, state and 6 digit pincode. The same seed must always return the same person. Test that it runs.
10_generate_customers.sql        Insert 5000 customers with ids C000001 to C005000, people from the function above, dates of birth between ages 21 and 70, customer since dates from 2016-01-01 to 2026-06-30, and about 3 percent of emails and phones set to null. Insert 5000 moods into the mood table, skewed so most customers are content, for example a beta distribution weighted toward low values. Set SEGMENT as Gold, Silver or Standard from tenure and total premium after policies exist, in the next file, not here: leave it as Standard for now.
11_generate_policies.sql         Insert about 8000 policies, 1 to 3 per customer, with product types Motor, Health, Life, Home, Travel, monthly premiums in rupees with a few very large ones, coverage amounts, start dates after the customer since date and on or before 2026-06-30, and renewal dates. Then decide churn as described in the brief: about 8 percent of all customers churned before the cutoff, with cancellation dates between 2026-01-01 and 2026-06-30 and a planted spike of about three times the normal rate during 2026-05-11 to 2026-05-17. Among customers still active at the cutoff about 20 percent churn, decided by a coin flip weighted by the customer's mood plus small effects from tenure, premium size and product type, with cancellation dates between 2026-07-01 and 2026-09-28 on all of that customer's policies. Give every cancellation a reason. Never use a plain threshold on mood.
12_assign_segments.sql           Update SEGMENT to Gold, Silver or Standard from total monthly premium and tenure at 2026-06-30 only, never from cancellations.
13_check_stage_one.sql           Read-only checks: row counts of CUSTOMERS, POLICIES and CUSTOMER_MOOD, churn rate among customers active at 2026-06-30 (must be between 15 and 25 percent), share of customers who churned before the cutoff, cancellations per day around 2026-05-11 to 2026-05-17 compared with a normal week, count of policies whose start date is after the cutoff (must be 0), count of orphan policies (must be 0), and the churn rate for customers with mood below 0.3 versus above 0.7 (the second must be clearly higher but neither may be 0 or 100 percent).

If a check fails, say which one and by how much. You may adjust the generator once to fix it. Do not change account level settings. Do not touch other schemas.

Final answer, short: files written, whether each ran, and the full output of the checks in 13. Report honestly anything that did not work or that you had to change.
