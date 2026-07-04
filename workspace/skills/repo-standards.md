---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: repo-standards
  version: "1.0.0"
  catalog: team
spec:
  name: Repo Standards
  description: Repository standards — CI baseline, security scans, code owners
  category: operations
  tags: 
    - standards
    - quality
    - deployment
  permissions: 
    - read:documentation
    - read:codebase
  toolRequirements: []
  contextRequirements: 
    - project_context
---

# Repository Standards

## Layout

```
cmd/ internal/ pkg/ api/ configs/ deployments/ docs/ scripts/ test/ tools/
```

## Code

- Tests for production code; documented public APIs
- Errors handled; secrets in env/vault only; pinned dependencies

## Deployment

- Health checks, Prometheus metrics, JSON logs
- Rollback capability; IaC only; CI/CD for all changes

## Documentation

- README per service; OpenAPI for REST APIs
- ADRs for significant decisions; runbooks for ops
