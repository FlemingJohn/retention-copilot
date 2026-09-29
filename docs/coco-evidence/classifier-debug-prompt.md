You are helping debug an error with Snowflake ML classification on the connected Snowflake account. Do not read project files.

The error:

    398208 (02000): CLASSIFICATION must have an active version defined.

It is returned by CREATE SNOWFLAKE.ML.CLASSIFICATION. The model is never created (SHOW SNOWFLAKE.ML.CLASSIFICATION returns nothing).

What has already been tried, all with the same error:
- The exact worked example from the Snowflake docs (training_purchase_data, binary_classification_view, CREATE OR REPLACE SNOWFLAKE.ML.CLASSIFICATION model_binary(INPUT_DATA => SYSTEM$REFERENCE('view', 'binary_classification_view'), TARGET_COLNAME => 'label')), run as a non-admin role with CREATE SNOWFLAKE.ML.CLASSIFICATION granted on the schema and USE SCHEMA set first.
- Fully qualified names as ACCOUNTADMIN, 3,000 rows, string and boolean labels, config_object with evaluate false and on_error skip.
- The account is Enterprise edition, AWS region Jakarta (AWS_AP_SOUTHEAST_7), created today, cross-region inference set to ANY_REGION.
- Only Gen2 warehouses can be created here. Gen1 and Snowpark-optimized warehouses are refused with "Creating or converting a warehouse to Gen1 (STANDARD_GEN_1) is not allowed".
- A Python stored procedure using scikit-learn does run and train, so Anaconda packages work.
- CREATE AGENT, semantic views, Cortex Search and Cortex AI functions all work.

Your task:
1. Search the Snowflake documentation and release notes for this error message and for SNOWFLAKE.ML.CLASSIFICATION requirements, region availability, Gen2 warehouse support, and any known issues. Report what you find with links.
2. Run read-only SQL to look for a cause, for example SHOW PARAMETERS at account level for anything ML related, SHOW WAREHOUSES, and whether the SNOWFLAKE.ML schema or classification class objects are visible.
3. If you want to test something, you may create objects only in the schema COCO_APP.CHECKS (create it first) and you must drop that schema when finished. Do not change any account level settings and do not create warehouses.
4. Give a short conclusion: the most likely cause, whether it can be fixed from our side, and exactly what to send Snowflake Support if not.

Be honest about anything you could not confirm.
