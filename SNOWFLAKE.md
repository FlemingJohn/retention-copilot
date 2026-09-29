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
Turns a question such as "which gold customers mentioned a rival?" into SQL, using a semantic view. It is enabled on both accounts. Status: **untested** on the event account.

### Cortex Search
Finds text by meaning, not just matching words. We use it over call transcripts to answer "why is this customer unhappy?". Status: creating a search service is **verified** on the event account.

### Cortex Agent
An AI that decides which tool to call. Our agent has these tools, in priority order: Cortex Analyst, Cortex Search, a procedure that records an approved action, data to chart, and code execution last. Threads keep the conversation between questions. Status: **from the docs**.

---

## 7. Prediction

### Snowflake ML
Trains a model inside Snowflake, for example to predict which customers will leave, and scores new customers. The built-in classifier gave the error "CLASSIFICATION must have an active version defined" on the old account. **Untested** on the event account. The fallback is Snowpark ML.

### Feature and score
A feature is one fact about a customer used by the model, such as missed payments. The score is the probability that the customer leaves. We also store the top features behind each score, so the screen can say why.

---

## 8. Protecting data

### Masking policy
A rule that hides a column from roles that should not see it. An email can show as `a***@x.com`. Status: **verified**.

### Role-based view
A view that only shows what a role is allowed to see. The app reads these views, never the raw tables.

### Guardrails
Snowflake can watch what AI tools read and block hidden instructions inside text. This matters because call transcripts are text an attacker could write. It needs Enterprise edition, which the accounts have. How to switch it on is **not confirmed**.

---

## 9. How the app talks to Snowflake

| Need | Interface | Status |
|---|---|---|
| Read tables and views | SQL API, `/api/v2/statements` | From the docs |
| Chat with a model | Cortex REST API, `/api/v2/cortex/v1/chat/completions` | From the docs |
| Ask about data | Cortex Analyst, `POST /api/v2/cortex/analyst/message` | From the docs |
| Run the agent | The agent `run` endpoint | From the docs |

All calls need a token. The token stays in the Next.js server routes and is never sent to the browser. It is not yet confirmed that the SQL API accepts our token type. The fallback is the Node.js driver.

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
