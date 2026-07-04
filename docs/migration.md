# Hermes → Anvio Migration

## Executive summary

`hermes-tech` is a **configuration-only** repo for the external Hermes Agent CLI: YAML+Markdown profiles, prompts, skills, workflows, plus one Python side-service. There is essentially no TypeScript to refactor. The **business logic *is* the configuration**.

Anvio is likewise a "local-first, file-first" agent OS whose primitives (`kind: Persona`, `kind: Skill`, `kind: Soul`, `kind: Agent`, `kind: Workflow`, `kind: McpConfig`) map one-to-one onto the Hermes concepts. The migration is therefore a **schema-preserving translation of files**, not a code rewrite.

## Phase 2 — Mapping table

| Hermes concept | Hermes file(s) | Anvio equivalent | Anvio file(s) |
|---|---|---|---|
| Profile (role definition) | `profiles/<role>.json` | `kind: Agent` + `kind: Persona` + `kind: Soul` (split by concern) | `workspace/agents/<role>.yaml`, `workspace/personas/<role>.md`, `workspace/souls/<role>-soul/SOUL.md` |
| Role system prompt | `prompts/<role>.md` | Persona body (`spec.systemPrompt`) | `workspace/personas/<role>.md` body |
| Skill (procedure) | `skills/<slug>/SKILL.md` (frontmatter + body) | `kind: Skill` (Markdown form) | `workspace/skills/<slug>.md` |
| Workflow | `workflows/<slug>/workflow.md` | `kind: Workflow` DAG | `workspace/workflows/<slug>.md` |
| Planner (routing + phases + gates) | `configs/planner.yaml` | A blueprint/workflow *plus* per-soul approver policy | `workspace/workflows/planner-*.md` + Soul `## Approvers` / `## Approval timeout` sections |
| Global runtime config | `configs/config.yaml` | Workspace + provider routing | `workspace/anvio.yaml` + `workspace/providers/routing.yaml` |
| MCP servers | `configs/mcp/mcp-servers.yaml` | `kind: McpConfig` | `workspace/mcp/servers.yaml` |
| Model provider (DeepSeek) | `model.provider: custom`, `base_url: https://api.deepseek.com/v1` | Built-in `deepseek` provider (or `provider: custom`) | `workspace/providers/routing.yaml` |
| Memory (facts + summaries) | `memory: memory_enabled`, `memory_char_limit`, `user_profile_enabled` | `spec.memory` | `workspace/anvio.yaml` `spec.memory` |
| Semantic memory (PGVector) | `semantic_backend: pgvector`, `scripts/index_memory.py`, `scripts/search_memory.py` | Qdrant or Postgres memory provider | `spec.memory.provider: qdrant \| postgresql` |
| Session compression | `compression: threshold, target_ratio, protect_last_n` | Anvio's built-in session summarizer (learning-loop) | Implicit; tune via storage provider + learning-loop config |
| Observability (Langfuse + OTel) | `observability.langfuse`, `observability.opentelemetry` | `@anvio/observability` — Langfuse + OTLP built in | Env vars: `OTEL_EXPORTER_OTLP_ENDPOINT`, `ANVIO_OTEL_ENABLED`, Langfuse via importable dashboard |
| Reasoning effort / max turns | `agent.max_turns`, `reasoning_effort` | Agent spec fields (per-agent override) | `workspace/agents/<role>.yaml` `spec.maxTurns` / `spec.reasoningEffort` |
| Telegram channel | Hermes gateway | Native `kind: Channel` `telegram` adapter | `workspace/anvio.yaml` `spec.channels.telegram` + `TELEGRAM_BOT_TOKEN` |
| Slack channel (Playwright bridge) | `services/slack-playwright/*.py` (Python UI-automation) | Native `slack` channel adapter (Socket Mode) — **eliminates the Python service** | `spec.channels.slack` + `SLACK_BOT_TOKEN` / `SLACK_APP_TOKEN` |
| Webhook (Grafana alerts) | `platforms.webhook.routes.grafana-alerts` | REST inbound + `Automation` trigger, or a custom webhook route | `POST /api/channels/...` or `automation` trigger |
| Cursor Agent delegation | `scripts/cursor-delegate/delegate.mjs` (@cursor/sdk) | `runtimes.cursor` (`CursorRuntimeProvider`, ACP or `agent -p`) | Agent spec: `runtime: cursor` |
| Bitbucket private repo mount | `docker/.env` `WORKSPACE_HOST_PATH`, `make workspace-clone` | Same host-mount pattern; Anvio has no opinion here | Unchanged |
| Toolsets (`file`, `web`, `todo`) | Hermes built-ins | Anvio built-in tool gateway (73 tools) | Implicit; filter via `harness/defaults.yaml` `toolSurface` |
| Facts vs procedures split | `memory/*` MD + `skills/*` MD | Same split enforced by schema (`kind: Memory` vs `kind: Skill`) | Preserved |
| Profile isolation (HERMES_HOME) | Per-profile HERMES_HOME | Per-agent workspace scoping | Single workspace; sessions namespaced by agent |

