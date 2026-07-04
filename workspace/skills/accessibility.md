---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: accessibility
  version: "1.0.0"
  catalog: team
spec:
  name: Accessibility
  description: WCAG-compliant accessibility patterns for web UIs
  category: frontend
  tags: 
    - frontend
    - a11y
  permissions: 
    - read:documentation
    - read:codebase
  toolRequirements: []
  contextRequirements: 
    - project_context
---

# Accessibility

## WCAG
- Semantic HTML, labels, focus order
- Keyboard navigation for all interactions
- Color contrast AA minimum
- ARIA only when semantics insufficient

## Test
axe, screen reader smoke, keyboard-only flows
