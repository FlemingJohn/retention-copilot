# Snowflake Guide

The Snowflake ideas this project uses, in the order we meet them. Each one says what it is, where the Retention Copilot uses it, and what has been checked on our account.

Marks used below:

- **Verified** means we ran it on the event account.
- **From the docs** means we read it in Snowflake's documentation but have not run it.
- **Untested** means we have not confirmed it either way.

---

## The big picture

Snowflake keeps data and the computers that work on it apart. Data sits in storage. Computers, called warehouses, start when you ask a question and stop when idle. You pay for the time they run, in credits.

Everything in this project stays inside Snowflake except the Next.js screens, which ask Snowflake for answers over a web API.

---

## 1. Where things live

### Account
Your own Snowflake environment, with its own users, data and bill. The event account has $400 of free credits and lasts 30 days.

### Database and schema
A database holds schemas. A schema holds tables, views and other objects. Think of a database as a filing cabinet and a schema as a drawer.

Names are written `DATABASE.SCHEMA.OBJECT`. Objects in this project will live in one database with a schema per area of work.

### Table and view
A table stores rows. A view is a saved question that looks like a table but stores nothing. Views are how the app will read masked data.

### Stage
A place to put files, such as CSVs, before loading them into tables.

---

## 2. Who can do what

### Role
A named set of permissions. You always act as one role. `ACCOUNTADMIN` can do everything, so it is only for setup. The deployed app must use a small role that can read the views it needs and nothing else.

### Privilege
A single permission, such as reading a table or creating a task. Roles are granted privileges.

### Token and authentication policy
The app and command line sign in with a programmatic access token. On our accounts a token would not work until an authentication policy said it need not have a network policy. This is a setup detail, but it explains the error "Network policy is required".

---

## 3. Computing and cost

### Warehouse
The computer that runs queries. Ours is `COMPUTE_WH`, size X-Small, the smallest. It starts on demand and stops after it has been idle for the auto-suspend time, which we set to 60 seconds.

### Credit
The unit of cost. A running warehouse uses credits. A bigger warehouse uses more per hour. Cortex AI functions also use credits, based on how much text goes through them.

**How to stay cheap:** keep the warehouse small, keep auto-suspend short, and avoid running the same expensive AI function over all rows again and again. Save its result in a table.

---

## 4. Text and AI inside SQL (Cortex)

Cortex is Snowflake's built-in AI. You call it from SQL, and the data never leaves Snowflake.

| Function | What it does | Status |
|---|---|---|
| `SENTIMENT` | Scores text from negative to positive | Verified |
| `AI_CLASSIFY` | Puts text into categories you name | Verified |
| `AI_EXTRACT` | Pulls named facts out of text, such as a competitor | Verified |
| `COMPLETE` | Asks a language model to write text, including Claude and Llama models | Verified |
| Embeddings | Turns text into numbers so meaning can be compared | Verified |

Where we use them: the synthetic call transcripts are written with `COMPLETE`. Sentiment, complaint reason and competitor mentions are pulled from each transcript with the other functions. The next-best-action message is written with `COMPLETE`.

---

## 5. Keeping data up to date

### Dynamic table
A table defined by a query that Snowflake refreshes by itself. You set a target lag, such as one hour. The Customer 360 table will be one. Status: **verified** on the old account, same edition.

### Stream
A marker that records which rows are new since you last looked. Status: **from the docs**.

### Task
A job that runs SQL on a schedule or when something happens. A triggered task can start when a stream has new data. We will use this so new call transcripts are analysed without anyone pressing a button. Status: **from the docs**.

---

## 6. Questions in plain language

### Semantic view
A description of your tables in business words: what a customer is, what churn risk means, how tables join. Status: creating one is **verified**.

### Cortex Analyst
Turns a question such as "which gold customers mentioned a rival?" into SQL, using a semantic view. Status: **verified** on the event account. A REST call with our token returned the SQL for "What is the average age?" and a note of how it read the question.

### Cortex Search
Finds text by meaning, not just matching words. We use it over call transcripts to answer "why is this customer unhappy?". Status: creating a search service is **verified** on the event account.

### Cortex Agent
An AI that decides which tool to call. Our agent has these tools, in priority order: Cortex Analyst, Cortex Search, a procedure that records an approved action, data to chart, and code execution last. Threads keep the conversation between questions. Status: creating an agent is **verified** on the event account. The syntax is `CREATE AGENT name FROM SPECIFICATION $$ ...yaml... $$` with no equals sign.

---

## 7. Prediction

### Churn model
Trains a model on past customers, for example to predict which ones will leave, and scores current customers.

Snowflake's built-in classifier does not work on our accounts. It fails with "CLASSIFICATION must have an active version defined", on both accounts and with clean data. We do not use it.

`CREATE SNOWFLAKE.ML.CLASSIFICATION` is itself the training step, so there is no separate trained model to supply. We tried a clean schema, evaluation off, skipping bad rows, a boolean label and the schema privilege grant. The docs recommend a Medium Snowpark-optimized warehouse, but Snowflake refuses to create one on the event account, because only Gen2 warehouses are allowed. So that setup could not be tested. The cause is unknown and no documentation page mentions the error.

