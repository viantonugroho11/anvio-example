---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: bitbucket-cli
  version: "1.0.0"
  catalog: team
spec:
  name: Bitbucket Cli
  description: Bitbucket CLI operations for local development
  category: devops
  tags: 
    - bitbucket
    - git
    - pr
    - cli
  permissions: 
    - read:documentation
    - read:codebase
  toolRequirements: 
    - mcp:bitbucket
  contextRequirements: 
    - project_context
---

# Bitbucket & GitHub CLI

## Credentials (Docker)

**Do not ask the user for Bitbucket credentials** if env is set. Check first:

```bash
env | rg '^BITBUCKET_|^ATLASSIAN_'
```

Vars from `docker/.env` (injected into profile `.env` at startup):
- `BITBUCKET_USERNAME` — Atlassian account email
- `BITBUCKET_APP_PASSWORD` — App Password **or** Atlassian API token (`ATATT...`)
- `BITBUCKET_WORKSPACE`, `BITBUCKET_REPOS`
- `BITBUCKET_URL`, `BITBUCKET_URL_2` … `BITBUCKET_URL_10` (one URL per private repo)

## SSH (Docker) — do NOT generate keys

Host keys are copied at startup to **`/opt/data/.ssh/`** (from `SSH_HOST_PATH` in `docker/.env`).

**Never** run `ssh-keygen` or ask the user to register a container-generated key unless `/opt/data/.ssh/` is empty.

Verify before clone:

```bash
ls /opt/data/.ssh/
ssh -i /opt/data/.ssh/id_rsa -T git@bitbucket.org   # expect: authenticated via ssh key
```

If verification fails, tell the user to set `SSH_HOST_PATH` in `docker/.env` to their host `~/.ssh` and recreate the container — do **not** try `/root/.ssh` (permission denied for user `hermes`).

## Clone private repo (Docker) — ONLY use this

### FORBIDDEN (blocked by Hermes security scanner)

Never run commands like these — they **fail approval** and leak credentials:

```bash
# ❌ NEVER — userinfo in URL triggers HIGH security block
git clone https://user:token@bitbucket.org/...
TOKEN=... git clone https://...
ssh-keygen -t rsa ...   # unless /opt/data/.ssh is empty AND user explicitly asks
```

### REQUIRED command

**Always** clone with the helper script — one argument, repo name only:

```bash
sh /opt/hermes/bitbucket-clone.sh go-corp-channeling-repayment
# → /workspace/go-corp-channeling-repayment
```

If `ssh -T` works, **do not** fall back to HTTPS.

Clone all from `BITBUCKET_REPOS`:

```bash
for r in $(echo "$BITBUCKET_REPOS" | tr ',' ' '); do
  sh /opt/hermes/bitbucket-clone.sh "$r"
done
```

Host: `make workspace-clone REPO=go-matchmaker`

## Bitbucket PR review (one command)

```bash
sh /opt/hermes/cursor-bitbucket-review.sh "https://bitbucket.org/Amartha/repo/pull-requests/123"
```

PR metadata via `node /opt/hermes/bitbucket-pr-info.mjs <url>` — **never** `curl | python3`.

Do **not** patch `/opt/hermes/bitbucket-clone.sh` (read-only mount). If clone fails, fix env/SSH — do not rewrite scripts.

## MCP (when enabled in config)

Use MCP servers `bitbucket` and `bitbucket-order-tyche` when available:
- `list_pull_requests`, `get_pr_details`, `add_pr_comment`, `list_pipelines`
- Maps `BITBUCKET_APP_PASSWORD` → `BITBUCKET_PASSWORD` in MCP config

## Git / SSH setup

- Host SSH mounted at `/mnt/host-ssh`, copied to `/opt/data/.ssh` at startup
- `HERMES_SSH_DIR=/opt/data/.ssh` in profile env
- `delegate.mjs` at `/opt/cursor-delegate/delegate.mjs` (`CURSOR_DELEGATE_SCRIPT`)

## Workflow (terminal fallback)

1. Branch from main: `git checkout -b feature/xyz`
2. Commit + push
3. Create PR via MCP or `/bitbucket-pr-workflow`
4. Respond to review comments
