Let me read the project brief and look up the required Snowflake syntax in parallel.Now let me look up the exact DDL syntax for semantic views and Cortex Search.Let me fetch the Snowflake documentation directly.Now let me look up Cortex Search Service and Cortex Analyst roles.Now I have the Cortex Analyst access control info. Let me find the Cortex Search Service syntax.Now I have all the syntax I need. Let me check the directory structure before writing the files.The `semantic-layer` subdirectory doesn't exist yet. Let me set up the task tracker and write all six files.Now writing the semantic view — the most complex file:Now I'll execute the files in order. Starting with the two views:Both views created. Now quick row count check before the semantic view:Both row counts match (4,636 and 1,000). Now executing the semantic view:Semantic view created. Now the Cortex Search service (this builds the index synchronously):The CALL_OVERVIEW view depends on a dynamic table somewhere in its lineage. Let me check which table is the dynamic table and then rewrite the search service to query the base tables directly.CUSTOMER_PROFILE is a dynamic table. I need to check if CALL_INSIGHTS is also a dynamic table, then rewrite the search service query to use base tables directly.CUSTOMER_PROFILE is the dynamic table causing the issue. I need to rewrite file 04 to bypass CALL_OVERVIEW and join the base tables (CALL_INSIGHTS, CALL_TRANSCRIPTS, RAW.CUSTOMERS) directly, avoiding CUSTOMER_PROFILE entirely.Search service created. Now executing the grants:All grants applied. Now running the full check file (06) statement by statement:The SEARCH_PREVIEW result is returned as VARCHAR (not VARIANT), so I need `parse_json`. Let me fix the check query:The query string needs to be in JSON format for user-defined Cortex Search services. Let me fix:The first attempt had correct SEARCH_PREVIEW syntax — the issue was just in parsing the VARCHAR result. Let me fix just the FLATTEN part:The underlying `SYSTEM$CORTEX_SEARCH_QUERY` works. The second argument must be a JSON options object, not a plain query string. Let me update the check file and run the corrected version:Let me verify if SNOWFLAKE.CORTEX.SEARCH_PREVIEW works when given the JSON options format:`SNOWFLAKE.CORTEX.SEARCH_PREVIEW` works when the second argument is a JSON options object, not a plain string. Now let me update file 06 with the correct syntax and run the final check:Now the final check — show grants to role to confirm no RAW/ANALYTICS/GENERATOR access:Everything is verified. Here is the complete summary.

---

## Files written and execution status

| File | Status |
|------|--------|
| `01_create_customer_overview_view.sql` | Ran as saved — `View CUSTOMER_OVERVIEW successfully created` |
| `02_create_call_overview_view.sql` | Ran as saved — `View CALL_OVERVIEW successfully created` |
| `03_create_semantic_view.sql` | Ran as saved — `Semantic view CHURN_SEMANTIC_VIEW successfully created` |
| `04_create_call_search_service.sql` | Needed one fix (see below), then ran — `Cortex search service CALL_SEARCH successfully created` |
| `05_grant_reader_access.sql` | Ran as saved — all 5 GRANT statements succeeded |
| `06_check_semantic_layer.sql` | Needed one fix (see below), then ran — all checks pass |

---

## Full check output

**Row counts** — CUSTOMER_OVERVIEW: **4,636** ✓ / CALL_OVERVIEW: **1,000** ✓

**Forbidden column check** — `SELECT TABLE_NAME, COLUMN_NAME … IN ('LAST_NAME','EMAIL','PHONE')` → **0 rows** ✓

**SHOW SEMANTIC VIEWS** — 1 row: `CHURN_SEMANTIC_VIEW` in `RETENTION_COPILOT.APP` ✓

**DESCRIBE SEMANTIC VIEW** — 203 rows covering all tables, relationship, 3 facts, 14 dimensions, 13 metrics, 1 AI_SQL_GENERATION instruction, 3 AI_VERIFIED_QUERIES ✓

**SEMANTIC_VIEW query 1 — customer count by risk tier:**
```
Low: 3,245  /  Medium: 927  /  High: 464
```

**SEMANTIC_VIEW query 2 — revenue at risk by action type:**
```
Payment plan offer: 8,235,111.16
Escalate open ticket: 8,162,426.92
Loyalty check-in: 5,687,909.88
… (6 action types total including NULL for Low-risk customers)
```

**SEMANTIC_VIEW query 3 — calls mentioning rival by insurer:**
```
Bajaj Allianz: 17 / Star Health: 16 / HDFC Life: 12 / LIC: 11 / ICICI Lombard: 13 / Tata AIG: 10 / SBI Life: 15
```

**Cortex Search preview** — 3 results returned for `'customer says another insurer is cheaper'`:
```
CALL000130 | praise or thanks       | Bajaj Allianz
CALL000467 | premium or price complaint |
CALL000171 | praise or thanks       |
```

**SHOW GRANTS TO ROLE RETENTION_COPILOT_READER** — 8 grants, all in `RETENTION_COPILOT.APP`:
- `USAGE` on `RETENTION_COPILOT.APP.CALL_SEARCH` (cortex search service)
- `USAGE` on `RETENTION_COPILOT` (database)
- `USAGE` on `SNOWFLAKE.CORTEX_ANALYST_USER` (database role)
- `USAGE` on `RETENTION_COPILOT.APP` (schema)
- `SELECT` on `RETENTION_COPILOT.APP.CHURN_SEMANTIC_VIEW` (semantic view)
- `SELECT` on `RETENTION_COPILOT.APP.CALL_OVERVIEW` (view)
- `SELECT` on `RETENTION_COPILOT.APP.CUSTOMER_OVERVIEW` (view)
- `USAGE` on `RETENTION_COPILOT_WH` (warehouse)

**No grants on RAW, ANALYTICS, or GENERATOR objects** ✓

---

## Roles granted and why

| Grant | Reason |
|-------|--------|
| `SELECT ON VIEW CUSTOMER_OVERVIEW` | App reads the customer list and churn data |
| `SELECT ON VIEW CALL_OVERVIEW` | App reads call history and transcript text |
| `SELECT ON SEMANTIC VIEW CHURN_SEMANTIC_VIEW` | Cortex Analyst needs this to resolve questions against the semantic layer |
| `USAGE ON CORTEX SEARCH SERVICE CALL_SEARCH` | Required so the role can query the search index; also required when Cortex Analyst references the service |
| `DATABASE ROLE SNOWFLAKE.CORTEX_ANALYST_USER` | Narrowest documented role that authorises calls to the Cortex Analyst API and Cortex REST API; does not include broader LLM or embedding functions |

---

## Issues encountered and resolved

**File 04 — dynamic table restriction.** `CUSTOMER_PROFILE` in `ANALYTICS` is a dynamic table. Cortex Search Services cannot read from views that contain dynamic tables. The fix was to rewrite the `AS` query to join `ANALYTICS.CALL_INSIGHTS`, `RAW.CALL_TRANSCRIPTS`, and `RAW.CUSTOMERS` directly, bypassing `CUSTOMER_PROFILE` entirely. The `CALL_OVERVIEW` view is unchanged and continues to join `CUSTOMER_PROFILE` (which is fine for a regular view).

**File 06 — `SNOWFLAKE.CORTEX.SEARCH_PREVIEW` query format.** For user-created Cortex Search Services, the second argument to `SEARCH_PREVIEW` must be a JSON options object `{"query": "…", "columns": […], "limit": N}`, not a plain query string. A plain string raises `unexpected argument at position 1`. The file was updated to pass a JSON string and wrap the return value in `parse_json()` before flattening the `results` array.