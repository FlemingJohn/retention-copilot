Reading the project brief first.Now I have all the context I need. Let me plan and create all 6 files.Now writing the procedure — the most complex file.137 lines total — well under 220.All 6 files written. Now running them in order.Procedure created. Now running it — this will take a few minutes.Procedure ran successfully. Now running the checks.All 6 files ran as saved. Here is the complete report.

---

## Files written and run status

| File | Ran | Result |
|---|---|---|
| `01_create_model_stage.sql` | ✓ | Stage MODEL_STAGE created |
| `02_create_churn_split.sql` | ✓ | CHURN_SPLIT created |
| `03_create_result_tables.sql` | ✓ | Both result tables created |
| `04_create_training_procedure.sql` | ✓ | Procedure created (137 lines, under 220) |
| `05_train_churn_model.sql` | ✓ | Procedure ran to completion |
| `06_check_churn_model.sql` | ✓ | All checks returned clean results |

---

## Full check output

**Split stratification**

| SPLIT | N | Churn rate |
|---|---|---|
| train | 3,244 | 20.81% |
| test | 1,392 | 20.83% |

Stratification worked: churn rate is nearly identical in both splits.

**Model metrics**

| Model | Split | ROC AUC | Avg Precision | Top-20% Capture |
|---|---|---|---|---|
| logistic_regression | train | 0.6619 | 0.3340 | 0.3585 |
| logistic_regression | test | **0.6600** | 0.3287 | 0.3655 |
| gradient_boosting | train | 0.7421 | 0.4769 | 0.4578 |
| gradient_boosting | test | 0.6410 | 0.3049 | 0.3379 |
| shuffled labels (LR) | test | 0.4860 | — | — |

**Model chosen: logistic_regression** — gradient boosting's test AUC (0.641) did not beat logistic regression's (0.660) by 0.02; it was actually worse.

**Top 10 feature importances (occlusion, test customers)**

Top features by average probability drop: TOTAL_MONTHLY_PREMIUM, PAYMENTS_COUNT, PRODUCT_COUNT, CALLS_COUNT, NEGATIVE_CALLS, LOWEST_SENTIMENT.

**CHURN_SCORES**

| Metric | Value |
|---|---|
| Total scored | 4,636 (all active customers) |
| High tier | 464 (≈10%) |
| Medium tier | 927 (≈20%) |
| Low tier | 3,245 (≈70%) |
| Min probability | 0.1904 |
| Avg probability | 0.4779 |
| Max probability | 0.9520 |

**Tier vs actual churn (test customers only)**

| Tier | N | Actual churn rate |
|---|---|---|
| High | 139 | **42.45%** |
| Medium | 276 | **28.26%** |
| Low | 977 | **15.66%** |

Churn rate rises monotonically from Low to High — the model is genuinely discriminating.

**Sample high-risk customers with drivers**

| CUSTOMER_ID | Probability | Driver 1 | Driver 2 | Driver 3 |
|---|---|---|---|---|
| C003307 | 0.9520 | 4 service tickets | 3 negative-sentiment calls | 3 calls made |
| C004288 | 0.9476 | 4 service tickets | 2 calls made | 1 negative-sentiment calls |
| C002525 | 0.9333 | 7 failed payments | 2 negative-sentiment calls | 2 calls made |

---

## Chosen model and why

**Logistic regression** was chosen. Gradient boosting had a larger train–test gap (0.742 → 0.641, gap 0.101) indicating overfitting on this small dataset. Logistic regression was nearly flat (0.662 → 0.660), showing it generalises better. The selection rule (pick GB only if it beats LR by ≥0.02) correctly rejected the overfitting model.

---

## Honest notes on suspicious signals

- **Test AUC 0.660** — not suspiciously high. For a synthetic dataset where churn is a noisy probabilistic function of MOOD (which is not directly observed), a ceiling around 0.70–0.75 is expected. 0.660 is plausible and not a leak indicator.
- **Shuffled label AUC 0.486** — squarely within the expected 0.45–0.55 range. The model is not learning noise.
- **GB train–test gap (0.742 vs 0.641)** — the gradient booster overfit to the 3,244 training customers. Modest depth (4) and early stopping weren't enough with this small dataset and weak signal. This is expected behaviour, not a bug.
- **Average CHURN_PROBABILITY = 0.478** — the logistic regression with `class_weight='balanced'` correctly calibrates toward higher probabilities. This is by design and worth noting when displaying scores; the probabilities are relative ranks, not calibrated posterior probabilities.
- **Missing flags in top importances** — `MISS_AVERAGE_SATISFACTION` and `MISS_LOWEST_SATISFACTION` appear in the top 10. This means customers with no satisfaction data (no resolved tickets) have different churn behaviour — plausibly because they've had fewer interactions overall.