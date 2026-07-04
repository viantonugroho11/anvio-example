# Decision Log

ADR-style records of architecturally-significant decisions taken during the Hermes → Anvio migration.

---

## ADR-001 — Migration is a configuration translation, not a code rewrite

**Status**: Accepted.

**Context**: The user's brief described the migration as if `hermes-tech` were a TypeScript agent codebase to be refactored into Clean Architecture with DI, DDD, application/domain/infrastructure layers. Analysis of the source repo shows it is a Hermes-CLI *configuration* repo — YAML+Markdown profiles/skills/workflows plus one small Python side-service. There is no imperative agent code to layer.

**Decision**: Treat the migration as a schema-preserving translation of declarative files into Anvio's native `kind: Persona | Skill | Soul | Agent | Workflow | McpConfig | Workspace` primitives. Do not build a TypeScript application on top. Do not introduce Clean Architecture / DDD scaffolding around Markdown files.

**Consequences**:
- (+) Faithful to both frameworks' philosophies (both are "file-first").
- (+) Migration output is small, reviewable, and diff-friendly.
- (+) Zero "adapter-heavy" wrapping — the anti-pattern the brief explicitly warned against.
- (–) The brief's Coding Standards section (TypeScript, DI, composition-over-inheritance, etc.) largely does not apply, because there is no TS code to write. Documented here so the deviation is explicit.

**User confirmation**: Recorded in this session's scope-check question.

---

## ADR-002 — No `application/domain/infrastructure/interfaces` split in the workspace

**Status**: Accepted.

**Context**: The brief asks for a Clean Architecture layering with separate application/domain/infrastructure/interfaces folders. Anvio's own monorepo already enforces `apps → platform → packages → core` internally; a workspace consumes those layers declaratively via YAML/MD.

**Decision**: Do not introduce a parallel layering inside `workspace/`. Use the Anvio-native folder structure (`agents/`, `personas/`, `souls/`, `skills/`, `workflows/`, `mcp/`, `providers/`, `memory/`) verbatim. Any code we do write (retained Python bridge) keeps its existing modular structure.

**Consequences**:
- (+) Matches every Anvio doc example and the `anvio init` scaffold.
- (+) `anvio workspace validate` passes without customization.
- (–) The brief's folder-structure section reads as unmet at a glance; ADR-001 + ADR-002 documented so a reviewer sees the reasoning.

---

## ADR-003 — Anvio replaces Hermes CLI as runtime

**Status**: Accepted (per user scope confirmation).

**Context**: Two runtimes co-existing is more surface area than the small team can maintain, and Anvio's feature set (native Slack/Telegram, Cursor runtime, PGVector-capable memory, Langfuse+OTel built in) covers all Hermes capabilities exercised in the source repo.

**Decision**: Anvio is the sole runtime post-migration. `hermes` CLI is removed from install docs, `make` targets that shell out to `hermes` become `anvio` equivalents, and the `hermes-agent.nousresearch.com` install line disappears from README.

**Consequences**:
- (+) One runtime, one set of docs, one telemetry pipeline.
- (–) Any Hermes-only feature we discover during Phase 4/5 becomes a real migration blocker rather than a workaround. Feature-parity check tracked in `docs/migration.md` § Risks.

---

## ADR-004 — Keep `services/slack-playwright/` in Phase 4 (deferred replacement)

**Status**: **Superseded by ADR-008.** Initial decision recorded below for history.

**Context**: User chose "Keep slack-playwright Python service, retarget it at Anvio's server." But Anvio ships a **native Slack channel adapter** (`packages/channels/src/slack.ts`, Socket Mode). Long-term, the native adapter is preferable — one less service, one less transport, native Block Kit approvals.

**Decision**:
- Phase 4: keep the Python service, change `HermesBridge` to call Anvio's REST (`POST /api/sessions`, `POST /api/sessions/:id/messages`) or CLI (`anvio run <agent> "<prompt>"`) instead of `hermes` subprocess. Preserve `/codereview`, `/code-task`, `/summary`, profile commands verbatim.
- Phase 5: enable `spec.channels.slack.enabled: true` in parallel behind a feature flag; migrate one command at a time; retire the Python service once all commands are covered.

**Consequences**:
- (+) Phase 4 lands quickly with no behavior change.
- (+) Users' Slack UX doesn't break mid-migration.
- (–) Two Slack surfaces exist briefly during transition. Mitigation: the Python bridge only listens to a controlled owner user + `@mention`, so accidental double-handling is scoped.

---

## ADR-005 — Semantic memory: re-index PGVector content into Anvio's memory provider

**Status**: Accepted.

