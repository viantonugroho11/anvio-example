---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: performance-testing
  version: "1.0.0"
  catalog: team
spec:
  name: Performance Testing
  description: Load, stress, and soak testing methodology
  category: qa
  routing: qa
  tags: 
    - qa
    - performance
  permissions: 
    - read:documentation
    - read:codebase
    - write:codebase
  toolRequirements: []
  contextRequirements: 
    - project_context
    - acceptance_criteria
---

# Performance Testing

## Types
- Load: expected traffic
- Stress: find breaking point
- Soak: memory/leak detection

## Output
SLO validation, bottlenecks, recommendations
