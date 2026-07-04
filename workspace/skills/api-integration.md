---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: api-integration
  version: "1.0.0"
  catalog: team
spec:
  name: Api Integration
  description: Integrating with third-party and internal APIs
  category: api
  tags: 
    - frontend
    - api
  permissions: 
    - read:documentation
    - read:codebase
  toolRequirements: []
  contextRequirements: 
    - project_context
---

# API Integration

## Patterns
- Typed clients from OpenAPI/codegen
- Error boundaries and retry UX
- Loading/skeleton states
- Optimistic updates with rollback

## Security
- No secrets in client; use BFF when needed
