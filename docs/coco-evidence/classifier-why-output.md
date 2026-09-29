I'll investigate this systematically. Let me start with documentation research and SQL diagnostics in parallel.Let me use web_fetch for docs and SQL execution for diagnostics.Good - the docs fetched successfully. Let me read the classification docs for region info, and run more diagnostics.Key finding: "Provider share does not have sufficient privileges" on SHOW VERSIONS. Let me check more.Let me check the Snowflake release notes for Classification changes and region availability.The region is actually Thailand (ap-southeast-7), not Jakarta. Let me check the ML functions region availability more specifically.Confirmed. FORECAST creates successfully (version 21.0) while CLASSIFICATION fails. Now let me clean up and deliver the diagnosis.---

## Diagnosis

### Most likely cause (confidence: **high**, ~90%)

**SNOWFLAKE.ML.CLASSIFICATION has no active class version deployed to AWS_AP_SOUTHEAST_7 (Thailand).** This is a Snowflake server-side provisioning gap — the Classification implementation hasn't been rolled out to this region.

### Evidence supporting this

1. **All four SNOWFLAKE.ML classes show `version: None`** in `SHOW CLASSES IN SCHEMA SNOWFLAKE.ML`. This means the SNOWFLAKE database (a provider-managed application) has not provisioned active versions for any of these classes in this region.

2. **`SHOW VERSIONS IN CLASS` fails for ALL classes** — including FORECAST and ANOMALY_DETECTION — with *"Provider share does not have sufficient privileges"*. This confirms the provider share has an incomplete deployment.

3. **FORECAST and ANOMALY_DETECTION work anyway**, creating instances with `current_version: 21.0`. This means they have been **re-architected** to bypass the class-version mechanism (likely migrated to a newer execution path — native stored procs or a service-based backend). CLASSIFICATION still uses the older path that requires the class to have an active version.

4. **The error is literal**: `398208: CLASSIFICATION must have an active version defined` — the class exists but has no runnable version code behind it.

5. **No customer-side parameter, privilege, or feature flag controls this.** There is no `ENABLE_ML_*` or `ENABLE_CLASSIFICATION_*` parameter. The account has Enterprise edition, ACCOUNTADMIN role, and the correct `CREATE SNOWFLAKE.ML.CLASSIFICATION` grant — none of which matter because the issue is on the provider side.

6. **AWS ap-southeast-7 (Thailand) is a very new AWS region** — it appears near the bottom of Snowflake's region list. New regions routinely have feature gaps during rollout.

7. **A second trial account in the same region shows the same behavior** — ruling out any account-specific configuration.

### What contradicts this

- The Snowflake documentation for Classification does not list region restrictions or mention that it's unavailable in any region. It presents it as generally available. This could mean: (a) the docs don't track per-region deployment status for ML classes, or (b) this is an unintentional gap rather than a deliberate exclusion.

### Can it be fixed from our side?

**No.** There is no account parameter, role, warehouse type, or configuration change that can fix this. The class version must be deployed by Snowflake's internal infrastructure team.

### What to send Snowflake Support

> **Subject:** SNOWFLAKE.ML.CLASSIFICATION fails with error 398208 in AWS_AP_SOUTHEAST_7 — class has no active version
>
> **Details:**
> - Account: CE63653 (locator CH32568), region AWS_AP_SOUTHEAST_7 (Thailand), Enterprise edition
> - `CREATE SNOWFLAKE.ML.CLASSIFICATION` fails with error `398208: CLASSIFICATION must have an active version defined`
> - Tested under ACCOUNTADMIN, SYSADMIN, and a custom role — same result
> - `SHOW CLASSES IN SCHEMA SNOWFLAKE.ML` shows all four classes (ANOMALY_DETECTION, CLASSIFICATION, FORECAST, TOP_INSIGHTS) with `version: None`
> - `SHOW VERSIONS IN CLASS SNOWFLAKE.ML.CLASSIFICATION` returns: *"Provider share does not have sufficient privileges"*
> - However, `CREATE SNOWFLAKE.ML.FORECAST` and `CREATE SNOWFLAKE.ML.ANOMALY_DETECTION` **succeed** and show `current_version: 21.0` on the created instances — suggesting those classes have been migrated to a new execution path that doesn't need the class version
> - A second trial account in the same region has the identical issue
> - Example failed query_id: `01c76598-000e-0805-0000-00027372a7fd`
>
> **Request:** Please deploy the CLASSIFICATION class version to the AWS_AP_SOUTHEAST_7 region, or confirm if/when this feature will be available here.

### What I could not confirm

- Whether Snowflake has an internal region-availability matrix for ML functions (the docs don't show one)
- Whether TOP_INSIGHTS has the same problem (never tested it)
- Whether this is a deliberate exclusion or an accidental gap in the deployment pipeline
- The exact timeline for when FORECAST/ANOMALY_DETECTION were migrated off the class-version path — this is only inferred from the fact they work despite `version: None`

`COCO_APP.ML_WHY` has been dropped and confirmed gone.