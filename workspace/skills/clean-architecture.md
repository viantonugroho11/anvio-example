---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: clean-architecture
  version: "1.0.0"
  catalog: team
spec:
  name: Clean Architecture
  description: Clean Architecture layering — dependencies point inward
  category: architecture
  routing: planning
  tags: 
    - architecture
    - clean-architecture
    - ddd
  permissions: 
    - read:documentation
    - read:codebase
  toolRequirements: []
  contextRequirements: 
    - project_context
    - requirements
---

# Clean Architecture

## Layers (outer→inner)
- Frameworks/Drivers: Web, DB, external services
- Interface Adapters: Controllers, presenters, gateways
- Application: Use cases, DTOs
- Domain (core, zero deps): Entities, value objects, repository interfaces

## Rules
- Dependencies point inward only
- Domain has zero external imports
- Use cases reference domain interfaces, not concrete impls
- Changing infra requires zero domain changes
- Each layer independently testable
- Wire deps via DI
