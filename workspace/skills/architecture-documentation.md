---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: architecture-documentation
  version: "1.0.0"
  catalog: team
spec:
  name: Architecture Documentation
  description: Document system architecture — components, flows, boundaries
  category: architecture
  routing: planning
  tags: 
    - documentation
    - architecture
  permissions: 
    - read:documentation
    - read:codebase
  toolRequirements: []
  contextRequirements: 
    - project_context
    - requirements
---

# Architecture Documentation

## Include
- Context diagram, containers, components
- Data flows and trust boundaries
- ADR index
- Operational view (deploy, monitor)