We use a Python stored procedure with scikit-learn instead. Status: **verified** on the event account, where a gradient boosting model trained inside Snowflake on 3,000 rows. Two lessons: put the packages in the procedure definition, and read rows with `collect()` because converting to pandas failed.

### Feature and score
A feature is one fact about a customer used by the model, such as missed payments. The score is the probability that the customer leaves. We also store the top features behind each score, so the screen can say why.

---

## 8. Protecting data

### Masking policy
A rule that hides a column from roles that should not see it. An email can show as `a***@x.com`. Status: **verified**.

### Role-based view
A view that only shows what a role is allowed to see. The app reads these views, never the raw tables.

### Guardrails
Snowflake can watch what AI tools read and block hidden instructions inside text. This matters because call transcripts are text an attacker could write.

- **What it covers:** prompt injection, jailbreak attempts and new attack patterns. It applies to CoCo, Cortex Agents and Snowflake CoWork. It does not cover a plain `COMPLETE` call or the REST chat calls, so the protection reaches our app through the agent.
- **Needs:** Enterprise edition and cross-region inference, and both accounts have them.
- **Switch on**, as `ACCOUNTADMIN`. The setting is the account parameter `AI_SETTINGS`, which is empty on the event account, so guardrails are off:

      ALTER ACCOUNT SET AI_SETTINGS = $$
        guardrails:
          advanced_prompt_injection:
            - enabled: true
      $$;

- **Switch off:** `ALTER ACCOUNT UNSET AI_SETTINGS;`
- **Log:** `SNOWFLAKE.ACCOUNT_USAGE.CORTEX_AI_GUARDRAILS_USAGE_HISTORY`. Rows with `GUARDRAILS_SIGNAL = TRUE` are flagged requests. The view can be read on the event account and is empty for now. Account usage views can lag behind real time.
- **Cost:** credits for the tokens scanned. Some harmless prompts may be flagged.

Status: the setting and the log view are **verified** to exist. Turning it on has **not been tried**.

---

## 9. How the app talks to Snowflake

| Need | Interface | Status |
|---|---|---|
| Read tables and views | SQL API, `/api/v2/statements` | Verified |
| Chat with Claude | Messages API, `/api/v2/cortex/v1/messages` | Verified |
| Chat with any model | Chat completions, `/api/v2/cortex/v1/chat/completions` | Reached and authenticated. Use `max_completion_tokens`, since `max_tokens` is deprecated |
| Ask about data | Cortex Analyst, `POST /api/v2/cortex/analyst/message` | Verified |
| Run the agent | The agent `run` endpoint | From the docs |

All calls go to our own Snowflake address, so the Claude models run under Snowflake and bill in Snowflake credits. No separate Anthropic account is involved.

Every call sends the token as `Authorization: Bearer <token>` with the header `X-Snowflake-Authorization-Token-Type: PROGRAMMATIC_ACCESS_TOKEN`. The Messages API also asks for `anthropic-version: 2023-06-01`. Our test worked without it, but the docs list it as required, so the app will send it. The token stays in the Next.js server routes and is never sent to the browser.

The role the app uses must hold `SNOWFLAKE.CORTEX_USER` or the narrower `SNOWFLAKE.CORTEX_REST_API_USER`. We give the app the narrower one. Chat calls support streaming, tool calling and structured JSON output. Limits per minute apply and return HTTP 429 when exceeded, so the app retries with a growing delay. Usage can be read from `SNOWFLAKE.ACCOUNT_USAGE.CORTEX_REST_API_USAGE_HISTORY`, which already shows our test call.

Task history is readable with SQL, which the Activity screen needs. Status: **verified**.

---

## 10. CoCo, the tool we build with

CoCo, also called Cortex Code, is Snowflake's AI coding assistant. The hackathon requires that we use it across planning, development, execution and testing.

Command we use:

    cortex exec -c cocohack --blocked "Bash,Write,Edit" --max-turns 5 "<task>"

- `cortex exec` runs one task and exits.
- `-c cocohack` picks the connection to the event account.
- `--blocked` stops CoCo using the shell or writing files, so it can only work in Snowflake.
- Every session is saved. `cortex conversations list` shows them and `cortex conversations transcript <id>` prints one. These are our evidence for the judges.

---

## Things learned the hard way

- Free trial accounts block Cortex AI functions and CoCo CLI until a card is added. The event account link avoids this.
- Trial accounts block external access, so Snowflake code cannot call outside websites. We do not need to.
- A token needs either a network policy or an authentication policy that waives it.
- `ALTER USER ... SET AUTHENTICATION POLICY` takes the policy name with no equals sign.
- Run SQL one statement at a time when learning. A failure in the middle of a script can hide which line failed.

---

## Words to know

| Word | Meaning |
|---|---|
| Object | Anything you create: a table, view, role, task |
| Fully qualified name | `DATABASE.SCHEMA.OBJECT` |
| Target lag | How stale a dynamic table may be |
| Serverless | Snowflake picks the computer, so you do not choose a warehouse |
| Region | Where the account runs. Ours is AWS Jakarta |
| Cross-region inference | Lets Cortex use a model hosted in another region. It is already on |
