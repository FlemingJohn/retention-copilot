You are in the DEVELOPMENT and EXECUTION phase of a hackathon project called Retention Copilot. Your working directory is the project root. Read exactly one project file first: docs/synthetic-data-brief.md. Then work only in snowflake/churn-model. Do not read other project files. Do not spawn subagents. Do not run shell commands. Use warehouse RETENTION_COPILOT_WH as ACCOUNTADMIN. Never read anything from the GENERATOR schema.

Already in Snowflake: RETENTION_COPILOT.ANALYTICS.CUSTOMER_PROFILE (dynamic table, one row per customer, features as of 2026-06-30) and RETENTION_COPILOT.ANALYTICS.CHURN_LABELS (CUSTOMER_ID, CHURNED_WITHIN_90_DAYS boolean, for the 4,636 customers with IS_ACTIVE_AT_CUTOFF true, churn rate about 21 percent).

Goal: train and honestly evaluate a churn model inside Snowflake with scikit-learn in a Python stored procedure, then score every active customer. Facts learned earlier on this account: pandas conversion inside procedures fails, so read rows with session.sql(...).collect() and build lists or numpy arrays yourself; use packages snowflake-snowpark-python, scikit-learn and numpy, runtime 3.11; SNOWFLAKE.ML.CLASSIFICATION does not work here, do not try it.

Create these files in snowflake/churn-model, run each in order:

01_create_model_stage.sql
  An internal stage RETENTION_COPILOT.ANALYTICS.MODEL_STAGE.

02_create_churn_split.sql
  A table RETENTION_COPILOT.ANALYTICS.CHURN_SPLIT with CUSTOMER_ID and SPLIT ('train' or 'test') for the customers in CHURN_LABELS, about 70 percent train and 30 percent test, decided deterministically from a hash of CUSTOMER_ID and made STRATIFIED so the churn rate is nearly equal in both parts (for example rank customers within churned and stayed groups by hash, and assign the first 70 percent of each group to train).

03_create_result_tables.sql
  RETENTION_COPILOT.ANALYTICS.CHURN_MODEL_RESULTS (MODEL_NAME, SPLIT_NAME, METRIC_NAME, METRIC_VALUE float, RUN_AT timestamp) and RETENTION_COPILOT.ANALYTICS.CHURN_SCORES (CUSTOMER_ID, CHURN_PROBABILITY float, RISK_TIER, TOP_DRIVER_1, TOP_DRIVER_2, TOP_DRIVER_3 (all varchar 200), MODEL_NAME, IS_TEST_CUSTOMER boolean, SCORED_AT timestamp).

