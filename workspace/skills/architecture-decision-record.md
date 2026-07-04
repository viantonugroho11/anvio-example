---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: architecture-decision-record
  version: "1.0.0"
  catalog: team
spec:
  name: Architecture Decision Record
  description: Author Architecture Decision Records (ADRs) with context, decision, consequences
  category: architecture
  routing: planning
  tags: 
    - adr
    - documentation
  permissions: 
    - read:documentation
    - read:codebase
  toolRequirements: []
  contextRequirements: 
    - project_context
    - requirements
---

# Architecture Decision Record

## Template
```
# ADR-NNN: Title
## Status
## Context
## Decision
## Consequences
## Alternatives Considered
```

Store in `memory/decisions/`.
