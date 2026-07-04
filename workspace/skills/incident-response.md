---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: incident-response
  version: "1.0.0"
  catalog: team
spec:
  name: Incident Response
  description: Structured incident response — triage, mitigate, communicate, postmortem
  category: devops
  tags: 
    - workflow
    - incident
    - sre
  permissions: 
    - read:documentation
    - read:codebase
  toolRequirements: []
  contextRequirements: 
    - project_context
    - current_alerts
    - recent_deploys
---

# Incident Response

## Trigger

Production alert, outage, SEV1–SEV4, or user-facing degradation.

## Participants

`@devops` (mitigate) · `@backend` (fix) · `@researcher` (RCA) · `@reviewer` (post-mortem)

## Steps

1. **Triage** — severity, impact, declare incident if SEV1/SEV2
2. **Mitigate** — rollback, scale, hotfix; restore service first
3. **RCA** — logs, metrics, traces; why detection missed it
4. **Permanent fix** — code/infra + monitoring improvements
5. **Post-mortem** — timeline, action items within 48h

## Severity SLA

| Level | Response |
|-------|----------|
| SEV1 | < 1h |
| SEV2 | < 4h |
| SEV3 | < 24h |
| SEV4 | next release |

## Validation

- Service restored before deep RCA
- Action items tracked to completion
- No secrets in incident timeline