**Context**: `hermes-tech` stores facts as Markdown in `memory/` and indexes them into PGVector via `scripts/index_memory.py`. Anvio's memory providers (`filesystem`, `sqlite`, `postgresql`, `qdrant`, `redis`, `honcho`) don't include a raw PGVector option, but `postgresql` and `qdrant` both cover the same use case.

**Decision**: Keep `memory/` (Markdown source-of-truth) as-is. Point Anvio at `postgresql` (using the same Postgres+pgvector instance already provisioned by `docker/docker-compose.memory.yaml`) *or* Qdrant — whichever Anvio's `postgresql` provider actually uses under the hood. Wire re-indexing to `anvio memory index` (or an equivalent job) so `scripts/index_memory.py` can be retired.

**Consequences**:
- (+) SoT stays as reviewable Markdown; index becomes an implementation detail.
- (–) One-time re-embedding cost when switching backends. Acceptable; corpus is small.

**Open item**: Confirm during Phase 4 whether Anvio's `postgresql` memory provider can share the existing pgvector extension or requires its own schema. If it requires its own, run both schemas side-by-side until Phase 5 cutover.

---

## ADR-006 — Planner phases modeled as a Workflow DAG, gates as Soul approvers

**Status**: Accepted.

**Context**: Hermes's `configs/planner.yaml` combines four things: (1) complexity scoring, (2) PLAN→EXECUTE→REVIEW→FINALIZE phase ordering, (3) mention-based routing, (4) required-agent quality gates.

**Decision**: Split these across Anvio primitives:

| Hermes concern | Anvio target |
|---|---|
| Phase ordering | A `kind: Workflow` DAG with `dependsOn` edges (`plan` → `execute` → `review` → `finalize`). |
| Complexity scoring | A `type: transform` node at the top emitting `{complexity: 'simple'\|'medium'\|'high'}`, then `type: conditional` nodes gating each phase. |
| Mention routing | Anvio channel routing (bot mentions map to `defaultAgent`) + a lightweight `type: agent` node with `agent: "{{inputs.mentioned_role}}"`. |
| Quality gates | The reviewer soul's `## Approvers` section — human-in-the-loop enforced by Soul Gate. |

**Consequences**:
- (+) Each concern uses the correct Anvio primitive; no monolithic planner.yaml.
- (+) Approvals are auditable via Anvio's approval events and channel affordances (inline buttons).
- (–) More files (workflow + 9 souls' approver sections) than Hermes's single YAML. Documentation cost.

---

## ADR-007 — Model provider: use built-in `deepseek` (or `custom`), not a wrapper

**Status**: Accepted.

**Context**: `configs/config.yaml` sets `model.provider: custom` with DeepSeek base_url. Anvio ships a first-class `deepseek` provider adapter — no `custom` gymnastics needed.

**Decision**: `workspace/providers/routing.yaml` selects `deepseek` as the default provider and reads `DEEPSEEK_API_KEY`. The `custom` provider stays available for future OpenAI-compatible endpoints.

**Consequences**:
- (+) One env var, no base_url in config, no shape-adjust code.
- (–) None material.

---

## ADR-008 — Drop the Python Slack bridge; use Anvio's native Slack channel

**Status**: Accepted. Supersedes ADR-004.

**Context**: ADR-004 kept `services/slack-playwright/` as a Phase 4 deliverable with the intent to retire it later. Reviewing the actual value: the bridge was Playwright-driven UI automation of Slack Web, a stopgap that only existed because Hermes had no first-party Slack transport. Anvio ships a native Slack channel adapter (Socket Mode) that covers `sendMessage`, thread mapping, and Block Kit approvals with fewer moving parts and no browser-in-a-loop.

**Decision**: Remove `services/slack-playwright/` entirely. Enable `spec.channels.slack: enabled: true` in `workspace/anvio.yaml` and configure via `SLACK_BOT_TOKEN` + `SLACK_APP_TOKEN`.

**Consequences**:
- (+) One transport, no Playwright/Chromium dependency, no browser session cache to babysit.
- (+) Native Block Kit approvals map cleanly onto the Soul Gate's approver flow.
- (+) Removes ~15 Python files and their tests, virtualenv, and Playwright install target from the repo surface.
- (–) The custom `/codereview`, `/code-task`, `/summary` slash commands the Python router implemented need to be re-expressed. Options: (a) a lightweight command-router skill invoked by the Slack channel default agent, (b) proper Slack slash-command registrations. Deferred as a follow-up — the underlying skills (`/cursor-code-review`, `/cursor-coding`) are already reachable by mentioning the corresponding agent in Slack.
