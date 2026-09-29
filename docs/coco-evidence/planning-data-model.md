I'll start by exploring the Snowflake account to understand what's already available.The SQL calls were denied. Let me try them individually.Let me try the SHOW WAREHOUSES command once more.Good, I have everything I need. The account is fresh (created today) with no project-specific objects yet.

**Account summary:**
- **Databases:** COCO_APP, SNOWFLAKE, SNOWFLAKE_LEARNING_DB, SNOWFLAKE_SAMPLE_DATA, USER$FLEMINGJOHN21
- **Warehouses:** COMPUTE_WH (XS, Gen2, running), SNOWFLAKE_LEARNING_WH (XS, suspended), SYSTEM$STREAMLIT_NOTEBOOK_WH (XS, suspended)
- **Current context:** ACCOUNTADMIN / FLEMINGJOHN21 / COMPUTE_WH
- **Notable:** All warehouses are Gen2. No custom roles or project databases exist yet.

Here is the data model document:

---

# Retention Copilot — Data Model

## 1. Account Inventory

| Category | Items |
|---|---|
| **Databases** | `COCO_APP`, `SNOWFLAKE`, `SNOWFLAKE_LEARNING_DB`, `SNOWFLAKE_SAMPLE_DATA`, `USER$FLEMINGJOHN21` |
| **Warehouses** | `COMPUTE_WH` (XS, Gen2, active), `SNOWFLAKE_LEARNING_WH` (XS, suspended), `SYSTEM$STREAMLIT_NOTEBOOK_WH` (XS, suspended) |
| **Current role** | `ACCOUNTADMIN` |
| **Relevant custom roles** | None yet — all roles are system-default or Snowflake-internal |

No project database or custom roles exist. Everything must be created from scratch.

---

## 2. Proposed Database & Schema Layout

**Database:** `RETENTION_COPILOT`

| Schema | Purpose |
|---|---|
| `RAW` | Raw / seed tables (CUSTOMERS, POLICIES, PAYMENTS, CLAIMS, SERVICE_TICKETS, CALL_TRANSCRIPTS) |
| `ANALYTICS` | Derived / enriched tables (CALL_INSIGHTS, CUSTOMER_PROFILE, CHURN_SCORES, RECOMMENDED_ACTIONS) |
| `APP` | Views and objects exposed to the Streamlit application |

---

## 3. Proposed Roles

| Role | Grants | Purpose |
|---|---|---|
| `RETENTION_COPILOT_ADMIN` | ALL on database `RETENTION_COPILOT`; USAGE on `COMPUTE_WH` | Full DDL/DML for setup, data loading, model training |
| `RETENTION_COPILOT_READER` | USAGE on database + all schemas; SELECT on all tables/views in `ANALYTICS` and `APP`; USAGE on `COMPUTE_WH` | Read-only access for the Streamlit app and end-users |

Both roles should be granted to `SYSADMIN` for administrative inheritance.

---

## 4. Raw Tables — `RETENTION_COPILOT.RAW`

### 4.1 CUSTOMERS

One row per customer. Central entity that every other table references.

| Column | Type | Constraints | PII | Notes |
|---|---|---|---|---|
| `CUSTOMER_ID` | `VARCHAR(36)` | **PK** | | UUID |
| `FIRST_NAME` | `VARCHAR(100)` | NOT NULL | **Yes** | |
| `LAST_NAME` | `VARCHAR(100)` | NOT NULL | **Yes** | |
| `EMAIL` | `VARCHAR(255)` | NOT NULL | **Yes** | |
| `PHONE` | `VARCHAR(30)` | | **Yes** | |
| `DATE_OF_BIRTH` | `DATE` | | **Yes** | |
| `ADDRESS` | `VARCHAR(500)` | | **Yes** | |
| `STATE` | `VARCHAR(2)` | | | US state code |
| `ZIPCODE` | `VARCHAR(10)` | | | |
| `CUSTOMER_SINCE` | `DATE` | NOT NULL | | Enrollment date |
| `SEGMENT` | `VARCHAR(20)` | | | e.g. Individual, Small-Biz |
| `IS_ACTIVE` | `BOOLEAN` | DEFAULT TRUE | | Current active status |
| `CREATED_AT` | `TIMESTAMP_NTZ` | DEFAULT CURRENT_TIMESTAMP | | |
| `UPDATED_AT` | `TIMESTAMP_NTZ` | DEFAULT CURRENT_TIMESTAMP | | |

### 4.2 POLICIES

Insurance policies held by a customer. A customer can have many policies.

