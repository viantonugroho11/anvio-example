---
apiVersion: anvio.io/v1
kind: Workflow
metadata:
  slug: incident-response
  version: "1.0.0"
  catalog: team
spec:
  description: Structured incident response — delegates to the /incident-response skill via devops.
  inputs:
    alert:
      type: string
    severity:
      type: string
      default: SEV2
  nodes:
    - id: devops
      type: agent
      agent: devops
      onFailure: halt
      template: |
        Run `/incident-response`. Severity: {{inputs.severity}}. Alert:
        {{inputs.alert}}
        Triage → mitigate → communicate → postmortem.
  outputs:
    incidentReport:
      from: nodes.devops.output
---

# Incident Response Workflow

Thin wrapper around the canonical `/incident-response` skill. Devops soul owns docker
access and is the correct entry point.
