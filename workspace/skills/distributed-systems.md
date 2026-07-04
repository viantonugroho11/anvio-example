---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: distributed-systems
  version: "1.0.0"
  catalog: team
spec:
  name: Distributed Systems
  description: Distributed-systems patterns — consistency, availability, partition tolerance
  category: architecture
  tags: 
    - architecture
    - distributed
  permissions: 
    - read:documentation
    - read:codebase
  toolRequirements: []
  contextRequirements: 
    - project_context
---

# Distributed Systems

## Patterns
- Saga, outbox, idempotency keys
- CQRS where read/write diverge
- Partitioning and backpressure
- Circuit breaker, retry with jitter

## Rules
- Design for partial failure
- Prefer eventual consistency with clear UX
- Avoid distributed transactions without strong need