| Column | Type | Constraints | PII | Notes |
|---|---|---|---|---|
| `POLICY_ID` | `VARCHAR(36)` | **PK** | | UUID |
| `CUSTOMER_ID` | `VARCHAR(36)` | **FK → CUSTOMERS** | | |
| `PRODUCT_TYPE` | `VARCHAR(50)` | NOT NULL | | Auto, Home, Life, Health, etc. |
| `POLICY_STATUS` | `VARCHAR(20)` | NOT NULL | | Active, Lapsed, Cancelled, Renewed |
| `PREMIUM_MONTHLY` | `NUMBER(12,2)` | | | Monthly premium amount |
| `COVERAGE_AMOUNT` | `NUMBER(14,2)` | | | |
| `START_DATE` | `DATE` | NOT NULL | | |
| `END_DATE` | `DATE` | | | NULL if open-ended |
| `RENEWAL_DATE` | `DATE` | | | Next renewal |
| `CANCELLATION_DATE` | `DATE` | | | NULL unless cancelled |
| `CANCELLATION_REASON` | `VARCHAR(200)` | | | |
| `CREATED_AT` | `TIMESTAMP_NTZ` | DEFAULT CURRENT_TIMESTAMP | | |

### 4.3 PAYMENTS

Payment transactions against policies. Tracks payment health for churn signals.

| Column | Type | Constraints | PII | Notes |
|---|---|---|---|---|
| `PAYMENT_ID` | `VARCHAR(36)` | **PK** | | UUID |
| `CUSTOMER_ID` | `VARCHAR(36)` | **FK → CUSTOMERS** | | |
| `POLICY_ID` | `VARCHAR(36)` | **FK → POLICIES** | | |
| `PAYMENT_DATE` | `DATE` | NOT NULL | | |
| `DUE_DATE` | `DATE` | NOT NULL | | |
| `AMOUNT` | `NUMBER(12,2)` | NOT NULL | | |
| `PAYMENT_METHOD` | `VARCHAR(30)` | | | Card, ACH, Check |
| `STATUS` | `VARCHAR(20)` | NOT NULL | | Completed, Failed, Pending, Refunded |
| `DAYS_LATE` | `INT` | DEFAULT 0 | | Computed: PAYMENT_DATE − DUE_DATE |
| `CREATED_AT` | `TIMESTAMP_NTZ` | DEFAULT CURRENT_TIMESTAMP | | |

### 4.4 CLAIMS

Insurance claims filed by customers. Claim frequency and severity feed churn models.

| Column | Type | Constraints | PII | Notes |
|---|---|---|---|---|
| `CLAIM_ID` | `VARCHAR(36)` | **PK** | | UUID |
| `CUSTOMER_ID` | `VARCHAR(36)` | **FK → CUSTOMERS** | | |
| `POLICY_ID` | `VARCHAR(36)` | **FK → POLICIES** | | |
| `CLAIM_DATE` | `DATE` | NOT NULL | | |
| `CLAIM_TYPE` | `VARCHAR(50)` | | | Accident, Theft, Liability, etc. |
| `CLAIM_AMOUNT` | `NUMBER(14,2)` | | | |
| `SETTLEMENT_AMOUNT` | `NUMBER(14,2)` | | | |
| `STATUS` | `VARCHAR(20)` | NOT NULL | | Open, Approved, Denied, Settled |
| `RESOLUTION_DATE` | `DATE` | | | |
| `RESOLUTION_DAYS` | `INT` | | | Days from filing to resolution |
| `CREATED_AT` | `TIMESTAMP_NTZ` | DEFAULT CURRENT_TIMESTAMP | | |

### 4.5 SERVICE_TICKETS

Customer service interactions. Ticket volume and unresolved issues signal churn risk.

| Column | Type | Constraints | PII | Notes |
|---|---|---|---|---|
| `TICKET_ID` | `VARCHAR(36)` | **PK** | | UUID |
| `CUSTOMER_ID` | `VARCHAR(36)` | **FK → CUSTOMERS** | | |
| `CHANNEL` | `VARCHAR(20)` | | | Phone, Email, Chat, Web |
| `CATEGORY` | `VARCHAR(50)` | | | Billing, Claims, Coverage, General |
| `PRIORITY` | `VARCHAR(10)` | | | Low, Medium, High, Critical |
| `STATUS` | `VARCHAR(20)` | NOT NULL | | Open, In-Progress, Resolved, Escalated |
| `OPENED_AT` | `TIMESTAMP_NTZ` | NOT NULL | | |
| `RESOLVED_AT` | `TIMESTAMP_NTZ` | | | |
| `RESOLUTION_HOURS` | `FLOAT` | | | Hours to resolve |
| `SATISFACTION_SCORE` | `INT` | | | 1-5 CSAT |
| `CREATED_AT` | `TIMESTAMP_NTZ` | DEFAULT CURRENT_TIMESTAMP | | |

### 4.6 CALL_TRANSCRIPTS

Raw call-center transcripts. Fed into Cortex LLM functions to produce CALL_INSIGHTS.

