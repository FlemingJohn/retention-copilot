Goal: build a simple working binary classifier in Snowflake using Snowflake's ML functions, and find out the real cause if it cannot be done. Do not read project files. Do not spawn subagents or delegate documentation searches. Work directly and efficiently, and stop after about 25 tool calls.

Known problem: CREATE SNOWFLAKE.ML.CLASSIFICATION fails on this account with
    398208 (02000): CLASSIFICATION must have an active version defined.
SHOW CLASSES IN SCHEMA SNOWFLAKE.ML lists ANOMALY_DETECTION, CLASSIFICATION, FORECAST and TOP_INSIGHTS with VERSION = None, and SHOW VERSIONS IN CLASS SNOWFLAKE.ML.CLASSIFICATION fails with "Provider share does not have sufficient privileges". An identical trial account behaves the same. The account is Enterprise, AWS Jakarta, and only Gen2 warehouses can be created.

Work only in a new schema COCO_APP.ML_TEST, using warehouse COMPUTE_WH. Do not change account level settings, roles, users or warehouses, and do not touch any other schema.

Steps:
1. Create the schema. Create a training table of 2,000 rows with numeric columns age, late_payments, open_claims and a boolean column churned that depends on those columns plus randomness. Create a view over it.
2. Try CREATE SNOWFLAKE.ML.CLASSIFICATION on the view, exactly as the Snowflake docs show. Record the exact result.
3. Try every other way you can find to get a working classifier from Snowflake's ML functions, for example a different ML class such as FORECAST or ANOMALY_DETECTION to see whether they share the failure, the same statement with a different role, and any documented alternative such as the Snowflake ML Python API run inside a stored procedure. Record each attempt and its exact result.
4. If anything works, train it, score a few rows and show the output.
5. Drop the schema COCO_APP.ML_TEST when finished, and confirm it is gone.

Final answer, kept short:
- What worked and what failed, with exact error text.
- Whether the failure is the same for the other ML classes.
- Your best assessment of the real cause, and whether it can be fixed from our side.
- Anything you could not confirm.
