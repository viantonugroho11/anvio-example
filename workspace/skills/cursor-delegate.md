---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: cursor-delegate
  version: "1.0.0"
  catalog: team
spec:
  name: Cursor Delegate
  description: General-purpose delegation from Hermes profiles to Cursor Agent
  category: delegation
  routing: coding
  tags: 
    - cursor
    - delegation
    - orchestration
  permissions: 
    - read:documentation
    - read:codebase
    - call:external_agent
  toolRequirements: 
    - cursor-cli
    - @cursor/sdk
  contextRequirements: 
    - project_context
    - acceptance_criteria
---

# Cursor Delegation (Hermes → Cursor)

Hermes **orchestrates**; Cursor Agent **executes** code review and coding tasks.

## When to use

- User asks for code review or implementation via Telegram/Hermes
- Task needs IDE-grade file access, multi-file edits, or deep diff review
- Hermes profile should **not** write production code directly — delegate instead

## Prerequisites

| Variable | Required | Notes |
|----------|----------|-------|
| `CURSOR_API_KEY` | Yes | User or team key from [Cursor Cloud Agents](https://cursor.com/dashboard/cloud-agents) |
| `CURSOR_DELEGATE_SCRIPT` | No | Default: `scripts/cursor-delegate/delegate.mjs` |
| Repo checkout | Local mode | `--cwd` must point to cloned repo |
| `REPO_URL` | Cloud mode | GitHub URL; Cursor clones and optionally opens PR |

Setup once:

```bash
make cursor-delegate-setup
```

## Runtime selection

| Scenario | Runtime | Flags |
|----------|---------|-------|
| Repo already on disk (VPS, dev machine) | **local** | `--cwd /path/to/repo` |
| Remote repo, open PR, overnight job | **cloud** | `--repo-url https://github.com/org/repo --ref feature/x` |
| Bitbucket-only repo | **local** | Clone locally first; cloud requires GitHub |

## Bitbucket private repo (local-first)

Cursor Cloud **tidak** clone Bitbucket. Untuk repo private Bitbucket, selalu pakai **local mode** + Hermes Bitbucket MCP.

### Arsitektur

```
Telegram → Hermes (orchestrator)
              ├─ Bitbucket MCP → baca/tulis PR, diff, komentar
              ├─ git (SSH)     → clone, fetch, checkout, push
              └─ Cursor local  → review/coding di --cwd /workspace/{repo}
```

| Komponen | Peran |
|----------|-------|
| Hermes | Scope task, sync branch, jalankan `delegate.mjs`, post ke PR |
| Cursor (local) | Review diff & edit file di disk |
| Bitbucket MCP | `get_pr_details`, `add_pr_comment`, `list_pipelines` |
| git + SSH | Clone/push repo private |

### Env & mount (Docker)

Set di `docker/.env`:

```bash
WORKSPACE_HOST_PATH=../projects      # host: folder clone repo
WORKSPACE_PATH=/workspace            # path di dalam container
SSH_HOST_PATH=/Users/you/.ssh        # SSH key untuk git@bitbucket.org
BITBUCKET_WORKSPACE=your-workspace
BITBUCKET_URL=https://bitbucket.org/your-workspace/repo1
```

Image `hermes-engineering:latest` includes **Cursor CLI** (`agent`, `cursor-agent` in PATH). Rebuild: `make docker-build`.

Container `hermes-backend`, `hermes-frontend`, `hermes-reviewer` mount:

- `${WORKSPACE_HOST_PATH}` → `/workspace`
- `${SSH_HOST_PATH}` → `/mnt/host-ssh` (read-only), copied to `/opt/data/.ssh` at startup
- `scripts/cursor-delegate` → `/opt/cursor-delegate`

Path repo untuk `--cwd`: `${WORKSPACE_PATH}/{repo-name}` → contoh `/workspace/order-tyche`.

### Setup sekali

```bash
# 1. Siapkan folder workspace
make workspace-init

# 2. Clone repo private — di dalam container:
docker compose -f docker/docker-compose.yaml exec hermes-backend \
  sh /opt/hermes/bitbucket-clone.sh order-tyche

# 3. Verifikasi
docker compose -f docker/docker-compose.yaml exec hermes-backend \
  ls -la /workspace/order-tyche
```

Di host: `make workspace-clone REPO=order-tyche`

**Jangan** `git clone https://user:token@bitbucket.org/...` — Hermes security scanner memblokir URL dengan kredensial. Pakai `/bitbucket-cli` → `sh /opt/hermes/bitbucket-clone.sh <repo>`.

### Review PR Bitbucket (end-to-end)

1. **MCP** `get_pr_details` → branch source, files, deskripsi
2. **git** di `/workspace/{repo}`:
   ```bash
   git fetch origin
   git checkout feature/branch-from-pr
   ```
3. **Cursor** (Hermes jalankan, jangan review sendiri):
   ```bash
   node ${CURSOR_DELEGATE_SCRIPT} review \
     --prompt "Review PR #42: branch feature/login vs main. Focus: auth, errors. ..." \
     --cwd ${WORKSPACE_PATH}/order-tyche
   ```
4. **MCP** `add_pr_comment` / `add_pr_inline_comment` dengan isi field `result` dari JSON Cursor
5. Balas ringkasan ke Telegram

### Implementasi + PR Bitbucket

1. Checkout branch feature: `git checkout -b feature/xyz`
2. **Cursor code** dengan `--cwd ${WORKSPACE_PATH}/{repo}`
3. `git commit && git push origin feature/xyz`
4. Buat/update PR via `/bitbucket-pr-workflow` atau MCP
5. Gate: `/cursor-code-review` sebelum merge

### Batasan

- Jangan pakai `--repo-url` untuk Bitbucket (cloud = GitHub only)
- Repo harus sudah ada di `/workspace` sebelum delegate
- Uncommitted changes hanya terlihat Cursor jika file ada di `--cwd`
- Push butuh SSH key valid di container

## Invoke (terminal)

```bash
# Code review (local)
node scripts/cursor-delegate/delegate.mjs review \
  --prompt "Review PR #42: focus on auth and error handling" \
  --cwd /workspace/my-repo

# Implementation (local)
node scripts/cursor-delegate/delegate.mjs code \
  --prompt "Add POST /api/v1/users with validation and tests" \
  --cwd /workspace/my-repo

# Cloud coding with PR
node scripts/cursor-delegate/delegate.mjs code \
  --prompt "Implement login feature per acceptance criteria" \
  --repo-url https://github.com/org/repo \
  --ref main \
  --auto-pr
```

Output is JSON (`status`, `agentId`, `runId`, `result`). Parse `result` for the human-facing summary.

## Hermes orchestration pattern

1. **Clarify** — acceptance criteria, repo path, branch/PR scope
2. **Prepare** — ensure repo cloned, `CURSOR_API_KEY` set, `make cursor-delegate-setup` done
3. **Delegate** — run `delegate.mjs` via terminal (do not implement review/code yourself)
4. **Summarize** — relay Cursor output to user; note `agentId` for resume/follow-up
5. **Gate** — for production merges, still route through `@reviewer` workflow

## Follow-up / resume

Store `agentId` from JSON output. For multi-turn work, use Cursor SDK `Agent.resume(agentId, ...)` or send a new prompt with full context.

## Failure handling

| Exit code | Meaning | Action |
|-----------|---------|--------|
| 0 | Success | Deliver `result` to user |
| 1 | Startup/auth failure | Check `CURSOR_API_KEY`, repo access |
| 2 | Run failed mid-task | Inspect transcript; retry with narrower prompt |
| 75 | Transient error | Retry once |

## Related skills

- `/cursor-code-review` — structured review via Cursor
- `/cursor-coding` — feature/fix implementation via Cursor
