---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: architecture-review
  version: "1.0.0"
  catalog: team
spec:
  name: Architecture Review
  description: Structured architecture review with NFR alignment and risk analysis
  category: architecture
  routing: planning
  tags: 
    - architecture
    - review
  permissions: 
    - read:documentation
    - read:codebase
    - call:external_agent
  toolRequirements: []
  contextRequirements: 
    - project_context
    - changeset
    - requirements
---

# Architecture Review

## Checklist
- Bounded contexts and coupling
- Data consistency model
- Failure modes and recovery
- Security boundaries
- Observability and operability
- Cost and scalability headroom

## Output
Findings by severity + recommended actions
