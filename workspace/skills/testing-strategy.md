---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: testing-strategy
  version: "1.0.0"
  catalog: team
spec:
  name: Testing Strategy
  description: Testing strategy across unit / integration / e2e / performance
  category: qa
  routing: qa
  tags: 
    - testing
    - quality
  permissions: 
    - read:documentation
    - read:codebase
    - write:codebase
  toolRequirements: []
  contextRequirements: 
    - project_context
    - acceptance_criteria
---

# Testing Strategy

## Pyramid
- Unit (many): fast, isolated
- Integration (some): DB, HTTP, messaging
- E2E (few): critical journeys

## Rules
- Test behavior and contracts
- Cover edge cases and error paths
- Automate regression in CI