| Column | Type | Constraints | PII | Notes |
|---|---|---|---|---|
| `TRANSCRIPT_ID` | `VARCHAR(36)` | **PK** | | UUID |
| `CUSTOMER_ID` | `VARCHAR(36)` | **FK → CUSTOMERS** | | |
| `TICKET_ID` | `VARCHAR(36)` | **FK → SERVICE_TICKETS** | | Optional link to a ticket |
| `CALL_DATE` | `TIMESTAMP_NTZ` | NOT NULL | | |
| `DURATION_SECONDS` | `INT` | | | |
| `AGENT_ID` | `VARCHAR(36)` | | | Call-center agent |
| `TRANSCRIPT_TEXT` | `VARCHAR(16777216)` | NOT NULL | **Yes** | Full transcript; may contain PII |
| `CREATED_AT` | `TIMESTAMP_NTZ` | DEFAULT CURRENT_TIMESTAMP | | |

---

## 5. Derived Tables — `RETENTION_COPILOT.ANALYTICS`

### 5.1 CALL_INSIGHTS

One row per transcript. Produced by running Cortex AI functions (AI_SENTIMENT, AI_EXTRACT, AI_CLASSIFY) over CALL_TRANSCRIPTS.

| Column | Type | Constraints | PII | Notes |
|---|---|---|---|---|
| `TRANSCRIPT_ID` | `VARCHAR(36)` | **PK, FK → CALL_TRANSCRIPTS** | | |
| `CUSTOMER_ID` | `VARCHAR(36)` | **FK → CUSTOMERS** | | |
| `SENTIMENT_SCORE` | `FLOAT` | | | −1.0 (negative) to +1.0 (positive) |
| `SENTIMENT_LABEL` | `VARCHAR(20)` | | | Positive, Neutral, Negative |
| `COMPLAINT_REASON` | `VARCHAR(200)` | | | Extracted primary complaint |
| `COMPETITOR_MENTIONED` | `VARCHAR(100)` | | | Competitor name if mentioned, else NULL |
| `INTENT` | `VARCHAR(50)` | | | Cancel, Downgrade, Inquiry, Praise |
| `SUMMARY` | `VARCHAR(2000)` | | | LLM-generated call summary |
| `PROCESSED_AT` | `TIMESTAMP_NTZ` | DEFAULT CURRENT_TIMESTAMP | | |

### 5.2 CUSTOMER_PROFILE

One row per customer. Wide table joining all raw sources into a customer-360 feature vector for the churn model and the application UI.

| Column | Type | Constraints | PII | Notes |
|---|---|---|---|---|
| `CUSTOMER_ID` | `VARCHAR(36)` | **PK, FK → CUSTOMERS** | | |
| `FIRST_NAME` | `VARCHAR(100)` | | **Yes** | |
| `LAST_NAME` | `VARCHAR(100)` | | **Yes** | |
| `EMAIL` | `VARCHAR(255)` | | **Yes** | |
| `STATE` | `VARCHAR(2)` | | | |
| `CUSTOMER_SINCE` | `DATE` | | | |
| `TENURE_MONTHS` | `INT` | | | Months since enrollment |
| `IS_ACTIVE` | `BOOLEAN` | | | |
| `ACTIVE_POLICIES` | `INT` | | | Count of active policies |
| `TOTAL_PREMIUM_MONTHLY` | `NUMBER(12,2)` | | | Sum of active monthly premiums |
| `PRODUCTS_HELD` | `VARCHAR(500)` | | | Comma-separated product types |
| `TOTAL_PAYMENTS` | `INT` | | | Lifetime payment count |
| `LATE_PAYMENTS_12M` | `INT` | | | Late payments in last 12 months |
| `FAILED_PAYMENTS_12M` | `INT` | | | Failed payments in last 12 months |
| `TOTAL_CLAIMS` | `INT` | | | Lifetime claims |
| `OPEN_CLAIMS` | `INT` | | | Currently open claims |
| `AVG_CLAIM_RESOLUTION_DAYS` | `FLOAT` | | | |
| `TOTAL_TICKETS` | `INT` | | | Lifetime tickets |
| `OPEN_TICKETS` | `INT` | | | |
| `AVG_SATISFACTION_SCORE` | `FLOAT` | | | Mean CSAT across tickets |
| `TOTAL_CALLS` | `INT` | | | |
| `AVG_SENTIMENT` | `FLOAT` | | | Mean sentiment across calls |
| `LAST_NEGATIVE_CALL_DATE` | `DATE` | | | Most recent negative-sentiment call |
| `COMPETITOR_MENTIONS_12M` | `INT` | | | Calls mentioning a competitor |
| `LAST_INTERACTION_DATE` | `DATE` | | | Most recent call, ticket, or payment |
| `DAYS_SINCE_LAST_INTERACTION` | `INT` | | | |
| `UPDATED_AT` | `TIMESTAMP_NTZ` | DEFAULT CURRENT_TIMESTAMP | | |

