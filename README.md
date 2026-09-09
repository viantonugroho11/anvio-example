# Hermes Engineering Platform — Anvio edition

A multi-agent software engineering platform migrated from the Hermes Agent CLI to
the [Anvio](https://anvio-docs.vercel.app) local-first Agent Operating System. Business
logic — 9 role profiles, ~60 skills, ~10 workflows, MCP integrations — is preserved
1:1; the runtime is now Anvio.

For the full "why" and per-file rationale see [docs/migration.md](docs/migration.md)
and [docs/decision-log.md](docs/decision-log.md).

## Architecture

```
Telegram / Slack / CLI / REST / web-chat
    ↓
Anvio channel adapter → ChannelHub → Session
    ↓
Agent (workspace/agents/<role>.yaml)
   ├── Persona (workspace/personas/<role>.md)
   ├── Soul    (workspace/souls/<role>-soul/SOUL.md)  — approvers, mandate
   └── Skills  (workspace/skills/<slug>.md)
    ↓
Runtime: claude-code (Claude Pro/Max OAuth) → fallback local
    ↓
Model provider — local hop only (DeepSeek → workspace/providers/routing.yaml)
    ↓
Tool gateway + MCP bridge (workspace/mcp/servers.yaml)
    ↓
Memory (filesystem SoT + optional Postgres/Qdrant vector index)

A2A (v2.4.0):
    /.well-known/agent.json  →  Agent Card discovery
    /a2a/*                   →  JSON-RPC 2.0 + REST + SSE streaming
    A2ATool                  →  delegate to external A2A agents as tools
```

## Quick start

```bash
# 1. Install Anvio (once per machine)
curl -fsSL https://raw.githubusercontent.com/viantonugroho11/Anvio/main/scripts/install.sh | bash
source ~/.anvio/env
anvio --version    # need >= v2.5.0 — A2A on official SDK, slash-command sanitization, etc.

# 2. Point Anvio at this workspace
export ANVIO_WORKSPACE=$PWD/workspace
make validate      # runs `anvio workspace validate`

# 3. Authenticate the runtime (Claude Pro/Max subscription OAuth — ADR-009)
make setup-token-claude          # wraps `claude setup-token`; token stored encrypted
# Fallback model provider for the `local` hop only:
export DEEPSEEK_API_KEY=sk-...

# 4. List agents / skills / workflows
make agents
make skills
make workflows

# 5. Chat with an agent, or run a one-shot task
make chat AGENT=tech-lead
make run  AGENT=architect Q="Design a JWT refresh-token endpoint"

# 6. Run a workflow (multi-agent DAG)
anvio workflow run feature-development \
  task="Add JWT refresh-token endpoint" \
  acceptanceCriteria="401 on expired token, sliding session, rate-limited"
```

## Profiles

Preserved 1:1 from Hermes. Each profile is bound by an Agent, a Persona, and a Soul.

| Slug | Role | Focus |
|---|---|---|
| `architect` | System Architect | Design, ADRs, architecture review |
| `frontend` | Frontend Engineer | UI/UX, frontend architecture (delegates code to Cursor) |
| `backend` | Backend Engineer | APIs, business logic, data (delegates code to Cursor) |
| `devops` | DevOps Engineer | Infrastructure, CI/CD, deployment |
| `qa` | QA Engineer | Testing, quality gates |
| `researcher` | Research Engineer | Technical research, prototyping (read-only) |
| `documenter` | Document Writer | Documentation, guides |
| `reviewer` | Reviewer | Code/security review (required gate; delegates to Cursor) |
| `tech-lead` | Tech Lead | Roadmap, estimation, delegation (default entry point) |

## Planner and workflows

The Hermes `configs/planner.yaml` PLAN → EXECUTE → REVIEW → FINALIZE routing is
translated to a native Anvio Workflow DAG at
[workspace/workflows/planner.md](workspace/workflows/planner.md) per ADR-006. The
reviewer soul's `## Approvers` block enforces the quality gate.

Other canonical workflows live under [workspace/workflows/](workspace/workflows/):
`feature-development`, `code-review`, `architecture-review`, `bug-investigation`,
`database-migration`, `deployment`, `release-preparation`, `cursor-coding`,
`cursor-code-review`, `incident-response`.

## Skills

~60 skills live under [workspace/skills/](workspace/skills/) — invoke with `/skill-name`
inside a session. Bodies preserved verbatim from Hermes; envelope normalized to
Anvio's `kind: Skill` schema.

Highlights:
- `clean-architecture`, `ddd`, `system-design`, `event-storming` — architecture
- `cursor-delegate`, `cursor-coding`, `cursor-code-review` — Cursor Agent delegation
- `semantic-memory` — PGVector-backed long-term memory
- `feature-development`, `incident-response`, `bitbucket-pr-workflow` — process
- `krakend-generator`, `kafka-consumer`, `postgres-optimization` — technology

## Cursor delegation (Anvio → Cursor Agent)

Backend, frontend, and reviewer profiles delegate the *actual code writing* to
[Cursor Agent](https://cursor.com). Anvio orchestrates; Cursor executes.

```bash
make cursor-delegate-setup            # install @cursor/sdk
export CURSOR_API_KEY=cursor_...      # from cursor.com/dashboard/cloud-agents
```

For Bitbucket private repos, Cursor runs in local mode against a mounted workspace:

```bash
make workspace-init
make workspace-clone REPO=order-tyche BITBUCKET_WORKSPACE=your-workspace
```

## Runtime auth — Claude Code OAuth

Agents run on the **`claude-code` runtime**, authenticated against a Claude Pro/Max
subscription rather than a metered API key (ADR-009). See Anvio's
[Runtime OAuth](https://anvio-docs.vercel.app/docs/security/runtime-oauth).

```bash
make setup-token-claude    # → anvio setup-token --claude
make auth-status           # list stored connections
```

The token is encrypted by the connection broker under `workspace/connections/`
(`service: claude-code`). Headless hosts and containers instead set
`CLAUDE_CODE_OAUTH_TOKEN`.

> **Do not set `ANTHROPIC_API_KEY`** in the same environment. It shadows OAuth and
> silently bills API credits instead of subscription quota. `make setup-token-claude`
> refuses to run if it is set.

`spec.model.model` in each agent is a **Claude** id (`sonnet`) — `ClaudeCodeRuntime`
passes it straight to the Agent SDK, so a DeepSeek model id there fails with
*"There's an issue with the selected model"*.

Fallback chain per agent: `claude-code → local` (and `→ cursor → local` for
`backend`, `frontend`, `reviewer`). The `local` hop is the only consumer of
`workspace/providers/routing.yaml`.

## Telegram

Native long-polling adapter — no webhook, no public URL. Enabled in
[workspace/anvio.yaml](workspace/anvio.yaml) under `spec.channels.telegram`.

```bash
cp .env.example .env       # fill TELEGRAM_BOT_TOKEN (from @BotFather)
make telegram              # health-check: `anvio channels status`
make gateway               # start the daemon — this is what actually polls Telegram
```

**Nothing polls Telegram until the gateway daemon runs** — config alone is inert, and
`anvio gateway start` needs `--foreground` ([Anvio#50](https://github.com/viantonugroho11/Anvio/issues/50)).

Run exactly one instance. `anvio run` / `anvio chat` also start a Telegram poller and
never stop it ([Anvio#48](https://github.com/viantonugroho11/Anvio/issues/48)); a leftover
CLI process races the gateway for `getUpdates`, wins some of them, and drops those
messages — the bot goes silent while `anvio channels status` still reports `healthy`.
If replies stop, look for stragglers:

```bash
ps aux | grep 'apps/cli/dist/main.js'   # kill anything that is not the gateway
```

Default agent is `tech-lead`; mention another role to route to it. Forum topics map
1:1 to sessions via `message_thread_id`, and tool approvals render as inline
Approve/Reject buttons backed by the same Soul Gate flow as Slack.

## Slack

Slack uses Anvio's **native Socket Mode channel adapter** ([packages/channels/slack](https://anvio-docs.vercel.app/docs/channels/adapters)) — no Python bridge, no Playwright. Enabled in [workspace/anvio.yaml](workspace/anvio.yaml) under `spec.channels.slack`.

```bash
export SLACK_BOT_TOKEN=xoxb-...     # bot token
export SLACK_APP_TOKEN=xapp-...     # app-level token, needs connections:write
anvio gateway start
```

Slack `thread_ts` maps 1:1 to an Anvio session; approvals render as Block Kit buttons.
Requires Socket Mode enabled in the Slack app + subscriptions to `message.channels`,
`message.im`, `message.groups`.

## A2A — Agent-to-Agent protocol (v2.5.0)

Anvio implements [Google's A2A protocol v1.0](https://a2a-protocol.org/latest/)
for cross-platform agent interoperability (ADR-016, upstream ADR-0026). Since v2.5.0,
backed by the official [`@a2a-js/sdk` v1.1.0](https://github.com/nichochar/a2a-js) —
protobuf-generated types, SDK transport handlers, and `AnvioAgentExecutor` bridging to
the Anvio runtime. Enabled in `workspace/anvio.yaml` under `spec.a2a.enabled: true`.

**Server** — exposes all workspace agents via Agent Cards at `/.well-known/agent.json`.
External A2A clients (CrewAI, AutoGen, LangGraph, etc.) can discover and interact with
your agents via JSON-RPC 2.0 or REST + SSE streaming on `/a2a/*`.

**Client** — `A2ATool` wraps any external A2A agent as a native Anvio tool. Register
the remote agent's URL and your agents can delegate tasks to it transparently.

Key routes (on the Unified Gateway):

| Route | Description |
|---|---|
| `/.well-known/agent.json` | Agent Card discovery |
| `/a2a` | JSON-RPC 2.0 endpoint |
| `/a2a/messages` | REST: send message |
| `/a2a/messages:stream` | REST: send message with SSE |
| `/a2a/tasks/:id` | REST: get/cancel task |
| `/a2a/tasks/:id:subscribe` | SSE: subscribe to task updates |

> **Note**: `createPlatform` doesn't auto-wire `a2aServer` yet — the config key is
> forward-looking. See the
> [A2A integration guide](https://github.com/viantonugroho11/Anvio/blob/main/docs/78-a2a-protocol.md)
> for programmatic setup.

## Semantic memory

`memory/` (Markdown) is the source of truth. It is indexed into
Postgres/pgvector (or Qdrant) via Anvio's memory provider — see ADR-005 for the
current state and the migration off `scripts/index_memory.py`.

```bash
make memory-up            # start postgres-memory on port 5433
make memory-index         # embed memory/ into vector store
make memory-search Q="ADR kafka"
```

## Observability

Langfuse + OTel + Prometheus + Grafana are provided by the same
`docker-compose.observability.yaml` used in the source repo. Anvio's
`@anvio/observability` consumes the same Langfuse keys and OTLP endpoint — no
changes required beyond setting env vars.

```bash
make telemetry-setup
make observability-up
```

- Langfuse UI — http://localhost:3000
- Grafana — http://localhost:3001 (admin/admin)
- OTel collector — grpc :4317, http :4318

## Repository layout

```
anvio-example/
├── source-repo/                     # Source of truth — DO NOT modify
├── anvio-docs/                      # Anvio documentation — reference only
├── workspace/                       # THE MIGRATED CONFIG (Anvio workspace)
│   ├── anvio.yaml                   # workspace-level config
│   ├── providers/routing.yaml       # DeepSeek default provider
│   ├── mcp/servers.yaml             # MCP servers — only filesystem + github enabled;
│   │                                # the rest need real env (`${VAR}` is NOT expanded)
│   ├── agents/       (9)            # kind: Agent
│   ├── personas/     (9)            # kind: Persona
│   ├── souls/        (9)            # kind: Soul
│   ├── skills/       (~63)          # kind: Skill
│   ├── workflows/    (11)           # kind: Workflow (DAGs) — includes planner
│   └── memory/                      # filesystem memory + ADRs
├── docker/                          # compose files (memory, observability, telemetry)
├── .env.example                     # runtime OAuth + channel tokens (copy to .env)
├── docs/
│   ├── migration.md                 # Phase 2 mapping table + Phase 3 architecture
│   └── decision-log.md              # ADRs 001..010
├── Makefile                         # `make agents / skills / workflows / chat / run / …`
└── README.md                        # this file
```

## Documentation

- [docs/migration.md](docs/migration.md) — mapping table Hermes → Anvio + validation strategy
- [docs/decision-log.md](docs/decision-log.md) — ADR-001..016 (009 OAuth, 010 Telegram, 015 v2.0.2 upgrade, 016 A2A)
- Anvio docs — mirrored under [anvio-docs/](anvio-docs/) or online at https://anvio-docs.vercel.app

## License

MIT (inherited from source-repo).
