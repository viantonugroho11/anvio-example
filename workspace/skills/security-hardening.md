---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: security-hardening
  version: "1.0.0"
  catalog: team
spec:
  name: Security Hardening
  description: Security hardening for infrastructure and applications
  category: security
  tags: 
    - security
    - devops
  permissions: 
    - read:documentation
    - read:codebase
  toolRequirements: []
  contextRequirements: 
    - project_context
---

# Security Hardening

## Checklist
- Least privilege IAM/RBAC
- Network policies, TLS everywhere
- Secret rotation, no defaults
- Image scanning, non-root containers
- Audit logging on admin actions
