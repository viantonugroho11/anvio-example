---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: disaster-recovery
  version: "1.0.0"
  catalog: team
spec:
  name: Disaster Recovery
  description: Disaster-recovery planning — RTO, RPO, runbooks, failover
  category: devops
  tags: 
    - devops
    - reliability
  permissions: 
    - read:documentation
    - read:codebase
  toolRequirements: []
  contextRequirements: 
    - project_context
---

# Disaster Recovery

## Plan
- RPO/RTO targets per tier
- Backups: frequency, restore tests
- Multi-AZ; DR region for critical
- Runbooks: failover, rollback

## Test
Game days and restore drills
