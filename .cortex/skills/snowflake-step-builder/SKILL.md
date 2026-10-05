---
name: snowflake-step-builder
description: "Build one self-contained Snowflake pipeline step as numbered SQL files, run them in order, and prove they worked. Use when: building a step of a Snowflake data or AI project (setup, data generation, enrichment, model, semantic layer, agent, automation, governance) through CoCo CLI. Triggers: build a snowflake step, write numbered sql files, create step folder, run sql files in order, add a check file, additive snowflake change."
---

# Snowflake Step Builder

One step of a Snowflake project is one folder of numbered SQL files, each run in order, ending in a check file that proves the step worked. This skill is the routine that kept ten such steps reliable.

## Before writing anything

1. Read the one project brief the prompt names. Read nothing else unless the prompt says so.
2. Work only inside the step folder named in the prompt, for example `snowflake/<step-name>/`.
3. For every existing table or view you will touch, run `describe table` or `describe view` first and use the real column names. Never guess a column.
4. If a Snowflake feature's syntax is not certain, search Snowflake's documentation. Do not write from memory.

## Writing the files

- Name files `NN_verb_the_thing.sql`, for example `02_create_enrich_new_calls_procedure.sql`. The number is the run order.
- One job per file. A file that creates a table and loads it is two files.
- No comments in the SQL. Fix the names instead.
- Plain names, no abbreviations: `CHURN_PROBABILITY`, not `CHURN_PROB`.
- Use `create ... if not exists` for things that must survive a rerun. Use `create or replace` only for views and procedures.
- Be additive. Never alter, drop or rewrite an object that an earlier step created unless the prompt asks for it.
- Keep long-running or costly work out of the check files.

## Running the files

1. Run each file in number order with the SQL tool.
2. Run one statement at a time when a file has several. Snowsight style batches hide which statement failed.
3. When a file fails, fix the file, save it, and rerun it. The files on disk must always match what actually ran.
4. If you had to change a file after a failure, say so in the report.

## The check file

The last file of every step is `NN_check_<step>.sql`. It only reads. It must show, with numbers:

- Row counts for every table the step filled, compared with the expected count.
- State of any task, stream, dynamic table or service the step created.
- For governance steps, the result of querying as a low-privilege role.

A check that cannot fail proves nothing. Include at least one condition that would show a wrong result, such as a count that must equal another count.

## Safety rules

- Never read from a schema the prompt marks off limits.
- Never put personal columns (last name, email, phone) into anything a web app or agent can read. Use masking policies, or leave them out of the view.
- Do not run an account-wide setting change unless the prompt says to. Write it as a script and mark it not executed.
- Never print or save a token or password. Redact it if it appears in output.
- Keep the warehouse at the smallest size. Save results of expensive AI functions into a table. Never recompute them per query.
- Test automation on one row, then clean the test row up and confirm the counts returned to normal.

## The report

End with a short report that has only facts from this run:

| File | Ran as saved (yes or no) | Notes |
|---|---|---|

Then the check output, the fixes you made and why, and a line listing what you did not change. Do not write "all checks passed" without showing the numbers.
