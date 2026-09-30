Reading the three SQL files to understand the current implementation.Writing the rewritten procedure file now.Now running all the checks from file 06.All three files ran cleanly. Here is the full report.

---

## Results

### Model metrics

| Model | Split | ROC AUC | Top-20% Capture |
|---|---|---|---|
| logistic_regression | train | 0.6596 | 0.3556 |
| logistic_regression | **test** | **0.6589** | **0.3655** |
| gradient_boosting | train | 0.7421 | 0.4578 |
| gradient_boosting | test | 0.6410 | 0.3379 |
| logistic_regression_shuffled | test (shuffled AUC) | 0.4910 | — |

**Chosen model: `logistic_regression`** — gradient boosting test AUC (0.6410) did not beat logistic regression (0.6589) by ≥0.02; the gap is −0.018, so the selection rule correctly picked LR.

---

### Calibration (test customers only)

| RISK_TIER | N | Avg Predicted | Actual Churn Rate |
|---|---|---|---|
| High | 142 | 0.4431 | 0.4225 |
| Medium | 267 | 0.2713 | 0.2884 |
| Low | 983 | 0.1579 | 0.1556 |
| **Overall** | **1392** | **0.2087** | **0.2083** |

**Overall predicted probability (0.2087) is within 0.04 pp of the actual churn rate (0.2083) — well within 3 percentage points.** This confirms the calibration fix worked: removing `class_weight='balanced'` brought predicted probabilities into alignment with the true base rate.

---

### Top 10 importance (mean absolute occlusion, test customers)

| Feature | Importance |
|---|---|
| TICKETS_COUNT | 0.0475 |
| PAYMENTS_COUNT | 0.0379 |
| MISS_AVERAGE_DAYS_LATE | 0.0214 |
| ACTIVE_POLICIES | 0.0176 |
| LATE_PAYMENTS | 0.0165 |
| FAILED_PAYMENTS | 0.0152 |
| CLAIMS_COUNT | 0.0125 |
| AVERAGE_SATISFACTION | 0.0119 |
| CALLS_COUNT | 0.0115 |
| PRODUCT_COUNT | 0.0113 |

---

### Sample high-risk customers

| CUSTOMER_ID | Probability | Driver 1 | Driver 2 | Driver 3 |
|---|---|---|---|---|
| C004288 | 0.8201 | 4 service tickets | 2 rival mentions | 2 calls made |
| C004188 | 0.7518 | 5 service tickets | 4 failed payments | 4 late payments |
| C003307 | 0.7397 | 4 service tickets | 3 negative-sentiment calls | 3 calls made |

Plural handling is correct: "3 negative-sentiment calls", not "calls" for ≥2, and singular forms activate at exactly 1.

---

### What changed vs what stayed identical

**Changed as requested:**
1. **Calibration** — both `LogisticRegression` calls no longer use `class_weight='balanced'`; overall predicted probability is now 0.2087 vs actual 0.2083 (0.04 pp gap)
2. **Importance** — stored as `mean(abs(occlusion_drops))` over test customers
3. **Readability** — full-word names throughout, one statement per line, 8 helper functions each under 30 lines, no comments, 220 lines total, plural/singular driver phrases corrected

**Unchanged:** same 26 features, same log-scale columns, same missing-value flags, same CHURN_SPLIT table, same two models, same ≥0.02 AUC gap selection rule, same occlusion method, same tier thresholds (top 10% High, next 20% Medium), same random seeds (42 for models, 0 for shuffle RNG).

**Nothing failed.**