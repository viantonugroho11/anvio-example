---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: terraform
  version: "1.0.0"
  catalog: team
spec:
  name: Terraform
  description: Terraform IaC — modules, state management, plan/apply hygiene
  category: devops
  tags: 
    - devops
    - iac
  permissions: 
    - read:documentation
    - read:codebase
    - write:infrastructure
  toolRequirements: 
    - terraform
  contextRequirements: 
    - project_context
---

# Terraform

## Practices
- Modules for reuse; remote state
- Plan before apply; lock state
- Pin provider versions
- Separate envs (workspace or dir)

## Safety
- No secrets in .tf; use vault/vars
