---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: feature-development
  version: "1.0.0"
  catalog: team
spec:
  name: Feature Development
  description: End-to-end feature delivery process — design, implement, test, review
  category: planning
  tags: 
    - workflow
    - feature
    - delivery
  permissions: 
    - read:documentation
    - read:codebase
  toolRequirements: []
  contextRequirements: 
    - project_context
---

# Feature Development

## Trigger

New feature, user story, or enhancement spanning design + implementation.

## Participants

`@tech-lead` (plan) · `@architect` · `@backend` · `@frontend` · `@qa` · `@reviewer` · `@documenter`

## Steps

1. Clarify acceptance criteria and risks
2. Design + ADR if significant (`@architect`)
3. Implement backend/frontend in parallel after design — use `/cursor-coding` to delegate implementation to Cursor Agent
4. Tests alongside code (`@qa` validates)
5. `@reviewer` gate — delegate via `/cursor-code-review` before merge
6. Document API/user changes (`@documenter`)
7. Deploy via `@devops` after review + QA pass

## Quality gates

- Acceptance criteria met
- Reviewer APPROVE (no CRITICAL findings)
- Docs updated for public API changes

## References

Planner graph: `configs/planner.yaml` workflow `feature-development`
