---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: reliability-engineering
  version: "1.0.0"
  catalog: team
spec:
  name: Reliability Engineering
  description: SRE reliability engineering — SLIs, SLOs, error budgets, toil reduction
  category: architecture
  tags: 
    - sre
    - reliability
  permissions: 
    - read:documentation
    - read:codebase
  toolRequirements: []
  contextRequirements: 
    - project_context
---

# Reliability Engineering

## Practices
- SLOs, error budgets, SLIs
- Graceful degradation
- Health checks, readiness, liveness
- Runbooks and incident response
- Chaos testing for critical paths

## Output
Reliability targets, monitoring plan, failure scenarios
