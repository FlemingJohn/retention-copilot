Reading the data brief first.Now let me describe the raw tables to understand column names before writing SQL.Now I have all column info. Writing the three SQL files.Now running file 01.File 01 ran. Now file 02.Now file 03 — running each check statement.All three files written and ran successfully. Here is the summary:

---

**Files written**

| File | Lines | Ran |
|---|---|---|
| `snowflake/customer-profile/01_create_customer_profile.sql` | 127 | ✓ |
| `snowflake/customer-profile/02_create_churn_labels.sql` | 16 | ✓ |
| `snowflake/customer-profile/03_check_customer_profile.sql` | 63 | ✓ |

---

**Check results**

| Check | Result | Pass? |
|---|---|---|
| Rows in CUSTOMER_PROFILE | 5,000 | ✓ |
| Null CUSTOMER_ID | 0 | ✓ |
| Duplicate CUSTOMER_ID | 0 | ✓ |
| IS_ACTIVE_AT_CUTOFF true / false | 4,636 / 364 | ✓ |
| Rows in CHURN_LABELS | 4,636 | ✓ |
| Churn rate | **20.82%** (target 15–25) | ✓ |
| Latest LAST_CALL_DATE | 2026-06-29 (≤ cutoff) | ✓ |
| Negative TENURE_MONTHS | 0 | ✓ |
| Null counts — counts/premiums/tickets | 0 | ✓ |
| Null LATE_OR_FAILED_RATE | 19 (customers with no payments) | expected |
| Null AVERAGE_DAYS_LATE | 2,469 (no late payments) | expected |
| Null AVERAGE_RESOLUTION_DAYS | 4,044 (no resolved claims) | expected |
| Null AVERAGE/LOWEST_SATISFACTION | 2,756 (no tickets) | expected |
| Null AVERAGE_SENTIMENT / DAYS_SINCE_LAST_CALL | 4,143 (no calls) | expected |

**Feature separation (churned vs stayed):**

| Feature | Stayed | Churned | Direction |
|---|---|---|---|
| late_or_failed_rate | 0.1419 | 0.2126 | churned worse ✓ |
| average_sentiment | 0.1649 | −0.0497 | churned worse ✓ |
| tickets_count | 0.72 | 1.11 | churned worse ✓ |
| average_satisfaction | 3.44 | 3.08 | churned worse ✓ |
| rival_mentions | 0.0147 | 0.0352 | churned worse ✓ |
| cancel_intent_calls | 0.0172 | 0.0238 | churned worse ✓ |
| total_monthly_premium | 5,157 | 5,423 | slight diff, overlap confirmed ✓ |

No feature separates groups perfectly — all overlap confirmed.

**Dynamic table state:** `ACTIVE`, refresh mode `FULL` (auto-selected by Snowflake due to LISTAGG DISTINCT), target lag `1 day`, warehouse `RETENTION_COPILOT_WH`, scheduling state `ACTIVE`.

Nothing changed or failed. The `FULL` refresh mode was chosen automatically by Snowflake (vs incremental) because of the `LISTAGG DISTINCT` expression; the table still refreshes correctly on the 1-day schedule.