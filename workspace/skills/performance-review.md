---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: performance-review
  version: "1.0.0"
  catalog: team
spec:
  name: Performance Review
  description: Review code and systems for performance issues
  category: review
  routing: planning
  tags: 
    - performance
    - review
  permissions: 
    - read:documentation
    - read:codebase
    - call:external_agent
  toolRequirements: []
  contextRequirements: 
    - project_context
    - changeset
---

# Performance Review

## Checklist
- N+1 queries, missing indexes
- Unbounded loops and allocations
- Cache strategy and TTL
- Pagination on list endpoints
- Connection pool sizing

## Output
Findings with estimated impact + fixes
