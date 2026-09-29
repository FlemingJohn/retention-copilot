# Synthetic Data Brief

The rules for the fake data behind Retention Copilot. The aim is data a churn model can learn something real from without learning our recipe.

---

## Setting

- An Indian general insurer selling Motor, Health, Life, Home and Travel policies.
- Cutoff date: 2026-06-30. Every event in every table happens on or before the cutoff. The only things after the cutoff are policy cancellations in the next 90 days, 2026-07-01 to 2026-09-28. Those are the churn outcomes.
- History runs from 2026-01-01 to the cutoff, six months, so daily metrics have about 180 days.
- Payment history starts earlier, on 2025-10-01, so payments reach about 60,000 rows.
- Claims are about 3 to 4 percent of policies per month, which gives about 1,500 over the six months.
- Claim amounts never exceed the policy cover and are capped per product. Satisfaction scores are whole numbers from 1 to 5.
- Customers who joined before 2026 have a customer since date as early as 2016.

## Row counts

| Table | Rows |
|---|---|
| CUSTOMERS | 5,000 |
| POLICIES | about 8,000 |
| PAYMENTS | about 60,000 |
| CLAIMS | about 1,500 |
| SERVICE_TICKETS | about 4,000 |
| CALL_TRANSCRIPTS | 1,000 |

## Libraries

- Faker with the `en_IN` locale for names, emails, phone numbers, cities, states and 6-digit pincodes.
- Snowflake SQL random functions and numpy for numbers, dates and probabilities.
- No AI functions for the structured tables. AI is only for transcripts, later.

## The hidden mood

Each customer gets a secret number MOOD between 0 (content) and 1 (unhappy), drawn from a skewed distribution so that most customers are content.

- MOOD is stored only in `RETENTION_COPILOT.GENERATOR.CUSTOMER_MOOD`. It is never copied into RAW, ANALYTICS or APP, and the schema is dropped once all data is generated.
- MOOD nudges these signals, and none of them is a direct copy of it:
  - late and failed payments: more likely when MOOD is high
  - service tickets: more, and lower satisfaction scores
  - call sentiment and competitor mentions, in the transcripts stage
  - claims: only a weak effect, since claims happen for their own reasons
- Every effect carries randomness, so the signals are correlated with MOOD and with each other but never determined by it.

## Churn

- Churn is a coin flip weighted by MOOD, plus small effects from tenure, premium size and product type. It is never a threshold rule.
- Overall rate among customers active at the cutoff: about 20 percent, acceptable between 15 and 25.
- Some unhappy customers stay. Some content customers leave. This is required.
- A churner gets a cancellation date on every one of their policies in 2026-07-01 to 2026-09-28, with a cancellation reason.
- About 8 percent of all customers already churned before the cutoff, with cancellation dates spread across 2026-01-01 to 2026-06-30. They give the daily history for forecasting.
- Plant one spike: during 2026-05-11 to 2026-05-17 cancellations run at about three times the normal rate, as after a premium increase. Negative tickets rise the same week.

## Leakage rules

- No table has a churned flag, an is active flag, or any status derived from the future.
- Only the cancellation dates and reasons in POLICIES reveal the outcome, and any feature builder must ignore events after the cutoff.
- SEGMENT is set from premium and tenure at the cutoff, never from the outcome.
- MOOD is invisible outside GENERATOR.

## Mess to add

- About 8 percent of satisfaction scores are missing.
- About 3 percent of phone numbers and emails are missing.
- A few customers with unusually large premiums.
- About 10 percent of unhappy customers show no warning signs at all.
- About 5 percent of content customers show some warning signs.

## Tables

All ids are readable text such as `C000001`, `P000001`. Money is in rupees. Dates use DATE, moments use TIMESTAMP_NTZ.

CUSTOMERS: CUSTOMER_ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE, DATE_OF_BIRTH, ADDRESS_LINE, CITY, STATE, PINCODE, CUSTOMER_SINCE, SEGMENT (Gold, Silver or Standard).

POLICIES: POLICY_ID, CUSTOMER_ID, PRODUCT_TYPE, PREMIUM_MONTHLY, COVERAGE_AMOUNT, START_DATE, RENEWAL_DATE, CANCELLATION_DATE, CANCELLATION_REASON.

PAYMENTS: PAYMENT_ID, POLICY_ID, CUSTOMER_ID, DUE_DATE, PAYMENT_DATE (empty when unpaid), AMOUNT, PAYMENT_METHOD (UPI, Card, NetBanking, AutoDebit), STATUS. No stored days late.

CLAIMS: CLAIM_ID, POLICY_ID, CUSTOMER_ID, CLAIM_DATE, CLAIM_TYPE, CLAIM_AMOUNT, SETTLEMENT_AMOUNT, STATUS, RESOLUTION_DATE.

SERVICE_TICKETS: TICKET_ID, CUSTOMER_ID, CHANNEL, CATEGORY, PRIORITY, STATUS, OPENED_AT, RESOLVED_AT, SATISFACTION_SCORE.

CALL_TRANSCRIPTS: TRANSCRIPT_ID, CUSTOMER_ID, TICKET_ID (may be empty), CALL_AT, DURATION_SECONDS, AGENT_ID, TRANSCRIPT_TEXT.

Every child row must point to a real customer, and every payment and claim to a real policy of that customer. Dates must be in a sensible order, for example a payment never before its policy starts and never after the cutoff.

## Checks to run after generation

- Row counts near the table above.
- No orphans: every foreign key finds its parent.
- Churn rate among customers active at the cutoff between 15 and 25 percent.
- Cancellation counts per day show the planted spike.
- No event dated after the cutoff except the future cancellations.
- Average late-payment rate is clearly higher for high-MOOD customers than for low-MOOD ones, and clearly not perfect.

## After generation

Train and test the churn model as a separate step. Split by customer, and also by time. Compare train and test scores. A near perfect score means a leak. A shuffled-label run must fall to chance. Results are on synthetic data and the screens must say so.
