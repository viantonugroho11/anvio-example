---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: test-design
  version: "1.0.0"
  catalog: team
spec:
  name: Test Design
  description: Test-case design — equivalence classes, boundary values, decision tables
  category: qa
  routing: planning
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

# Test Design

## Process
1. Map acceptance criteria to cases
2. Happy path, edge, negative, security
3. Prioritize by risk

## Output
Test plan matrix: requirement to test type to status
