---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: cursor-coding
  version: "1.0.0"
  catalog: team
spec:
  name: Cursor Coding
  description: Delegate coding tasks to Cursor Agent with clear acceptance criteria
  category: delegation
  routing: coding
  tags: 
    - coding
    - cursor
    - delegation
    - implementation
  permissions: 
    - read:documentation
    - read:codebase
    - write:codebase
    - call:external_agent
  toolRequirements: 
    - cursor-cli
    - @cursor/sdk
  contextRequirements: 
    - project_context
    - acceptance_criteria
---

# Cursor Coding

Hermes **plans and coordinates**; **Cursor Agent writes and edits code**.

## Trigger

- `@backend implement ...` / `@frontend build ...`
- Feature story ready for implementation
- Bug fix with clear reproduction steps

## Hermes role (orchestrator only)

Do **not** write production code directly. Your job:

1. Clarify acceptance criteria and constraints
2. Confirm repo path and branch strategy
3. Compose implementation prompt for Cursor
4. Run delegation script
5. Verify outcome (tests, diff summary) and hand off to `@reviewer`

## Steps

### 1. Plan (lightweight)

Before delegating, confirm:

- [ ] Acceptance criteria explicit
- [ ] Repo cloned at `--cwd`
- [ ] Branch name (if not default)
- [ ] Files/modules likely touched
- [ ] Test expectations
- [ ] Out of scope items listed

For multi-step features, use `/engineering-orchestration` or `/feature-development` for the graph; delegate **implementation slices** to Cursor one at a time.

### 2. Build Cursor prompt

Template:

```
Task: [one clear outcome]
Acceptance criteria:
- ...
Constraints:
- Follow /repo-conventions
- No breaking API changes without ADR
- Include unit/integration tests
Files/context: [paths, related modules]
Do NOT: [commit, open PR] unless asked
```

### 3. Delegate to Cursor

Local (repo on disk):

```bash
node ${CURSOR_DELEGATE_SCRIPT:-scripts/cursor-delegate/delegate.mjs} code \
  --prompt "<built prompt>" \
  --cwd "${REPO_PATH}"
```

Cloud (GitHub, auto PR):

```bash
node ${CURSOR_DELEGATE_SCRIPT:-scripts/cursor-delegate/delegate.mjs} code \
  --prompt "<built prompt>" \
  --repo-url "${REPO_URL}" \
  --ref "${BRANCH}" \
  --auto-pr
```

### Bitbucket private (local — wajib)

1. Pastikan repo di `${WORKSPACE_PATH:-/workspace}/{repo}`:
   `sh /opt/hermes/bitbucket-clone.sh <repo>` (jangan clone HTTPS dengan token di URL)
2. Branch: `git checkout -b feature/xyz`
3. Delegate:
   ```bash
   node ${CURSOR_DELEGATE_SCRIPT:-scripts/cursor-delegate/delegate.mjs} code \
     --prompt "<built prompt>" \
     --cwd "${WORKSPACE_PATH:-/workspace}/{repo}"
   ```
4. `git push` + PR via `/bitbucket-pr-workflow` atau MCP Bitbucket

Lihat `/cursor-delegate` → **Bitbucket private repo**.

### 4. Verify

After Cursor returns:

1. Check `status === finished` in JSON output
2. Run tests locally if terminal available: `go test ./...`, `npm test`, etc.
3. Summarize changes for user (files touched, behavior)
4. Route to `@reviewer` via `/cursor-code-review` before merge

### 5. Iterate

If incomplete, resume with new prompt referencing prior `agentId` or include Cursor's last `result` as context.

## Branching strategy

| Situation | Approach |
|-----------|----------|
| Local dev | Cursor edits in `--cwd`; user commits |
| Cloud + PR | `--auto-pr` on feature branch |
| Hotfix | Narrow prompt; single concern per delegation |
| Bitbucket private | Local `--cwd` only; push + PR via MCP/git (no cloud) |

## Quality gates

- Acceptance criteria met (Hermes verifies via test output or Cursor summary)
- `@reviewer` gate before production merge (delegate review to `/cursor-code-review`)
- Docs updated if public API changed (`@documenter`)

## Failure handling

- Cursor run failed → narrow scope, retry with smaller prompt
- Tests fail → delegate fix: `"Fix failing tests: <output>"`
- Large diff → split into multiple Cursor delegations

## References

- Base delegation: `/cursor-delegate`
- Feature workflow: `/feature-development`
- Review gate: `/cursor-code-review`
- Workflow: `workflows/cursor-coding/workflow.md`
