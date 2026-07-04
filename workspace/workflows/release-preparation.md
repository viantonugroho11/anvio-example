---
apiVersion: anvio.io/v1
kind: Workflow
metadata:
  slug: release-preparation
  version: "1.0.0"
  catalog: team
spec:
  description: Coordinate a release from code freeze through shipping.
  inputs:
    version:
      type: string
    scope:
      type: string
      default: ""
  nodes:
    - id: architect
      type: agent
      agent: architect
      template: |
        Approve release scope for version {{inputs.version}}.
        Scope: {{inputs.scope}}
    - id: devops
      type: agent
      agent: devops
      dependsOn: [architect]
      template: |
        Enter code freeze on release branch. Cut release-candidate tag {{inputs.version}}-rc.1
        and deploy to staging.
        Approved scope: {{nodes.architect.output}}
    - id: qa
      type: agent
      agent: qa
      dependsOn: [devops]
      template: |
        Full regression + performance + security scan on the release candidate.
        RC ready: {{nodes.devops.output}}
    - id: documenter
      type: agent
      agent: documenter
      dependsOn: [qa]
      template: |
        Write release notes for {{inputs.version}}: features, bug fixes, breaking
        changes, migrations, known issues.
        QA verdict: {{nodes.qa.output}}
    - id: reviewer
      type: agent
      agent: reviewer
      dependsOn: [qa, documenter]
      onFailure: halt
      template: |
        Final gate. Approve or reject the release.
        QA: {{nodes.qa.output}}
        Notes: {{nodes.documenter.output}}
    - id: ship
      type: agent
      agent: devops
      dependsOn: [reviewer]
      onFailure: halt
      template: |
        Tag final {{inputs.version}} and deploy to production. Monitor. Announce.
        Reviewer verdict: {{nodes.reviewer.output}}
  outputs:
    releaseNotes:
      from: nodes.documenter.output
    reviewerVerdict:
      from: nodes.reviewer.output
    shipResult:
      from: nodes.ship.output
---

# Release Preparation Workflow

Reviewer is the required final gate before shipping. Documenter output is auto-persisted
by the reviewer soul's mandate ("documentation is a deliverable").
