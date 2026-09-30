You are in the DEVELOPMENT and EXECUTION phase of a hackathon project called Retention Copilot. Your working directory is the project root. Read exactly one project file first: docs/synthetic-data-brief.md. Then work only in snowflake/synthetic-data. Do not read other project files. Do not run shell commands.

Stage one and two are done: files 01 to 19 exist, and RAW.CUSTOMERS, RAW.POLICIES, RAW.PAYMENTS, RAW.CLAIMS and RAW.SERVICE_TICKETS are filled. GENERATOR.CUSTOMER_MOOD holds the hidden mood. RAW.CALL_TRANSCRIPTS exists and is empty. Use warehouse RETENTION_COPILOT_WH as ACCOUNTADMIN.

Stage three writes the call transcripts with Snowflake Cortex COMPLETE. It costs tokens, so this run does a TEST BATCH OF EXACTLY 20 transcripts and nothing more. Do not write more than 20 in this run, under any circumstances.

Design:
- Plan the calls for all customers first (about 1,000 planned calls in total) in a table GENERATOR.CALL_PLAN, then write only the first 20 of the plan.
- Who calls: only customers that have a policy not cancelled before the call date. A call date is between 2026-01-01 and 2026-06-30 and before any pre-cutoff cancellation date of that customer. Customers with higher hidden mood are more likely to call, but the link is weak and noisy, and some content customers and some unhappy customers call too. A customer can be planned for more than one call, at most 3. Order the plan by a hash so that the first 20 rows are a random cross-section, not sorted by mood or customer id.
- For every planned call store: PLAN_ID, CUSTOMER_ID, CALL_AT (a timestamp in working hours), AGENT_ID and an Indian agent first name, TOPIC, STYLE, COMPETITOR (an insurer name or empty), TONE (a short instruction) and DURATION_TARGET (short, medium or long).
- TOPIC is one of: premium increase at renewal, claim status enquiry, claim rejected or delayed, payment or billing problem, add a family member or change a policy, general product question, thanks and praise, asking how to cancel. Topic depends on mood only weakly. Claim topics should mostly go to customers who actually have a claim, and billing topics mostly to customers who actually have late or failed payments, otherwise the text will contradict the tables.
- STYLE varies: formal, casual, hurried, chatty, and Indian English with a few Hindi words (Hinglish) for about a third of the calls. Vary length too.
- TONE comes from the hidden mood but never as a rule: content customers are mostly calm or cheerful but sometimes sharp, unhappy customers are mostly frustrated but some are polite, tired or resigned. Never write the words churn, mood, score or cancel-risk in a transcript.
- COMPETITOR: a named Indian insurer (LIC, HDFC Life, ICICI Lombard, Star Health, Bajaj Allianz, Tata AIG, SBI Life) is mentioned by about 3 percent of low mood callers and about 20 percent of high mood callers.
- The prompt to COMPLETE includes true facts from the tables so the call agrees with the data: the customer's first name, city, the relevant policy product and monthly premium in rupees, and where relevant a real recent claim (type, amount, status) or the number of late payments in the last six months. The prompt must NOT include the customer's cancellation dates, any churn outcome or the mood number itself; only the TONE sentence derived from it.
- The output is only the dialogue, as alternating lines starting Agent: and Customer:, 120 to 350 words depending on DURATION_TARGET, in natural spoken language with no stage directions, no headings and no markdown.
- Use the cheapest Cortex model that writes natural dialogue. Try claude-haiku-4-5 first. If it is not available, use llama3.1-70b. Record the model used.
- Call COMPLETE so that token usage is returned (use the form that takes a message list and an options object with max_tokens set to 700, and read the usage counts from the result). Record prompt tokens, completion tokens and the model for each call in GENERATOR.TRANSCRIPT_USAGE.
- Insert into RAW.CALL_TRANSCRIPTS: TRANSCRIPT_ID like CALL000001, CUSTOMER_ID, TICKET_ID left empty for now, CALL_AT, DURATION_SECONDS estimated from the word count at about 130 words per minute plus noise, AGENT_ID, TRANSCRIPT_TEXT.

Create these files in this order and run each:
20_create_call_plan.sql          builds GENERATOR.CALL_PLAN for the whole plan.
21_create_usage_table.sql        creates GENERATOR.TRANSCRIPT_USAGE.
22_create_transcript_writer.sql  a stored procedure that takes a first plan id and a count, writes those calls with COMPLETE, and inserts the transcripts and the usage rows. Skip plan ids that already have a transcript so a rerun never duplicates.
23_write_test_batch.sql          calls the procedure for plan ids 1 to 20 only.
24_check_transcripts.sql         read-only checks: number of transcripts, average and minimum and maximum word count, total prompt and completion tokens, tokens per transcript, the model used, the mood mix of the 20 (low, mid, high), the mix of topics and styles, the count of transcripts that mention a competitor, the count containing the words churn, mood or score (must be 0), and 3 full sample transcripts from different mood groups.

Then estimate the cost. Look up the current Snowflake credit rate per million tokens for the model you used in Snowflake's Service Consumption Table or the Cortex pricing documentation, and give: credits used by the 20, credits per transcript, and the projected credits for 1,000 transcripts. If you cannot find the rate, say so and give the token totals only. Do not guess a rate.

Coding rules for every file, strict: no comments of any kind, one job per file, short files, plain names, upper case object names, lower case keywords. Do not change account level settings. Do not touch other schemas.

Final answer, short: files written, whether each ran, the check output, the cost estimate and its source, and an honest one paragraph assessment of the quality and variety of the 3 samples. Report anything that failed or that you changed.
