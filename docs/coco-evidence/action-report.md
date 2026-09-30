Reading the data brief first.Good. Now let me inspect the CUSTOMER_PROFILE table columns before writing any SQL.Good, I have all the column info. Let me set up the todo list and write all five files.Running files 01, 02, 03 in sequence now.Quick sanity check on the view before creating the procedure.1,391 unique customers — exactly right. Now creating the procedure.All three DDL statements succeeded. Now running the 30-row pilot.All 30 fell to templates — likely the raw response extraction path failed. Let me run the checks and also inspect one raw response before reporting.Found the issue. The response uses `:choices[0]:messages` (a string directly), not `:choices[0]:message:content`. The extraction path was wrong. Fixing the procedure now.Also updating the saved file to match.Now re-running the pilot.All 30 from the model. Now running all check statements.Pilot passes all checks — 0 forbidden words, 0 empty drafts, 30 unique model drafts. Conditions met; running the full 1,391-customer run now. This will take a few minutes.All 1,391 from the model. Running the final check suite.52 rows have an empty required field — let me find which one.52 rows have empty REASON — likely customers with null CHURN_PROBABILITY. Let me check.`array_to_string(array_compact(...))` works correctly — Snowflake's `concat_ws` with `nullif` collapses to NULL when the last argument is NULL. Need to update both the view and the procedure to use the array approach. Let me fix both.Now redeploy both objects and re-run.Now re-running the 30-row pilot to confirm the REASON fix.REASON is clean. Now running the full suite.All 1,391 from the model. Running the complete 05 check suite now.All five files written and all runs succeeded. Here is the full report.

---

## Files written

| File | Status |
|---|---|
| `01_create_recommended_actions_table.sql` | Ran as saved — table created |
| `02_create_action_rules_view.sql` | Ran as saved — view created (patched after REASON bug found) |
| `03_create_action_writer_procedure.sql` | Ran as saved — procedure created (patched twice: response path + driver join) |
| `04_write_actions.sql` | Ran as saved |
| `05_check_actions.sql` | Ran as saved |

---

## Pilot output (30 rows)

| Check | Result |
|---|---|
| Row count | 30 |
| Action types | 6 present (Escalate open ticket 9, Payment plan offer 7, Claims follow-up call 6, Loyalty check-in 6, Retention offer callback 1, Service recovery call 1) |
| Confidence/Status | High/Pending 9, Medium/Pending 14, Low/Needs review 7 |
| Draft source | model 30, template 0 |
| Forbidden words | **0** |
| Draft lengths | min 453, avg 497, max 573 chars |
| Duplicate CUSTOMER_IDs | **0** |
| Empty required fields | **0** |
| Revenue at risk | ₹9,958,494.28 |

---

## Full run output (1,391 rows)

| Check | Result |
|---|---|
| Row count | 1,391 |
| Action types | Payment plan offer 474, Escalate open ticket 321, Loyalty check-in 209, Claims follow-up call 198, Service recovery call 100, Retention offer callback 89 |
| Confidence/Status | High/Pending 350, Medium/Pending 696, Low/Needs review 345 |
| Draft source | model 1,391, template 0 |
| Forbidden words | **0** |
| Draft lengths | min 419, avg 504, max 621 chars |
| Duplicate CUSTOMER_IDs | **0** |
| Empty required fields | **0** |
| Total REVENUE_AT_RISK | ₹32,664,300.22 |

---

## Issues found and fixed

**Two bugs encountered:**

1. **Wrong response path (first run):** `SNOWFLAKE.CORTEX.COMPLETE` with the message-array form returns `choices[0]:messages` (a plain string), not `choices[0]:message:content`. The first pilot had 0 model drafts because every extraction was NULL. Fixed by correcting the path; subsequent runs returned 100% model drafts.

2. **`concat_ws` with `nullif` collapses to NULL (Snowflake quirk):** When the last argument to `concat_ws` is `nullif(col, '')` and that column is an empty string, Snowflake returns NULL for the entire `concat_ws` call even though earlier arguments are non-null. This affected 52 rows in the first full run where REASON came back NULL. Fixed by replacing `concat_ws('; ', nullif(...), ...)` with `array_to_string(array_compact(array_construct(nullif(...), ...)), '; ')`, which correctly ignores NULLs. Both the view and procedure files were updated and re-deployed before the final run.

The final full run is clean on all ten checks.