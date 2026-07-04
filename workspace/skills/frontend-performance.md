---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: frontend-performance
  version: "1.0.0"
  catalog: team
spec:
  name: Frontend Performance
  description: Frontend performance — Core Web Vitals, bundle budgets, lazy loading
  category: frontend
  tags: 
    - frontend
    - performance
  permissions: 
    - read:documentation
    - read:codebase
  toolRequirements: []
  contextRequirements: 
    - project_context
---

# Frontend Performance

## Core Web Vitals
- LCP, INP, CLS targets
- Bundle analysis and tree shaking
- Image lazy load, font subset
- Memoization only when measured

## Measure
Lighthouse, Web Vitals RUM
