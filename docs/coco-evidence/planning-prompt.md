You are in the PLANNING phase of a hackathon project called Retention Copilot: an insurer or lender customer 360 with churn prediction and next best action. Do not read project files. Do not create or change anything in Snowflake.

Step 1. Using read-only SQL against the connected Snowflake account, list the databases, the warehouses and the roles. Note anything relevant to the project.

Step 2. Draft the data model as a markdown document with these raw tables: CUSTOMERS, POLICIES, PAYMENTS, CLAIMS, SERVICE_TICKETS, CALL_TRANSCRIPTS. Also draft these derived tables: CALL_INSIGHTS (sentiment, complaint reason and competitor for each call), CUSTOMER_PROFILE (one row per customer joining everything), CHURN_SCORES, RECOMMENDED_ACTIONS.

For every table give the columns with types, the primary key, the foreign keys, and one sentence on its purpose. Every policy, payment, claim, ticket and transcript must point to a customer id so the data stays referentially consistent. Mark which columns hold personal data that must be masked.

Step 3. Propose the database name, the schemas (one per area of work) and the roles: an admin role for setup and a limited read-only role for the application.

Output only the markdown document, after finishing the SQL exploration.
