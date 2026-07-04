---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: krakend-generator
  version: "1.0.0"
  catalog: team
spec:
  name: Krakend Generator
  description: KrakenD API gateway configuration generation
  category: backend
  tags: 
    - krakend
    - api-gateway
    - devops
  permissions: 
    - read:documentation
    - read:codebase
    - write:infrastructure
  toolRequirements: 
    - krakend
  contextRequirements: 
    - project_context
---

# KrakenD API Gateway

## Flow
1. Identify backend services + endpoints
2. Define endpoints (method, path, backend mapping)
3. Configure middleware: rate-limit, auth, caching, CORS, circuit-breaker
4. Set timeouts per backend
5. Observability (OpenTelemetry, metrics)
6. Validate: `krakend check -c krakend.json --lint`

## Common Middleware
- `oauth2`: JWT + RBAC
- `rate-limit`: per-endpoint/user
- `qos`: circuit breaker + timeout
- `cors`: CORS headers
- `request-proxy`: request mutation
