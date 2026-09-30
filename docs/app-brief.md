# App Brief

The web app for Retention Copilot. A retention manager at Suraksha General Insurance opens it to see who is at risk, understand why, ask questions and record a decision on a recommended action.

The data is synthetic and every screen says so.

---

## Stack

- Next.js App Router with TypeScript and React. No UI library and no CSS framework.
- Styling: CSS Modules that use only the tokens in `src/styles/theme.css`. Light theme only. No colour is written by hand in a component.
- Font: Source Sans 3 from Google Fonts through `next/font`, weights 400, 600 and 700.
- Icons: small inline SVG line icons, 24 by 24, stroke 1.8, round ends, colour from `currentColor`.
- Node 24. Keep dependencies to the minimum: next, react, react-dom, typescript, the type packages and `server-only`.

## Shape of the code

These rules come from the project's CLAUDE.md and apply to every file.

- One thing per file, named after it: one component, one hook, one type or interface, one function group per file.
- No comments anywhere. Plain full word names, no abbreviations. Functions under about thirty lines and files under about two hundred.
- Folders: `src/types`, `src/components`, `src/hooks`, `src/styles`, `src/lib`, and routes under `src/app`. Inside `src/lib` make a folder per area, for example `src/lib/snowflake` and `src/lib/agent`.

## Security rules

- The browser never sees the Snowflake token. All Snowflake calls happen in server code under `src/lib` and `src/app/api`, and `src/lib` files that use the token import `server-only`.
- Configuration comes from environment variables and is read in one place: SNOWFLAKE_ACCOUNT_URL, SNOWFLAKE_TOKEN, SNOWFLAKE_WAREHOUSE, SNOWFLAKE_DATABASE, SNOWFLAKE_SCHEMA, SNOWFLAKE_ROLE, SNOWFLAKE_AGENT, SNOWFLAKE_SEMANTIC_VIEW. They live in `.env.local`, which is git ignored. Provide `.env.example` with names only and no values.
- The token belongs to a service user that can only hold the read only role. It can read the views in the APP schema, call the agent and call one procedure. Every SQL statement in the app must use only the APP schema.
- Send SQL through the Snowflake SQL API at `POST {account url}/api/v2/statements` with the headers `Authorization: Bearer <token>`, `X-Snowflake-Authorization-Token-Type: PROGRAMMATIC_ACCESS_TOKEN`, JSON body with statement, warehouse, role, database, schema, timeout and `bindings` for every user supplied value. Never build SQL by joining user text into a statement. Results come back as arrays of strings, convert numbers and booleans in one place. Handle result partitions if there are several.
- Validate every input on the server: a customer id must match C followed by six digits, an action id ACT followed by six digits, a decision one of Approved, Dismissed, Needs review, a note at most 300 characters, a question at most 500 characters, a search text at most 60 characters, a limit between 1 and 100.
- Return short plain error messages to the browser and log nothing secret. Never return stack traces.
- The agent is called at `POST {account url}/api/v2/databases/{database}/schemas/{schema}/agents/{agent}:run` with the same token headers and `Accept: text/event-stream`. The body is `{"messages":[{"role":"user","content":[{"type":"text","text":"..."}]}]}`, and follow up questions send the earlier messages of the conversation too. The stream is server sent events. The events that matter are response.text.delta (data has a text field), response.tool_use (data has a name), response.table (a result table) and response.chart. The route re-streams a small cleaned up set of events to the browser and never forwards raw events.

## Data the app may read

All in the APP schema:

