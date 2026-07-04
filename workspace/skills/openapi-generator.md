---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: openapi-generator
  version: "1.0.0"
  catalog: team
spec:
  name: Openapi Generator
  description: Generate OpenAPI specs from code or hand-authored contracts
  category: api
  tags: 
    - openapi
    - api-documentation
  permissions: 
    - read:documentation
    - read:codebase
  toolRequirements: 
    - openapi-cli
  contextRequirements: 
    - project_context
---

# OpenAPI 3.x

## Flow
1. Metadata: title, version, servers
2. Reusable components: schemas, parameters, security
3. Paths with operations, request bodies, responses
4. Tags for logical grouping
5. Security requirements
6. Validate: `openapi-spec-validator` + `spectral`

## Rules
- `$ref` to reduce duplication
- Keep in sync with implementation
- Example values for all schemas
- Error responses for each endpoint
- All referenced schemas exist
