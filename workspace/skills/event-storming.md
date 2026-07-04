---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: event-storming
  version: "1.0.0"
  catalog: team
spec:
  name: Event Storming
  description: Event Storming for collaborative domain discovery
  category: architecture
  tags: 
    - ddd
    - events
  permissions: 
    - read:documentation
    - read:codebase
  toolRequirements: []
  contextRequirements: 
    - project_context
---

# Event Storming

## Steps
1. Domain events (past tense verbs)
2. Commands triggering events
3. Aggregates and policies
4. Read models and integrations
5. Hotspots and unknowns

## Output
Event map, bounded context candidates, integration points