- `APP.CUSTOMER_OVERVIEW`: one row per active customer, 4,636 rows. Columns: CUSTOMER_ID, FIRST_NAME, CITY, STATE, SEGMENT, TENURE_MONTHS, ACTIVE_POLICIES, TOTAL_MONTHLY_PREMIUM, PRODUCTS_HELD, LATE_PAYMENTS, FAILED_PAYMENTS, LATE_OR_FAILED_RATE, CLAIMS_COUNT, OPEN_CLAIMS, REJECTED_CLAIMS, TICKETS_COUNT, OPEN_TICKETS, ESCALATED_TICKETS, AVERAGE_SATISFACTION, CALLS_COUNT, AVERAGE_SENTIMENT, NEGATIVE_CALLS, RIVAL_MENTIONS, CANCEL_INTENT_CALLS, CHURN_PROBABILITY (0 to 1), RISK_TIER (High, Medium, Low), TOP_DRIVER_1, TOP_DRIVER_2, TOP_DRIVER_3, ACTION_ID, ACTION_TYPE, ACTION_CHANNEL, ACTION_REASON, ACTION_CONFIDENCE (High, Medium, Low), ACTION_STATUS (Pending, Needs review, Approved, Dismissed), PRIORITY_RANK, REVENUE_AT_RISK (expected annual premium loss in rupees), DRAFT_MESSAGE. Action columns are empty for Low tier customers.
- `APP.CALL_OVERVIEW`: one row per call, 1,000 rows. Columns: TRANSCRIPT_ID, CUSTOMER_ID, FIRST_NAME, CITY, CALL_AT, SENTIMENT_SCORE (-1 to 1), MAIN_TOPIC, COMPETITOR_MENTIONED, COMPLAINT_REASON, WANTS_TO_CANCEL, TRANSCRIPT_TEXT.
- Procedure `APP.RECORD_ACTION_DECISION(ACTION_ID, DECISION, NOTE)` returns a text message, the only write the app may make.
- The Cortex Agent described above.

## Screens

Every page has the same frame: a top bar and a collapsible side panel.

**Top bar, left to right:** the product mark and the name Retention Copilot, one box that says Ask or search a customer, and a badge that reads Manager. Typing a customer id such as C000123 opens that customer. Any other text opens the Ask page and asks that question.

**Side panel:** icon and label for Overview, Customers, Ask. A chevron button at the top collapses it to an icon rail of 68 pixels, the open width is 212 pixels. The choice is remembered in the browser. On a phone it becomes a row across the top and the collapse button is hidden. Impact and Activity are added later, leave room for them.

**Footer line on every page:** Synthetic data. Risk figures are modelled and only demonstrate the workflow.

**Overview (/):** four summary tiles: customers at risk (High plus Medium), high risk customers, expected revenue at risk in rupees written in lakh or crore, actions waiting (Pending plus Needs review). Below, bars for the share of customers who are High risk by segment (Gold, Silver, Standard). Below, the priority list: the top 25 by PRIORITY_RANK with customer first name and city, risk chip with the percentage, the action type, confidence chip, status chip and revenue at risk. Filter chips All, High, Medium work on the loaded rows. A row opens the customer.

**Customers (/customers):** a search box (by id, first name or city) and filters for risk tier, then a table of up to 50 customers ordered by priority. **Customer page (/customers/[id]):** header with first name, city, segment and id. Left column: policies and products, payment history counts, claims, tickets, and satisfaction, all from the overview row. Right column: a risk card with the percentage, the tier and up to three reasons; an action card with the action type, channel, reason, confidence, status, the draft message in a quiet box labelled Draft for review, and buttons Approve and Dismiss. Pressing a button opens an inline confirmation with an optional note and a Confirm button, then calls the decision route and shows the returned message and the new status. Below: the call timeline, newest first, each call showing date, topic, sentiment as a small labelled chip, rival mention, and the transcript expandable.

**Ask (/ask):** a chat page. The user types a question, the answer streams in. Show small chips naming the tools used. If a table comes back render it as a table. Show suggested first questions when the chat is empty: How many high risk customers are there in each city? Which customers should we call first? What are customers saying when they mention a rival insurer? Keep the conversation in the page state and send earlier messages with each new question. Never render HTML from the agent, render text only.

## Visual rules

White surfaces, Snowflake blue, one typeface, rounded shapes (radius 16 for cards, 12 for controls, fully round for chips and bars), one pixel borders in the border colour, no shadows and no gradients. Risk is always a chip with an icon, a word and a number so colour is never the only signal. Deep blue for text links, buttons and icons, bright blue only for filled shapes such as bars. Numbers in tables use tabular figures. Focus rings are visible. Layout works at phone width with no horizontal page scroll.

## API routes

- GET /api/overview returns the four tile values, the segment shares and the top 25 priority rows.
- GET /api/customers with optional search, tier and limit returns customer summary rows.
- GET /api/customers/[id] returns one customer overview row.
- GET /api/customers/[id]/calls returns that customer's calls newest first, transcript text included.
- POST /api/recommendations/[id]/decision with a JSON body of decision and note calls the procedure and returns the message and the new status.
- POST /api/questions with a JSON body of the conversation messages streams the agent answer.
