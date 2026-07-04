---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: api-design
  version: "1.0.0"
  catalog: team
spec:
  name: Api Design
  description: REST / GraphQL / gRPC API design principles and conventions
  category: api
  routing: planning
  tags: 
    - api
    - rest
    - design
  permissions: 
    - read:documentation
    - read:codebase
  toolRequirements: []
  contextRequirements: 
    - project_context
---

# API Design

- Resources as nouns, plural: `GET /api/v1/users/:id`
- Consistent response: `{data, meta, errors}`
- Consistent error: `{error: {code, message, details, requestId}}`
- Paginate lists, support filter/sort/fields
- Version via URL prefix or header
- Document with OpenAPI 3.x
- Rate limit + auth enforced
- ETags for caching
