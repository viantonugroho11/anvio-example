---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: project-estimation
  version: "1.0.0"
  catalog: team
spec:
  name: Project Estimation
  description: Project effort estimation with confidence intervals
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

# Project Estimation

## Techniques
- Break into tasks <2 days
- Three-point: optimistic/likely/pessimistic
- Explicit assumptions and unknowns

## Output
Estimate range, confidence, blockers
