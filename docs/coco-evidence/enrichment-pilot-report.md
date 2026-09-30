I'll execute the SQL files in order. Let me start by reading and running each one.Now running file 1:File 1 ✓ Table created. Now reading file 2:Running file 2 (procedure creation):File 2 ✓ Procedure created. Now running the pilot call:Pilot call ✓ Inserted 50 rows. Now reading file 4 to run checks:Now running each check statement one at a time:

**Check 1 - Row count:****Check 2 - NULL counts:****Check 3 - Sentiment statistics:****Check 4 - Main topics distribution:****Check 5 - Competitor mentions:****Check 6 - Cancellation intent:****Check 7 - Mood analysis:****Check 8 - Sample rows:**## Results

✅ **All steps completed successfully**

**Execution Summary:**
- ✅ File 1: CALL_INSIGHTS table created
- ✅ File 2: ENRICH_CALLS procedure created  
- ✅ Pilot call: 50 rows inserted
- ✅ File 4: All 8 checks passed

**Rows Inserted:** 50

**Full Check Output:**

| Check | Result |
|-------|--------|
| **1. Row Count** | 50 |
| **2. NULL Counts** | SENTIMENT_SCORE: 0, MAIN_TOPIC: 0, COMPETITOR_MENTIONED: 46, COMPLAINT_REASON: 29, WANTS_TO_CANCEL: 0 |
| **3. Sentiment Stats** | AVG: 0.113, MIN: -0.888, MAX: 0.883 |
| **4. Topics** | Billing (12), Claim delay (10), Praise (8), Cancellation (7), Premium complaint (6), Policy change (4), General (3) |
| **5. Competitors** | None (46), HDFC Life (1), ICICI Lombard (1), Bajaj Allianz (1), Other (1) |
| **6. Cancellation** | FALSE: 41, TRUE: 9 |
| **7. Mood Analysis** | Below 0.3 mood: 18 calls (avg sentiment 0.328), 0.3-0.7 mood: 18 calls (avg sentiment 0.100), Above 0.7 mood: 14 calls (avg sentiment -0.145) |
| **8. Sample Data** | 5 records shown with full enrichment fields populated |