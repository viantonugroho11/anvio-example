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

---

## ADR-009 — Run agents on Claude Code runtime OAuth, not a metered API key

**Status**: Accepted. Amends ADR-007.

**Context**: ADR-007 chose DeepSeek as the model provider for the `local` runtime, billed per token. Anvio also supports **vendor runtimes** (`claude-code`, `cursor`, `codex`, `antigravity`) authenticated by the vendor's own OAuth against an existing subscription (Claude Pro/Max), documented in Anvio's [Runtime OAuth](https://anvio-docs.vercel.app/docs/security/runtime-oauth) page. A Claude Pro/Max subscription is already held, so subscription quota is cheaper and higher-quality than DeepSeek-per-token for this workload.

**Decision**:
- `spec.runtime.default: claude-code` in `workspace/anvio.yaml`, `fallbacks: [local]`.
- Every agent under `workspace/agents/*.yaml` declares `spec.runtime.provider: claude-code`. `backend`, `frontend`, and `reviewer` chain `fallbacks: [cursor, local]` (they already delegate code work to Cursor); the rest use `[local]`.
- Onboard with `anvio setup-token --claude`, which wraps the official `claude setup-token`. The resulting token is encrypted by the connection broker under `workspace/connections/` (`service: claude-code`). Headless/CI uses `CLAUDE_CODE_OAUTH_TOKEN`.
- `providers/routing.yaml` (DeepSeek) is now **only** consulted on the `local` fallback hop.

**Consequences**:
- (+) Billed against subscription quota instead of per-token API credits.
- (+) Full Claude Agent SDK tool loop; failover chain still degrades to Cursor/DeepSeek on auth failure.
- (–) **`ANTHROPIC_API_KEY` must not be set in the same environment** — an API key shadows OAuth and silently bills API credits. It is commented out in `.env.example` for this reason.
- (–) OAuth expects a browser; containers/headless hosts must inject `CLAUDE_CODE_OAUTH_TOKEN` or mount a pre-seeded `workspace/connections/`.
- (–) Non-auth errors fail immediately (no failover), per Anvio's fallback semantics.

---

## ADR-010 — Telegram as a first-class channel alongside Slack

**Status**: Accepted.

**Context**: Hermes drove Telegram through per-profile bot tokens (`TELEGRAM_BOT_FE`, `TELEGRAM_BOT_BE`, …). Anvio's `TelegramChannel` adapter is long-polling over the Bot API — one bot, thread→session mapping, inline Approve/Reject buttons for tool approvals.

**Decision**: Enable `spec.channels.telegram` in `workspace/anvio.yaml` with `defaultAgent: tech-lead` (matching Slack and the planner entry point). One bot token via `TELEGRAM_BOT_TOKEN`. Routing to a non-default role is done by mentioning the agent, not by running a second bot.

**Consequences**:
- (+) No webhook, no public URL, no reverse proxy — works local-first.
- (+) Approvals reuse the same Soul Gate flow as Slack Block Kit buttons.
- (+) Collapses Hermes's multi-bot-token scheme to a single credential.
- (–) The adapter has no user allowlist — restrict by keeping the bot out of public groups, or add an approval gate in the soul. `TELEGRAM_ALLOWED_USERS` from Hermes has no Anvio equivalent.
- (–) A single bot means per-role bots (`TELEGRAM_BOT_FE/BE`) are dropped; role selection is now a mention inside the chat.


---

## ADR-011 — Agent `spec.model` must name a Claude model under the `claude-code` runtime

**Status**: Accepted. Constrains ADR-009.

**Context**: `ClaudeCodeRuntime.buildQueryOptions()` passes `request.agent.spec.model.model` verbatim to the Claude Agent SDK. Agents were first migrated with `provider: deepseek / model: deepseek-chat` (the fallback provider), which made every run fail with *"There's an issue with the selected model (deepseek-chat). It may not exist or you may not have access to it."*

**Decision**: All 9 agents set `spec.model` to `provider: anthropic`, `model: sonnet`. Upstream: [Anvio#49](https://github.com/viantonugroho11/Anvio/issues/49). The alias survives model-id rotations; the Agent SDK resolves it against the subscription.

**Consequences**:
- (+) Runs succeed on subscription OAuth — verified with a `PONG` round-trip through `anvio run tech-lead`.
- (–) `spec.model` now serves two masters: it is the Claude Code model *and* the `local` fallback's model config. A `local` fallback would need `ANTHROPIC_API_KEY`, which ADR-009 forbids — so the `local` hop is effectively inert. Accepted: `claude-code` is the intended path, and `cursor` covers the delegation cases.
- (–) `providers/routing.yaml` is now documentation of intent rather than an active code path.

---

## ADR-012 — Disable MCP servers whose config cannot resolve

**Status**: Accepted.

**Context**: Anvio does **not** expand `${VAR}` in `workspace/mcp/servers.yaml` — placeholders reach the child process as literal strings. Every platform boot therefore spawned four servers that crashed instantly: `atlassian` (missing `jsdom` in the published npx build), `bitbucket` and `bitbucket-order-tyche` (`BITBUCKET_EMAIL environment variable is required`), and `hermes-memory` (`ERR_INVALID_URL input: '${MEMORY_DATABASE_URL}'`). The `filesystem` server pointed at the container path `/workspace`, absent on the host.

**Decision**: Set `enabled: false` on the four broken servers with the reason inline; repoint `filesystem` at `.`. Only `filesystem` and `github` boot by default. Upstream: [Anvio#47](https://github.com/viantonugroho11/Anvio/issues/47).

**Consequences**:
- (+) Gateway boots clean — zero errors in the log, and startup is measurably faster.
- (+) The failure reason is recorded next to each flag instead of being rediscovered from stack traces.
- (–) Bitbucket/Jira/pgvector tools are unavailable until real credentials are inlined or Anvio grows env interpolation. Re-enabling is a one-line flip plus real values.


---

## ADR-013 — Operating rule: the gateway is the only process allowed to poll a channel

**Status**: Accepted. Still valid — the underlying bug is [Anvio#48](https://github.com/viantonugroho11/Anvio/issues/48) (still open in v2.0.2).

**Context**: Telegram was configured, `anvio channels status` reported `healthy`, the gateway logged `[Telegram] Bot polling started` — and the bot still never replied. Cause: two `anvio run` processes from an earlier smoke test were still alive. `createPlatform()` starts channel adapters for *every* entrypoint, including one-shot CLI runs, and does not stop them when the command finishes. Those stragglers won some `getUpdates` races, consumed the updates, and had nowhere to route them.

**Decision**: Treat `anvio gateway start --foreground` as the single owner of inbound channels. Do not run `anvio run` / `anvio chat` against this workspace while the gateway is up; if replies stop, check `ps aux | grep apps/cli/dist/main.js` for leftovers before debugging anything else. Filed upstream as [Anvio#48](https://github.com/viantonugroho11/Anvio/issues/48).

**Consequences**:
- (+) Deterministic: one poller, one owner of the update offset.
- (–) One-shot CLI testing and a live gateway are mutually exclusive until #48 lands. Use the REST/web-chat surface on `:3001` to exercise an agent while the gateway runs.
- (–) The health probe cannot detect this class of failure — it only validates the token, so `healthy` is not evidence that messages are being routed.


---

## ADR-014 — Harness disabled for single-operator workspace

**Status**: Superseded by ADR-015 (v2.0.2 upstream fixes). Kept for the migration record.

**Context**: With the built-in `HarnessDefaults.enabled: true` and `soulSlug: architect-soul`, `HarnessGateway.handleInbound()` calls `canAccessRestrictedZone()` on every inbound. Telegram DMs hit the branch `!isDm && trustTier === 'restricted'` because (a) `TelegramChannel` never sets `metadata.isDm`, and (b) a chat's threadId is never in `soul.trustedZones`/`allowedZones`. The gate then demands `isManagerUser`, which fails for a user not in the soul's approver list — and drops the message with `reason: 'restricted_zone'`, no log line, no reply. Filed upstream as [Anvio#52](https://github.com/viantonugroho11/Anvio/issues/52).

**Decision**: `workspace/harness/defaults.yaml` with `enabled: false`. Also switched `soulSlug` to `tech-lead-soul` (workspace default) so if we re-enable later the correct soul is loaded. Soul Gate approvals per-tool still fire — this only disables the pre-runtime channel gate.

**Consequences**:
- (+) Round-trip through Telegram works: verified `user: "haiii" → assistant reply`, persisted in `state.db`.
- (+) One operator, one Telegram token — the harness's group/mention/manager machinery has nothing to gate.
- (–) Multi-tenant / group-chat use cases now bypass the harness. Not applicable here; when it is, `enabled: true` plus a real `soul` with `trustedZones` + `manager` is the right shape.
- (–) Soul-level approvers for destructive tools still work because Soul Gate is a separate layer, but the pre-runtime channel filter is gone.


---

## ADR-015 — Upgrade to Anvio v2.0.2 and revert Telegram workarounds

**Status**: Accepted. Supersedes ADR-014; refines the workspace for the fixed upstream.

**Context**: Anvio v2.0.2 ("Telegram bug sweep", released 2026-08-31) shipped code + tests for every Telegram-path issue we filed during this migration:

| Upstream | Symptom in v2.0.0/2.0.1 | Workaround we needed |
|---|---|---|
| [#51](https://github.com/viantonugroho11/Anvio/issues/51) | Default profile `engageOn: mention` + adapter never set `mentionedBot` — every DM disengaged | `workspace/harness/channel-profiles.yaml` forcing `engageOn: always` on Telegram |
| [#52](https://github.com/viantonugroho11/Anvio/issues/52) | `canAccessRestrictedZone` drop; adapter never set `isDm`; gate emitted no log | `workspace/harness/defaults.yaml` with `enabled: false` |
| [#53](https://github.com/viantonugroho11/Anvio/issues/53) | Adapter never called `setMyCommands` and had no slash-command router | manual `POST /setMyCommands` via Bot API; no dispatcher |
| [#54](https://github.com/viantonugroho11/Anvio/issues/54) | "Task Completed" spam bubble on chat channels; SDK swallowed `/`-prefixed prompts | avoid `/`-commands; live with the spam |

The four fixes together mean the workspace no longer needs any of the workarounds we authored to make the bot respond at all.

**Decision**:
- Delete `workspace/harness/channel-profiles.yaml` — the shipped Anvio default is now `engageOn: always` for `telegram`, which is what we wanted.
- Rewrite `workspace/harness/defaults.yaml` with `enabled: true` and `soulSlug: tech-lead-soul` (the workspace default, replacing the built-in `architect-soul`). The gate now works correctly for private chats via `metadata.isDm`, so we get the Soul-Gate approver flow back for destructive tool calls.
- Anvio's own `install.sh` fetches `main`, and this workspace expects `v2.0.2+`. Any older release will silently drop Telegram DMs.

**Consequences**:
- (+) Slash-command menu, per-tool approvals, DM routing, "/help"/"/agents"/"/skills" dispatch — all work out-of-the-box with the shipped adapter.
- (+) One less workspace file to maintain (`channel-profiles.yaml`), one file simpler (`defaults.yaml`).
- (–) The workspace now has a **hard version floor of v2.0.2**. Downgrading Anvio without also re-adding the two workaround files reproduces the silent-drop failures.
- (–) ADR-013's operating rule ("gateway is the only process allowed to poll a channel") still stands — [Anvio#48](https://github.com/viantonugroho11/Anvio/issues/48) is not part of the v2.0.2 sweep. Running `anvio run` or `anvio chat` against this workspace while the gateway is up will still leak a background poller.

---

## ADR-016 — Enable A2A protocol (v2.4.0)

**Status**: Accepted.

**Context**: Anvio v2.4.0 ships `packages/a2a` — a full A2A v1.0 implementation (ADR-0026). A2A (Agent-to-Agent) is Google's open protocol for cross-platform agent interoperability: agents expose Agent Cards for discovery, exchange Messages via Tasks, and stream results over SSE. The package provides both server (expose Anvio agents to external A2A clients) and client (delegate to external A2A agents via `A2ATool`).

The gateway routes `/a2a/*` and `/.well-known/agent.json` when `platform.a2aServer` is present. Agent Cards are auto-generated from `agents/*.yaml` frontmatter.

**Decision**:
- Add `spec.a2a.enabled: true` to `workspace/anvio.yaml`.
- Once upstream wires `createPlatform` to read this config key and instantiate `A2AServer`, the gateway will automatically serve Agent Card discovery and accept A2A JSON-RPC + REST requests.
- External A2A agents can be added as tools by registering `A2ATool` instances in the workspace tool config.

**Consequences**:
- (+) Every agent in `workspace/agents/` becomes discoverable via `/.well-known/agent.json` — enables cross-platform orchestration (CrewAI, AutoGen, LangGraph, etc.).
- (+) `A2ATool` wraps external A2A agents as native Anvio tools — delegation without custom integration code.
- (+) SSE streaming + push notifications for long-running inter-agent tasks.
- (–) Config key `spec.a2a.enabled` is forward-looking — `createPlatform` doesn't read it yet in v2.4.0; the gateway routes exist but the boot wiring is manual (programmatic `platform.a2aServer = ...`). This ADR documents the intent; full auto-wiring expected in a future release.
- (–) Version floor raised to **v2.5.0** for A2A features (v2.5.0 migrates to official `@a2a-js/sdk` v1.1.0 with protobuf types and SDK transport handlers).
