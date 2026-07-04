---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: integration-testing
  version: "1.0.0"
  catalog: team
spec:
  name: Integration Testing
  description: Integration testing patterns across API and data boundaries
  category: qa
  routing: qa
  tags: 
    - qa
    - testing
  permissions: 
    - read:documentation
    - read:codebase
    - write:codebase
  toolRequirements: []
  contextRequirements: 
    - project_context
    - acceptance_criteria
---

# Integration Testing

## Scope
- HTTP APIs against real/stub deps
- DB migrations and transactions
- Message consumers with test topics

## Rules
- Isolated test data; cleanup after
