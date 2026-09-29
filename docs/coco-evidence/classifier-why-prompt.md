Question: why does CREATE SNOWFLAKE.ML.CLASSIFICATION fail on this Snowflake account while the other ML functions work? Do not read project files. Do not spawn subagents. Work directly, and stop after about 30 tool calls.

The error, from the exact worked example in the Snowflake docs:

    398208 (02000): CLASSIFICATION must have an active version defined.

Facts already established:
- CREATE SNOWFLAKE.ML.FORECAST and CREATE SNOWFLAKE.ML.ANOMALY_DETECTION both succeed on this account. The anomaly model instance shows current_version 21.0 in SHOW SNOWFLAKE.ML.ANOMALY_DETECTION.
- CREATE SNOWFLAKE.ML.CLASSIFICATION fails the same way under ACCOUNTADMIN, SYSADMIN and a custom non-admin role with CREATE SNOWFLAKE.ML.CLASSIFICATION granted on the schema. It fails for string labels, boolean labels, evaluate false, and on_error skip.
- SHOW CLASSES IN SCHEMA SNOWFLAKE.ML lists ANOMALY_DETECTION, CLASSIFICATION, FORECAST and TOP_INSIGHTS, all with VERSION None. SHOW VERSIONS IN CLASS on any of them fails with "Provider share does not have sufficient privileges", including the ones that work.
- A second, separate trial account shows the identical behaviour.
- Region AWS_AP_SOUTHEAST_7 (Jakarta), Enterprise edition, Gen2 warehouses only.

Investigate, in this order:
1. Search the Snowflake documentation, release notes and known issues for this error, for any statement about which regions or accounts support SNOWFLAKE.ML.CLASSIFICATION, and for how the CLASSIFICATION class differs from FORECAST and ANOMALY_DETECTION (for example a newer implementation that needs a different feature, warehouse type, cross-region setting or account parameter). Give links.
2. Run read-only SQL to compare the classes: SHOW GRANTS on the classes, SHOW PARAMETERS at account level for anything containing ML, CLASSIFICATION, MODEL, REGISTRY or SNOWPARK, DESCRIBE on the classes, and the details of the failed queries from INFORMATION_SCHEMA.QUERY_HISTORY (error messages, and any hint in the query text or metadata).
3. Look for anything CLASSIFICATION needs that FORECAST does not, such as a Model Registry, a specific warehouse generation, a feature flag, or a required application role, and test it if it is safe.
4. You may create objects only in a new schema COCO_APP.ML_WHY, using warehouse COMPUTE_WH. Do not change account level settings, roles, users or warehouses. Drop COCO_APP.ML_WHY when finished and confirm it is gone.

Final answer, short and honest:
- The most likely cause, and how confident you are.
- What evidence supports it and what contradicts it.
- Whether it can be fixed from our side, and how.
- Exactly what to send Snowflake Support.
- Anything you could not confirm.