### 5.3 CHURN_SCORES

One row per customer per scoring run. Stores the model's churn probability and contributing factors.

| Column | Type | Constraints | PII | Notes |
|---|---|---|---|---|
| `SCORE_ID` | `VARCHAR(36)` | **PK** | | UUID |
| `CUSTOMER_ID` | `VARCHAR(36)` | **FK → CUSTOMERS** | | |
| `SCORE_DATE` | `DATE` | NOT NULL | | Date the model was run |
| `CHURN_PROBABILITY` | `FLOAT` | NOT NULL | | 0.0 to 1.0 |
| `RISK_TIER` | `VARCHAR(10)` | NOT NULL | | High, Medium, Low |
| `TOP_FACTOR_1` | `VARCHAR(100)` | | | e.g. "3 late payments in 90 days" |
| `TOP_FACTOR_2` | `VARCHAR(100)` | | | |
| `TOP_FACTOR_3` | `VARCHAR(100)` | | | |
| `MODEL_VERSION` | `VARCHAR(20)` | | | Tracks which model produced the score |
| `CREATED_AT` | `TIMESTAMP_NTZ` | DEFAULT CURRENT_TIMESTAMP | | |

### 5.4 RECOMMENDED_ACTIONS

One row per customer per scoring run. Next-best-action generated by an LLM or rules engine using the churn score and customer profile.

| Column | Type | Constraints | PII | Notes |
|---|---|---|---|---|
| `ACTION_ID` | `VARCHAR(36)` | **PK** | | UUID |
| `CUSTOMER_ID` | `VARCHAR(36)` | **FK → CUSTOMERS** | | |
| `SCORE_ID` | `VARCHAR(36)` | **FK → CHURN_SCORES** | | Links to the score that triggered it |
| `ACTION_TYPE` | `VARCHAR(50)` | NOT NULL | | Discount, Callback, Upgrade, Loyalty, Re-engage |
| `ACTION_DETAIL` | `VARCHAR(1000)` | | | LLM-generated personalized recommendation |
| `PRIORITY` | `INT` | | | 1 = highest |
| `CHANNEL` | `VARCHAR(20)` | | | Email, Phone, In-App |
| `STATUS` | `VARCHAR(20)` | DEFAULT 'Pending' | | Pending, Actioned, Dismissed |
| `ACTIONED_AT` | `TIMESTAMP_NTZ` | | | When the agent/user acted on it |
| `CREATED_AT` | `TIMESTAMP_NTZ` | DEFAULT CURRENT_TIMESTAMP | | |

---

## 6. Entity-Relationship Summary

```
CUSTOMERS (1) ──┬──< POLICIES (M)
                │       │
                │       ├──< PAYMENTS (M)
                │       └──< CLAIMS (M)
                │
                ├──< SERVICE_TICKETS (M)
                │       │
                │       └──< CALL_TRANSCRIPTS (M)
                │
                ├──< CALL_INSIGHTS (M)      [via TRANSCRIPT_ID]
                ├──  CUSTOMER_PROFILE (1)
                ├──< CHURN_SCORES (M)
                │       │
                │       └──< RECOMMENDED_ACTIONS (M)
                └───────────< RECOMMENDED_ACTIONS (M)
```

All foreign keys point back to `CUSTOMER_ID` ensuring full referential consistency for the customer-360 join.

---

## 7. PII Masking Summary

Columns requiring dynamic data masking (via Snowflake masking policies) for the `RETENTION_COPILOT_READER` role:

| Table | Columns |
|---|---|
| `CUSTOMERS` | FIRST_NAME, LAST_NAME, EMAIL, PHONE, DATE_OF_BIRTH, ADDRESS |
| `CALL_TRANSCRIPTS` | TRANSCRIPT_TEXT |
| `CUSTOMER_PROFILE` | FIRST_NAME, LAST_NAME, EMAIL |

The `RETENTION_COPILOT_ADMIN` role sees unmasked values. The `RETENTION_COPILOT_READER` role sees masked/redacted values.

---

## 8. Next Steps (Implementation Order)

1. Create database `RETENTION_COPILOT` with schemas `RAW`, `ANALYTICS`, `APP`
2. Create roles `RETENTION_COPILOT_ADMIN` and `RETENTION_COPILOT_READER` with grants
3. Create the six raw tables in `RAW`
4. Generate and load synthetic seed data
5. Build `CALL_INSIGHTS` using Cortex AI functions
6. Build `CUSTOMER_PROFILE` as a dynamic table or view joining all raw sources
7. Train churn model and populate `CHURN_SCORES`
8. Generate `RECOMMENDED_ACTIONS` via Cortex AI_COMPLETE
9. Apply masking policies on PII columns
10. Build the Streamlit app against the `APP` schema