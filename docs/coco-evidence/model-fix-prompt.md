You are in the DEVELOPMENT and EXECUTION phase of a hackathon project. Your working directory is the project root. Work only in snowflake/churn-model. Do not spawn subagents. Do not run shell commands. Use warehouse RETENTION_COPILOT_WH as ACCOUNTADMIN. Never read anything from the GENERATOR schema.

Read snowflake/churn-model/04_create_training_procedure.sql, 05_train_churn_model.sql and 06_check_churn_model.sql. The model trains and scores correctly, but three things must change. Keep all other logic identical: same features, same missing value handling, same split table, same two models, same selection rule (gradient boosting only if its test ROC AUC beats logistic regression by at least 0.02), same occlusion method for per customer drivers, same tiers (top 10 percent High, next 20 percent Medium), same random seeds.

Change 1, calibration. The logistic regressions use class_weight='balanced', which inflates probabilities (the Low tier averages 41 percent predicted while 16 percent really churn). Remove class_weight from BOTH logistic regressions (the real one and the one trained on shuffled labels) so predicted probabilities match the real churn rate of about 21 percent. Ranking metrics may move slightly, that is fine.

Change 2, importance. The stored global importance must be the mean of the ABSOLUTE occlusion change over the test customers, not the signed mean.

Change 3, readability, required by the project rules. Rewrite the Python inside the procedure so that:
- every name is a plain full word with no abbreviations (for example scaler, logistic_model, boosting_model, test_rows, train_labels, missing_flag_columns, run_query, insert_result, not sc, lr, gb, te_d, mf, sq, ins, MR, SCT);
- there is one statement per line, no semicolon separated statements, no long list comprehensions on one line;
- the work is split into small helper functions, each under 30 lines, in a sensible top to bottom order with the main path first;
- there are no comments of any kind;
- the file stays under 220 lines.
Also fix the plural in driver phrases: use "1 negative-sentiment call" for one and "3 negative-sentiment calls" for more, and the same for tickets, payments and calls generally.

Update 06_check_churn_model.sql so it also shows a calibration table on TEST customers only: for each RISK_TIER the number of customers, the average predicted CHURN_PROBABILITY and the actual churn rate (join CHURN_LABELS), and the overall average predicted probability next to the overall actual churn rate. Keep the other checks.

Then re-run in order: 04, 05, 06. Each file must run exactly as saved.

Final answer, short: the metrics table (ROC AUC train and test for both models, shuffled label AUC, top 20 percent capture), the chosen model, the calibration table, the top 10 importance rows, and 3 sample high risk customers with drivers. State plainly whether the average predicted probability is now close to the actual churn rate (within 3 percentage points). Report anything that failed or that you could not keep identical.
