---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: api-documentation
  version: "1.0.0"
  catalog: team
spec:
  name: Api Documentation
  description: Reference and guide documentation for APIs
  category: documentation
  tags: 
    - documentation
    - api
  permissions: 
    - read:documentation
    - read:codebase
  toolRequirements: []
  contextRequirements: 
    - project_context
---

# API Documentation

## Content
- Auth, base URL, versioning
- Endpoints: method, params, responses
- Error codes and examples
- Rate limits and pagination

## Sync
Generate from OpenAPI where possible
