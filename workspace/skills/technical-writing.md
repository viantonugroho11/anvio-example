---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: technical-writing
  version: "1.0.0"
  catalog: team
spec:
  name: Technical Writing
  description: Technical writing — audience, structure, clarity
  category: documentation
  tags: 
    - documentation
  permissions: 
    - read:documentation
    - read:codebase
  toolRequirements: []
  contextRequirements: 
    - project_context
---

# Technical Writing

## Style
- Active voice, present tense
- One idea per paragraph
- Examples before edge cases
- TOC for docs >3 sections

## Audience
Define beginner vs expert paths
