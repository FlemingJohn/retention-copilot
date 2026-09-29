You are in the DEVELOPMENT and EXECUTION phase of a hackathon project called Retention Copilot. Your working directory is the project root. Write the setup SQL as files in the folder snowflake/setup, then run each file in order against the connected Snowflake account with the SQL tool, as ACCOUNTADMIN. Do not read any other project files. Do not run shell commands.

Coding rules for the files you write. They are strict:
- No comments of any kind in the SQL. No lines starting with two dashes, no block comments.
- One job per file. Files are short.
- Plain names, no abbreviations in object names beyond the ones specified below.
- Make each file safe to run twice: use IF NOT EXISTS or CREATE OR REPLACE where that is safe.
- Use upper case object names and lower case keywords.

Create exactly these files, in this order, with these names:

01_create_database.sql
  Create database RETENTION_COPILOT.

02_create_schemas.sql
  Create schemas RAW, ANALYTICS and APP in RETENTION_COPILOT.

03_create_resource_monitor.sql
  Create resource monitor RETENTION_COPILOT_MONITOR with a credit quota of 100, frequency NEVER reset is not needed, notify at 75 percent and suspend at 100 percent.

04_create_warehouse.sql
  Create warehouse RETENTION_COPILOT_WH, size XSMALL, auto suspend 60 seconds, auto resume on, initially suspended, attached to RETENTION_COPILOT_MONITOR. It must be a Gen2 warehouse, which is the only kind this account allows, so do not set any generation or resource constraint property.

05_create_roles.sql
  Create roles RETENTION_COPILOT_ADMIN and RETENTION_COPILOT_READER.

06_grant_access.sql
  RETENTION_COPILOT_ADMIN: all privileges on database RETENTION_COPILOT and on its three schemas and future objects in them, and usage and operate on the warehouse.
  RETENTION_COPILOT_READER: usage on the database, usage on schema APP only, select on all current and future tables and views in APP only, and usage on the warehouse. It gets nothing on RAW or ANALYTICS.
  Grant both roles to the user FLEMINGJOHN21 and grant RETENTION_COPILOT_ADMIN to role SYSADMIN.

07_check_setup.sql
  Read-only checks that print: the schemas in the database, the warehouse with its size, auto suspend and monitor, the grants held by each of the two roles.

Run 01 to 06 in order, then run 07 and show its output. If any statement fails, stop, report the exact error and do not work around it by changing account level settings.

Final answer, short: the list of files written, whether each ran successfully, and the output of the checks. Report honestly anything that did not work.
