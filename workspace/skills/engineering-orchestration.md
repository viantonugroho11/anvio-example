---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: engineering-orchestration
  version: "1.0.0"
  catalog: team
spec:
  name: Engineering Orchestration
  description: Multi-step PLAN → REVIEW workflow for coordinating specialist agents
  category: planning
  tags: 
    - orchestration
    - planning
    - delegation
  permissions: 
    - read:documentation
    - read:codebase
  toolRequirements: []
  contextRequirements: 
    - project_context
---

# Engineering Orchestration

## When to use

Multi-step features, cross-role work, or tasks without a single `@mention`.

## Workflow

PLAN → EXECUTE → VERIFY → REVIEW (if code/arch) → FINALIZE

1. **Plan** — acceptance criteria, dependencies, risks (`@tech-lead` or self)
2. **Execute** — `delegate_task` to `@architect`, `@backend`, `@frontend`, etc.
   - **Coding:** `@backend` / `@frontend` use `/cursor-coding` → Cursor Agent (not direct edits)
   - **Review:** `@reviewer` uses `/cursor-code-review` → Cursor Agent
3. **Verify** — tests, requirements met
4. **Review** — `@reviewer` gate for production-impacting changes
5. **Finalize** — docs, ADR if needed, `make memory-index` after new ADRs

## Delegation

- Parallel: independent backend + frontend after design
- Sequential: architect → implement → qa → reviewer → documenter
- Read-only research first: `@researcher` before `@architect` on unknown domains

## Output

- Task graph with owners
- Explicit blockers and assumptions
- Verdict before close: reviewer status if code changed
