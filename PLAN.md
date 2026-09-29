# Retention Copilot

Track 2 of the Snowflake CoCo CLI Hackathon, GCC Edition: Customer 360 and Next Best Action.

A tool for an insurer's or lender's retention manager. It shows one customer's unified profile, predicts churn risk, and recommends the next best action with a reason and a draft outreach message.

Submissions close on October 4, 2026. The event account claim window ends on October 3, 2026 (UTC).

---

## Scoring

| Criterion | Weight | How the project answers it |
|---|---|---|
| Technical execution | 40% | Cortex functions, dynamic tables, semantic views, Cortex Search, masking and REST APIs working together. The CoCo CLI workflow is documented. |
| Real-world relevance | 30% | A named persona, the retention manager, and a measured result: retention uplift on a holdout set and estimated revenue saved. |
| Solution completeness | 30% | A deployed app, a GitHub repository, a README with an architecture diagram, an MVP document and a three minute demo video. |

Both portal items are mandatory: a GitHub or deployed link, and the prototype or MVP document.

---

## Architecture

    Next.js on Vercel
      pages and components
      server routes, token kept on the server
            |
            |  SQL API, Cortex REST API, Cortex Analyst API
            v
    Snowflake event account
      raw tables
      transcript enrichment
      customer profile, a dynamic table
      churn model
      next best action
      semantic view and search
      masked, role-based views

All intelligence stays in Snowflake. Next.js only draws the screens and never exposes credentials to the browser.

---

## Pipeline

Each step has its own folder under `snowflake/`, in this order.

1. `setup` creates the database, schemas, roles and warehouse.
2. `synthetic-data` builds customers, policies, payments, claims, tickets and 500 to 2,000 call transcripts.
3. `transcript-enrichment` adds sentiment, complaint reason and competitor mentions with Cortex functions.
4. `customer-profile` joins structured features and transcript signals in one dynamic table.
5. `churn-model` trains a classifier and stores a score and the main drivers for each customer.
6. `next-best-action` picks an action from rules, then a Claude model writes the reason and the draft message.
7. `semantic-layer` holds the semantic view for Cortex Analyst and the Cortex Search service on transcripts.
8. `agent` holds the Cortex Agent that turns a question into a recommended action. Its tools are Cortex Analyst, Cortex Search and a custom procedure that records an approved action.
9. `automation` holds the stream on new transcripts and the triggered task that enriches them without a person starting it.
10. `governance` holds masking policies on personal data, the role-based views the app reads, and the confidence checks that make the agent fail safely.

The customer question and the recommended action happen in one experience: an answer lists customers and each row offers the action.

---

## CoCo usage

Every phase is done through CoCo CLI, and evidence of each is saved in `docs/coco-evidence/`.

| Phase | What CoCo does | Evidence |
|---|---|---|
| Planning | Explores the data, frames the problem, drafts the data model and workflow | Session log and the resulting design notes |
| Development | Builds the pipelines, semantic view, model, agent and application code | Session logs and commits |
| Execution | Runs the full solution, including the scheduled task | Task run history and session log |
| Testing | Validates outputs, accuracy, errors and edge cases before the demo | Test session log and results |

Extras, in order of value:

1. A reusable CoCo skill, documented so other teams can use it. Skills are Markdown files with a name and description, kept in `.cortex/skills/` and shared with `cortex skill add` or published to a stage.
2. An MCP connector, for example Slack or Jira, so an approved action posts to another tool. Servers are added with `cortex mcp add`.
3. Scheduled runs through a triggered Snowflake task.

---

## Screens

The app lives in `src/`.

- Customer search.
- Customer profile with every signal in one place.
- Churn risk with the drivers behind it.
- Recommended action and draft message, with an approve button.
- A question box that answers in plain language and shows the query it ran.

Server routes live in `src/app/api/`: `customers`, `recommendations` and `questions`.

---

## Account

- The event account is on AWS, region Jakarta, Enterprise edition.
- Cortex functions, Claude models, embeddings and Cortex Search work there.
- External access integrations are blocked on trial accounts. The project does not need them.
- Cross-region inference is already set to any region.

---

## Open questions

- Whether the built-in Snowflake ML classifier works on the event account. The fallback is Snowpark ML.
- Whether the SQL API accepts a programmatic access token. The fallback is the Node driver.

---

## Security

- The deployed app runs as a limited role and its own service user, never as the account administrator.
- Tokens used during setup are revoked when the build ends.
- Token lifetime must cover judging, October 5 to October 22.
- No token, key or password is committed to the repository. Values live in environment variables.

---

## Timeline

| Date | Work |
|---|---|
| Sep 29 to Sep 30 | setup, synthetic data, transcript enrichment |
| Oct 1 | customer profile, churn model, semantic layer |
| Oct 2 | next best action, app screens, server routes |
| Oct 3 | governance, deployment, testing, MVP document, README |
| Oct 4 | demo video and portal submission |
