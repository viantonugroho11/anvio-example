---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: helm-generator
  version: "1.0.0"
  catalog: team
spec:
  name: Helm Generator
  description: Helm chart generation and templating
  category: devops
  tags: 
    - helm
    - kubernetes
    - devops
  permissions: 
    - read:documentation
    - read:codebase
    - write:infrastructure
  toolRequirements: 
    - helm
  contextRequirements: 
    - project_context
---

# Helm Chart

## Structure
```
Chart.yaml, values.yaml, values/{env}.yaml
templates/{_helpers.tpl, deployment, service, ingress, configmap, secret, hpa, pdb, tests/}
```

## Flow
1. Chart.yaml metadata
2. values.yaml with all params
3. Templates with proper labels + selectors
4. `_helpers.tpl` for common labels
5. Env-specific values files
6. Resource limits, probes, HPA
7. Network policies + pod security context
8. Test: `helm lint` → `helm template` → `helm install --dry-run --debug`

## Rules
- `.Values.*` for all configurable values
- Sensible defaults in values.yaml
- `required` for mandatory values
- Liveness + readiness probes
- Pod disruption budgets
- Semantic version image tags