### Concepts with no direct equivalent

| Hermes | Anvio disposition |
|---|---|
| `configs/planner.yaml` phase engine (PLAN→EXECUTE→REVIEW→FINALIZE) | Anvio has no dedicated planner phase engine. **Encode as a Workflow DAG** with `agent` nodes for each phase, using `dependsOn` for ordering and the `reviewer` soul's `## Approvers` block for the gate. |
| Complexity scoring (`simple_threshold`, `medium_threshold`, signals) | Anvio has no scorer. **Encode as a `transform` node** at the top of the planner workflow that emits a category, then `conditional` nodes branch on it. |
| `configs/config.yaml` `platform_toolsets.*` | Anvio decides tool surface per channel via `toolSurface`. Map each Hermes toolset to `mcp_and_channel` (locked) or full gateway. |
| Cursor-only skills (`/cursor-coding`, `/cursor-code-review`) | Keep the skills; set the executing agent's `runtime: cursor`. |

## Phase 3 — Target architecture

### Folder layout of the migrated repo

```
anvio-example/
├── source-repo/                  # SoT — untouched
├── anvio-docs/                   # reference — untouched
├── workspace/                    # THE MIGRATION TARGET
│   ├── anvio.yaml                # storage, memory, events, defaults, channels
│   ├── agents/                   # kind: Agent (one per Hermes profile)
│   │   ├── architect.yaml
│   │   ├── backend.yaml
│   │   ├── frontend.yaml
│   │   ├── devops.yaml
│   │   ├── qa.yaml
│   │   ├── researcher.yaml
│   │   ├── documenter.yaml
│   │   ├── reviewer.yaml
│   │   └── tech-lead.yaml
│   ├── personas/                 # kind: Persona (tone + systemPrompt)
│   │   └── <role>.md
│   ├── souls/                    # kind: Soul (durable identity + policy)
│   │   └── <role>-soul/SOUL.md
│   ├── skills/                   # kind: Skill (~60 files, 1:1 with Hermes)
│   │   └── <slug>.md
│   ├── workflows/                # kind: Workflow (DAG)
│   │   ├── feature-development.md
│   │   ├── code-review.md
│   │   ├── planner.md           # planner.yaml → DAG
│   │   └── ...
│   ├── mcp/servers.yaml          # kind: McpConfig
│   ├── providers/routing.yaml    # model routing (DeepSeek default)
│   └── memory/                   # filesystem memory
├── docker/                       # retargeted compose files
├── docs/
│   ├── migration.md              # this file
│   ├── decision-log.md           # ADRs
│   ├── architecture.md
│   ├── folder-structure.md
│   ├── agents.md
│   ├── skills.md
│   ├── workflows.md
│   └── testing.md
└── README.md
```

### Layering (native Anvio; no additional Clean-Architecture wrapper)

Anvio *is* the runtime; adding an application/domain/infrastructure/interfaces split on top of a config-only workspace would be ceremony (see ADR-002 in `decision-log.md`). The Anvio monorepo itself already enforces `apps → platform → packages → core`; workspace files consume that surface declaratively.