04_create_training_procedure.sql
  A Python stored procedure RETENTION_COPILOT.ANALYTICS.TRAIN_CHURN_MODEL() that does all of this. Keep every helper function inside it short (under 30 lines) and the whole file under 220 lines. No comments.
  Features: use exactly these numeric columns from CUSTOMER_PROFILE: TENURE_MONTHS, ACTIVE_POLICIES, TOTAL_MONTHLY_PREMIUM, PRODUCT_COUNT, PAYMENTS_COUNT, LATE_PAYMENTS, FAILED_PAYMENTS, LATE_OR_FAILED_RATE, AVERAGE_DAYS_LATE, CLAIMS_COUNT, OPEN_CLAIMS, REJECTED_CLAIMS, TOTAL_CLAIMED_AMOUNT, AVERAGE_RESOLUTION_DAYS, TICKETS_COUNT, OPEN_TICKETS, ESCALATED_TICKETS, AVERAGE_SATISFACTION, LOWEST_SATISFACTION, CALLS_COUNT, AVERAGE_SENTIMENT, LOWEST_SENTIMENT, NEGATIVE_CALLS, RIVAL_MENTIONS, CANCEL_INTENT_CALLS, DAYS_SINCE_LAST_CALL. Plus SEGMENT one hot encoded, plus one 0/1 flag per product type found in PRODUCTS_HELD (Motor, Health, Life, Home, Travel). Do not use names, email, phone, city, state, CUSTOMER_ID, CUSTOMER_SINCE, LAST_CALL_DATE or IS_ACTIVE_AT_CUTOFF.
  Missing values: they are real (sentiment exists for only about 17 percent of customers). For the logistic regression: fill numeric gaps with the training median and add a 0/1 missing flag for every feature that is empty for more than 10 percent of training customers; take log1p of TOTAL_MONTHLY_PREMIUM and TOTAL_CLAIMED_AMOUNT; standardise using training data only. For the gradient boosting model keep gaps as missing (it handles them) and use the same one hot flags.
  Models: (a) LogisticRegression with L2 regularisation and class_weight balanced, (b) HistGradientBoostingClassifier with a modest depth and learning rate, early stopping on, fixed random_state. Fit preprocessing and models on the train customers only.
  Evaluation on the test customers, and also on the train customers for the overfitting gap: ROC AUC, average precision, and the top 20 percent capture rate (the share of all churners that fall in the top 20 percent of predicted probability). Also a SHUFFLED LABEL test: retrain the logistic regression on train customers with the labels randomly permuted, and report its test ROC AUC. Write every metric for each model into CHURN_MODEL_RESULTS.
  Choice: pick the gradient boosting model only if its test ROC AUC beats the logistic regression's by at least 0.02, otherwise pick the logistic regression. Record the choice as a row with METRIC_NAME chosen_model in CHURN_MODEL_RESULTS (METRIC_VALUE 1 for the chosen model name row).
  Save the chosen fitted model and its preprocessing as one pickle to @RETENTION_COPILOT.ANALYTICS.MODEL_STAGE/churn_model.pkl.
  Scoring: score all 4,636 customers with the chosen model. RISK_TIER: the top 10 percent by probability High, the next 20 percent Medium, the rest Low.
  Drivers: for each customer find the top three features that push the score up, using an occlusion method: replace one feature (or the group of columns that belong to one feature, such as a value with its missing flag) by the training median or missing, and measure the drop in predicted probability; keep the three biggest positive drops. Write them as plain English phrases that include the customer's real value, for example "3 late payments in the last 6 months", "average call sentiment -0.72", "2 open tickets", "rival insurer mentioned on a call". Use a small dictionary from feature name to phrase template. If fewer than three features push the score up, leave the rest empty.
  Also write into CHURN_MODEL_RESULTS the average occlusion drop per feature over the test customers as METRIC_NAME importance_<feature> for the chosen model, so global importance can be shown.
  Fill CHURN_SCORES for all 4,636 customers with IS_TEST_CUSTOMER from CHURN_SPLIT. Truncate both result tables at the start so a rerun starts clean. Return a short text summary with the chosen model and its test ROC AUC.

05_train_churn_model.sql
  Calls the procedure.

06_check_churn_model.sql
  Read only checks, each its own statement, running as one file:
  - churn rate in train and in test from CHURN_SPLIT joined to CHURN_LABELS, and the two row counts;
  - every train and test metric per model, and the shuffled label AUC, from CHURN_MODEL_RESULTS, and the chosen model;
  - the largest 10 importance_ rows;
  - the number of rows in CHURN_SCORES, the count per RISK_TIER, and the actual churn rate per RISK_TIER for TEST customers only (join CHURN_LABELS, keep IS_TEST_CUSTOMER true), which should rise from Low to High;
  - the minimum, average and maximum CHURN_PROBABILITY;
  - 5 sample rows from CHURN_SCORES with drivers, ordered by probability descending.

Coding rules for every file, strict: no comments of any kind, one job per file, plain names with no abbreviations, upper case object names, lower case keywords, fully qualified names in SQL. Each file must run exactly as saved. Do not change account level settings. Do not touch other schemas.

Final answer, short: files written, whether each ran as saved, the full check output, which model was chosen and why, and an honest note on anything suspicious, for example a test ROC AUC above 0.95, a shuffled label AUC outside 0.45 to 0.55, or a large train versus test gap. Report anything that failed or that you changed.
