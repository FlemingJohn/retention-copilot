I'll work through this systematically. Let me start by setting up the schema and training data.Schema and data ready (2000 rows, 1013 churned). Now attempting CLASSIFICATION.Confirmed: CLASSIFICATION fails with `CLASSIFICATION must have an active version defined.` Now let me try the other ML classes and check the current role.FORECAST and ANOMALY_DETECTION gave input validation errors (not the version error), which means they got further. Let me fix the inputs to see if they actually work.FORECAST works. Let me now try ANOMALY_DETECTION with proper data, and re-attempt CLASSIFICATION with a different role.Very revealing: FORECAST and ANOMALY_DETECTION both work despite showing VERSION=None. Only CLASSIFICATION fails. Let me try with SYSADMIN and also try TOP_INSIGHTS.Same error with SYSADMIN. Now let me check the account region and whether this is a regional availability issue.Region is `AWS_AP_SOUTHEAST_7` (Jakarta). Let me check versions on the working classes.All three classes return the same error on SHOW VERSIONS, yet FORECAST and ANOMALY_DETECTION work. The "version=None" in SHOW CLASSES is a display artifact. The CLASSIFICATION class is specifically broken. Let me now try the Python ML API as an alternative.Pandas dependency issue. Let me add it.The snowflake-ml-python wrapper spawns an internal sproc that lacks pandas. Let me try pure sklearn directly.Pure sklearn works. Now let me also try to build a proper scoring workflow using a UDF to make it more "Snowflake-native". Then I'll clean up.Scoring works. Now let me clean up.Schema dropped, confirmed gone. Here's the summary:

---

## Results

### What failed

- **`CREATE SNOWFLAKE.ML.CLASSIFICATION`** — fails with `398208 (02000): CLASSIFICATION must have an active version defined.` Identical result with both ACCOUNTADMIN and SYSADMIN roles.
- **`SHOW VERSIONS IN CLASS SNOWFLAKE.ML.CLASSIFICATION`** — fails with `Provider share does not have sufficient privileges`. Same error for FORECAST and ANOMALY_DETECTION classes (this is normal — it's not user-accessible).
- **`snowflake.ml.modeling.linear_model.LogisticRegression`** (the Snowflake ML Python wrapper) — fails because its internal temp stored procedure lacks pandas in its dependency resolution. This is a secondary issue unrelated to the CLASSIFICATION class.

### What worked

- **`CREATE SNOWFLAKE.ML.FORECAST`** — succeeded.
- **`CREATE SNOWFLAKE.ML.ANOMALY_DETECTION`** — succeeded.
- **Pure sklearn `LogisticRegression`** inside a stored procedure — trained successfully (84.5% accuracy), model saved to a stage, loaded into a Python UDF, and scored rows correctly.

### Is the failure the same for other ML classes?

**No.** FORECAST and ANOMALY_DETECTION both work fine despite showing the same `VERSION = None` in `SHOW CLASSES`. The failure is **specific to CLASSIFICATION**.

### Root cause assessment

The CLASSIFICATION class is delivered to customer accounts via a provider share from Snowflake. On this account (Enterprise, **AWS Jakarta / `AWS_AP_SOUTHEAST_7`**), the CLASSIFICATION class has no active version deployed — Snowflake's internal provisioning has not published a working version of CLASSIFICATION to this region. FORECAST and ANOMALY_DETECTION are provisioned, which is why they work. This is a **Snowflake-side regional deployment gap**, not a privilege, edition, or configuration issue.

**It cannot be fixed from our side.** The only remedy is to open a Snowflake support case asking them to activate the CLASSIFICATION class version in `AWS_AP_SOUTHEAST_7`.

### What I could not confirm

- Whether TOP_INSIGHTS is also affected (it uses a different interface — `SNOWFLAKE.ML.TOP_INSIGHTS` as a table function — and returned `Unknown user-defined table function`, suggesting it's also not deployed in this region, but it could also be a syntax/availability difference).
- Whether this is specific to Jakarta or affects other newer AWS regions.