The workspace is config-only; there is no code to layer. Slack is handled by Anvio's native channel adapter (see ADR-008), so the Python Slack bridge from source-repo is not carried into this project.

### Runtime lifecycle after migration

```
User (Telegram / Slack / CLI)
        ↓
Anvio channel adapter (packages/channels)
        ↓
ChannelHub → Session → RuntimeRoutingAgentRuntime
        ↓
Agent (workspace/agents/<role>.yaml)
   ├── Persona (workspace/personas/<role>.md)
   ├── Soul     (workspace/souls/<role>-soul/SOUL.md) — approvers, mandate
   └── Skills   (workspace/skills/<slug>.md, resolved by slug list)
        ↓
Model provider (DeepSeek by default → providers/routing.yaml)
        ↓
Tool gateway  (built-ins)  +  MCP bridge  (workspace/mcp/servers.yaml)
        ↓
Memory (facts, session summaries) — filesystem → optional Qdrant/Postgres
```

## Deliverables per translated file (template)

For every migrated artifact this repo will record, in git commit messages and `docs/decision-log.md` where non-obvious:

1. **What** was migrated (source path → target path)
2. **Why** the shape changed (schema difference, feature-parity fix, etc.)
3. **Old** source (verbatim frontmatter/body snippet)
4. **New** target (verbatim)
5. **Architectural reasoning** (which Anvio primitive was chosen and why)
6. **Trade-offs** (what we gained/lost)
7. **Risks** (behavior that could drift; how we'll detect it)
8. **Validation** (a specific check — e.g. "`anvio agents list` shows `architect`", "`anvio workflow validate feature-development` returns ok")

## Validation strategy

- **Structural** — `anvio workspace validate` must pass after each slice.
- **Enumeration** — `anvio agents list`, `anvio skill list`, `anvio workflow list` must show every migrated artifact.
- **Behavioral parity** — a corpus of representative prompts (`@architect design a payment ledger`, `@backend implement /login endpoint`, `@reviewer review PR #42`) is run against both stacks and outputs compared for tone, skill invocation pattern, and gate behavior.
- **MCP** — `anvio mcp test <id>` for each server; tool-count parity with the Hermes YAML.
- **Regression** — Slack smoke test via the native adapter: mention each agent, exercise `/cursor-code-review` and `/cursor-coding` via a session started from Slack, verify approvals render as Block Kit buttons.

## Risks

| Risk | Impact | Mitigation |
|---|---|---|
| Anvio's `Workflow` DAG cannot express Hermes's complexity-score routing verbatim | Medium — planner behavior may diverge on borderline requests | Add a `transform` node that computes a numeric score and use `conditional` nodes to branch. Log the score. |
| Semantic memory schema mismatch (PGVector custom SQL vs Anvio memory providers) | High — past ADRs may not surface until re-indexed | ADR-005 (see decision log): re-index into Qdrant or Postgres via Anvio's memory provider; keep the raw markdown SoT in `workspace/memory/` and treat the vector store as an index. |
| Cursor delegation nuances (`--cwd`, local vs cloud) | Medium | Use `runtime: cursor` on the relevant agents; smoke-test the `/cursor-coding` and `/cursor-code-review` skills against the real Cursor CLI. |
| Slack command parity (`/codereview`, `/code-task`, `/summary`) after dropping the Python bridge | Medium | Per ADR-008, either register Slack slash commands or add a lightweight command-router skill invoked by the Slack channel's default agent. Underlying skills (`/cursor-code-review`, `/cursor-coding`, memory summarization) are already reachable by mentioning the corresponding agent in Slack. |
| Skill catalog resolver reads `.yaml/.yml` only (per docs) | Low — hand-authored `.md` skills may not resolve via the low-level catalog resolver | Anvio's higher-level skill registry does read `.md`; if any skill doesn't appear via `anvio skill list`, dual-write it as `.yaml`. |
