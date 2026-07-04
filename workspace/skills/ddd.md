---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: ddd
  version: "1.0.0"
  catalog: team
spec:
  name: Ddd
  description: Domain-Driven Design tactical and strategic patterns
  category: architecture
  tags: 
    - ddd
    - architecture
    - domain-modeling
  permissions: 
    - read:documentation
    - read:codebase
  toolRequirements: []
  contextRequirements: 
    - project_context
---

# Domain-Driven Design

## Building Blocks
- Entity: distinct identity, persists through changes
- Value Object: immutable, defined by attributes
- Aggregate: cluster with single root, one per transaction
- Repository: collection-like interface for aggregates
- Domain Service: stateless ops outside entities
- Domain Event: meaningful domain occurrence
- Specification: evaluable business rule

## Process
1. Explore domain with experts → Ubiquitous Language
2. Identify bounded contexts + relationships
3. Model aggregates, entities, value objects
4. Repository interfaces for aggregate persistence
5. Domain services for cross-aggregate ops
6. Event-source critical audit trails

## Tactical
- Keep aggregates small, modify one per transaction
- Domain events for cross-context communication
- Anti-corruption layers at context boundaries
- Enforce invariants on every state change
