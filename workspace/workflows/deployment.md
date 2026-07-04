---
apiVersion: anvio.io/v1
kind: Workflow
metadata:
  slug: deployment
  version: "1.0.0"
  catalog: team
spec:
  description: Safe, repeatable production deployment with staged validation and rollback triggers.
  inputs:
    release:
      type: string
    strategy:
      type: string
      default: rolling-update
  nodes:
    - id: devops
      type: agent
      agent: devops
      template: |
        Pre-deployment: verify CI green, reviews approved, environment healthy,
        migration plan in place. Notify team.
        Release: {{inputs.release}}, strategy: {{inputs.strategy}}
    - id: qa
      type: agent
      agent: qa
      dependsOn: [devops]
      template: |
        Staging deployment complete. Run smoke, integration, e2e, migration checks.
        Devops readiness: {{nodes.devops.output}}
    - id: prodDeploy
      type: agent
      agent: devops
      dependsOn: [qa]
      onFailure: halt
      template: |
        Execute production deployment. Apply migrations first (if safe).
        Strategy: {{inputs.strategy}}. Monitor rollout. Rollback if error rate > 1%
        or latency > 20% baseline.
        QA verdict: {{nodes.qa.output}}
    - id: monitor
      type: agent
      agent: devops
      dependsOn: [prodDeploy]
      template: |
        Post-deployment smoke tests. Monitor metrics/errors 30 minutes. Verify alerting.
        Announce completion.
        Deploy result: {{nodes.prodDeploy.output}}
  outputs:
    prodResult:
      from: nodes.prodDeploy.output
    monitorReport:
      from: nodes.monitor.output
---

# Deployment Workflow

Deployment strategies (from source-repo): rolling-update (low risk, slow, stateless),
blue/green (very low, fast, critical), canary (minimal, gradual, high-risk), recreate
(high, instant, dev/demo only). Rollback triggers: error rate > 1%, latency > 20%.
