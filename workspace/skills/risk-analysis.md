---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: risk-analysis
  version: "1.0.0"
  catalog: team
spec:
  name: Risk Analysis
  description: Risk register creation with likelihood × impact scoring
  category: planning
  tags: 
    - planning
    - leadership
  permissions: 
    - read:documentation
    - read:codebase
  toolRequirements: []
  contextRequirements: 
    - project_context
---

# Risk Analysis

## Matrix
Likelihood x Impact to priority

## Categories
Technical, security, schedule, dependency, operational

## Output
Risk register with mitigations and owners
