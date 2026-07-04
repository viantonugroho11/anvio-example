---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: bitbucket-pr-workflow
  version: "1.0.0"
  catalog: team
spec:
  name: Bitbucket Pr Workflow
  description: Bitbucket pull-request workflow — create, review, merge, cleanup
  category: devops
  tags: 
    - git
    - pr
    - bitbucket
    - github
  permissions: 
    - read:documentation
    - read:codebase
    - call:external_agent
  toolRequirements: 
    - mcp:bitbucket
  contextRequirements: 
    - project_context
---

# Pull Request Workflow

## Trigger

Feature branch ready for review; user asks to open/update PR.

## Preconditions

- CI green; tests included; diff scoped
- Branch from `main`: `feature/` or `fix/` prefix

## Steps

1. Push branch
2. Create PR via **MCP** (`bitbucket` / `bitbucket-order-tyche`) or terminal
3. Link ticket/acceptance criteria in description
4. Request `@reviewer`; address feedback
5. Squash merge after APPROVE; delete branch

## Bitbucket

See `/bitbucket-cli` for clone, SSH, and API curl patterns.

## Validation

- No force-push to `main`
- Reviewer gate before merge (platform rule)

## Failure handling

- CI fail: fix before PR
- Large diff: split PRs
