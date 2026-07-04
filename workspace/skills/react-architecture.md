---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: react-architecture
  version: "1.0.0"
  catalog: team
spec:
  name: React Architecture
  description: React application architecture — state, data fetching, boundaries
  category: architecture
  routing: planning
  tags: 
    - frontend
    - react
  permissions: 
    - read:documentation
    - read:codebase
    - write:codebase
  toolRequirements: []
  contextRequirements: 
    - project_context
    - requirements
---

# React Architecture

## Structure
- Feature folders or domain modules
- Container/presentational split when useful
- Co-locate tests and types

## Patterns
- Server state vs client state separation
- Composition over prop drilling
- Lazy routes and code splitting
