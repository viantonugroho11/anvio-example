---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: design-system
  version: "1.0.0"
  catalog: team
spec:
  name: Design System
  description: Design-system creation and evolution
  category: frontend
  routing: planning
  tags: 
    - frontend
    - design
  permissions: 
    - read:documentation
    - read:codebase
  toolRequirements: []
  contextRequirements: 
    - project_context
---

# Design System

## Components
- Tokens: color, spacing, typography
- Primitives to composites to patterns
- Variants via consistent API

## Rules
- Document usage and accessibility
- Avoid one-off styles; extend tokens
