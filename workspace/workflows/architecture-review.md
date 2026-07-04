---
apiVersion: anvio.io/v1
kind: Workflow
metadata:
  slug: architecture-review
  version: "1.0.0"
  catalog: team
spec:
  description: Review architectural decisions for alignment with business goals and technical standards.
  inputs:
    proposal:
      type: string
    reviewScope:
      type: string
      default: "full — functional, non-functional, tech choices, maintainability, cross-cutting"
  nodes:
    - id: architect
      type: agent
      agent: architect
      template: |
        Conduct an architecture review.

        Proposal:
        {{inputs.proposal}}

        Review scope: {{inputs.reviewScope}}

        Cover: functional requirements, non-functional (scalability, performance, security),
        technology choices, maintainability, cross-cutting concerns, team alignment.
        Output: decision (Approve | Approve-with-conditions | Rework | Reject) with rationale
        and an ADR draft.
    - id: reviewer
      type: agent
      agent: reviewer
      dependsOn: [architect]
      template: |
        Supporting review — validate security and NFR alignment.

        Architect verdict and ADR draft:
        {{nodes.architect.output}}
      onFailure: halt
  outputs:
    verdict:
      from: nodes.architect.output
    securityValidation:
      from: nodes.reviewer.output
---

# Architecture Review Workflow

Runs `/architecture-review` skill via the architect, then routes the ADR draft through
the reviewer for security and NFR validation. Reviewer serves as the required quality gate.

```bash
anvio workflow run architecture-review proposal="Migrate order service to event sourcing"
```
