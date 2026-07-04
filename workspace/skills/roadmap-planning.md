---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: roadmap-planning
  version: "1.0.0"
  catalog: team
spec:
  name: Roadmap Planning
  description: Roadmap planning with milestones and dependency tracking
  category: planning
  routing: planning
  tags: 
    - planning
    - leadership
  permissions: 
    - read:documentation
    - read:codebase
  toolRequirements: []
  contextRequirements: 
    - project_context
    - requirements
---

# Roadmap Planning

## Steps
1. Align on outcomes and metrics
2. Inventory epics and dependencies
3. Sequence by value vs risk
4. Capacity-based milestones

## Output
Quarterly roadmap, critical path, defer list
