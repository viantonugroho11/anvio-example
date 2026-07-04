---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: technical-research
  version: "1.0.0"
  catalog: team
spec:
  name: Technical Research
  description: Technical research — primary sources, comparison, recommendation
  category: research
  tags: 
    - research
  permissions: 
    - read:documentation
    - read:codebase
  toolRequirements: []
  contextRequirements: 
    - project_context
---

# Technical Research

## Process
1. Define question and success criteria
2. Search official docs + reputable sources
3. Compare options with evidence
4. Summarize with citations

## Rules
- No implementation; evidence only
