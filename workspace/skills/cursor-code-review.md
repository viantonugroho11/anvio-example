---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: cursor-code-review
  version: "1.0.0"
  catalog: team
spec:
  name: Cursor Code Review
  description: Delegate code review execution to Cursor Agent
  category: delegation
  routing: coding
  tags: 
    - code-review
    - cursor
    - delegation
    - quality
  permissions: 
    - read:documentation
    - read:codebase
    - call:external_agent
  toolRequirements: 
    - cursor-cli
    - @cursor/sdk
  contextRequirements: 
    - project_context
    - changeset
    - acceptance_criteria
---

# Cursor Code Review

Hermes **plans and routes** the review; **Cursor Agent executes** the actual diff analysis.

## Trigger

- `@reviewer review this PR`
- User pastes diff or PR link via Telegram
- Planner `code-review` workflow with Cursor execution

## Hermes role (orchestrator only)

Do **not** perform line-by-line review yourself. Your job:

1. Gather context (PR link, branch, files, acceptance criteria)
2. Build a precise review prompt for Cursor
3. Run delegation script
4. Format and deliver Cursor's verdict to the user

## Steps

### 1. Scope the review

Collect:

- Repo path (`--cwd`) or GitHub URL (`--repo-url`)
- Branch/ref or PR number
- Focus areas (security, performance, API contract, etc.)
- Review depth: quick scan vs full gate

### 2. Build Cursor prompt

Include in `--prompt`:

```
Review scope: [PR #N | branch X vs main | files: ...]
Focus: [security, correctness, tests, conventions]
Context: [ticket, acceptance criteria, known risks]
Output format:
  ## Review Overview
  ## Critical / Warnings / Suggestions
  ## Verdict: APPROVE | CHANGES_REQUESTED | REJECT
```

Load `/repo-conventions` and `/repo-standards` facts into the prompt when available.

### 3. Delegate to Cursor

```bash
# Local (repo on disk)
node ${CURSOR_DELEGATE_SCRIPT:-scripts/cursor-delegate/delegate.mjs} review \
  --prompt "<built prompt>" \
  --cwd "${REPO_PATH}"
```

For GitHub PR on remote branch (cloud):

```bash
node ${CURSOR_DELEGATE_SCRIPT:-scripts/cursor-delegate/delegate.mjs} review \
  --prompt "<built prompt>" \
  --repo-url "${REPO_URL}" \
  --ref "${HEAD_REF}"
```

### Bitbucket private PR (local — wajib)

Cloud tidak mendukung Bitbucket. **Satu perintah** — jangan improvisasi `curl`, `curl | python3`, atau URL dengan kredensial (security scanner memblokir).

User kirim URL PR Bitbucket → jalankan:

```bash
sh /opt/hermes/cursor-bitbucket-review.sh "https://bitbucket.org/Amartha/repo-name/pull-requests/1234"
```

Script ini: fetch metadata PR (node, bukan curl|pipe) → `bitbucket-clone.sh` (SSH) → checkout branch → `delegate.mjs review`.

### FORBIDDEN

```bash
# ❌ blocked — pipe ke interpreter
curl ... | python3 -m json.tool

# ❌ blocked — kredensial di URL
git clone https://user:token@bitbucket.org/...
```

SSH sudah tersedia di `/opt/data/.ssh` — jangan klaim "SSH key not available" tanpa cek `ssh -i /opt/data/.ssh/id_rsa -T git@bitbucket.org`. Jangan generate SSH key baru.

Lihat `/bitbucket-cli` dan `/cursor-delegate`.

### 4. Deliver results

Parse JSON `result` field. Post to:

- Telegram reply to user
- Bitbucket/GitHub PR comment via MCP (optional, if user requests)

Map Cursor verdict to platform gate:

| Cursor verdict | Platform gate |
|----------------|---------------|
| APPROVE | APPROVE |
| CHANGES_REQUESTED | CHANGES_REQUESTED |
| REJECT | REJECT |

### 5. Persist (optional)

If significant findings, note in `memory/episodes/` via finalize phase.

## Checklist (for prompt, not Hermes execution)

- Correctness, edge cases, error handling, concurrency
- Security: OWASP, auth, secrets, injection
- Performance: N+1, caching, allocations
- Maintainability: naming, function size, structure
- Testing: coverage for new logic
- Consistency with `/repo-conventions`

## Chat format (relay to user)

```
File: path | Line: N
[🔴 Critical | 🟡 Warning | 🔵 Suggestion]
Issue: ...
Suggestion: ...
```

## References

- Base delegation: `/cursor-delegate`
- Legacy checklist: `/code-review`
- Workflow: `workflows/cursor-code-review/workflow.md`
- Planner: `configs/planner.yaml` → `cursor-code-review`
