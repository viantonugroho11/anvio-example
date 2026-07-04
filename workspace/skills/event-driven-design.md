---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: event-driven-design
  version: "1.0.0"
  catalog: team
spec:
  name: Event Driven Design
  description: Event-driven architecture patterns and event choreography vs orchestration
  category: architecture
  routing: planning
  tags: 
    - event-driven
    - architecture
    - messaging
  permissions: 
    - read:documentation
    - read:codebase
  toolRequirements: []
  contextRequirements: 
    - project_context
---

# Event-Driven Design

## Concepts
- Event: past tense, e.g. `OrderPlaced`
- Command: request, e.g. `PlaceOrder`
- Event Store: immutable log
- Event Handler: triggers side effects
- Event Bus: routes events
- Saga: distributed tx with compensations

## Schema
`{id, type, version, timestamp, source, data, metadata: {correlationId, causationId}}`

## Patterns
- Event Sourcing: state from event stream
- CQRS: separate read/write models
- Saga: compensating actions
- Outbox: reliable publish via DB tx
- Dead Letter Queue: failed event handling

## Rules
- Events immutable once published
- Consumers idempotent
- Schema versioning strategy
- Eventual consistency acceptable to business
- Dead letter handling in place
