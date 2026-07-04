---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: changelog-generation
  version: "1.0.0"
  catalog: team
spec:
  name: Changelog Generation
  description: Generate release changelogs from git history and PR labels
  category: documentation
  tags: 
    - documentation
    - release
  permissions: 
    - read:documentation
    - read:codebase
  toolRequirements: []
  contextRequirements: 
    - project_context
---

# Changelog Generation

## Format
Keep a Changelog: Added, Changed, Fixed, Removed, Security

## Rules
- User-facing impact first
- Link PRs/issues
- Semver alignment
