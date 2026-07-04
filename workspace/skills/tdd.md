---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: tdd
  version: "1.0.0"
  catalog: team
spec:
  name: Tdd
  description: Test-Driven Development discipline — red / green / refactor
  category: qa
  routing: qa
  tags: 
    - tdd
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

# TDD

## Cycle: Red → Green → Refactor
1. Write failing test
2. Minimal code to pass
3. Refactor (tests stay green)

## Structure: Arrange → Act → Assert
- One assertion per test where possible
- Meaningful test names
- Independent, repeatable tests
- Mocks for external deps

## Pyramid
- E2E (few), Integration (some), Unit (many)
- Test behavior, not implementation
- Test edge cases + error paths
- No testing private methods
