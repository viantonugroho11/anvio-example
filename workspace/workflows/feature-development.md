---
apiVersion: anvio.io/v1
kind: Workflow
metadata:
  slug: feature-development
  version: "1.0.0"
  catalog: team
spec:
  description: |
    End-to-end feature delivery — architect designs, backend + frontend implement in
    parallel, qa validates, reviewer gates, documenter finalizes.
    Derived from source-repo/configs/planner.yaml workflows.feature-development.
  inputs:
    task:
      type: string
    acceptanceCriteria:
      type: string
      default: ""
  nodes:
    - id: architect
      type: agent
      agent: architect
      template: |
        Design the solution architecture and any required ADRs for:
        {{inputs.task}}

        Acceptance criteria: {{inputs.acceptanceCriteria}}

        Produce: architecture summary, key decisions, integration points, risks.

    - id: backend
      type: agent
      agent: backend
      dependsOn: [architect]
      template: |
        Implement the backend API and business logic per this design:
        {{nodes.architect.output}}

        Task: {{inputs.task}}

    - id: frontend
      type: agent
      agent: frontend
      dependsOn: [architect]
      template: |
        Implement the frontend UI per this design:
        {{nodes.architect.output}}

        Task: {{inputs.task}}

    - id: qa
      type: agent
      agent: qa
      dependsOn: [backend, frontend]
      template: |
        Validate the following implementation against the acceptance criteria.

        Acceptance criteria: {{inputs.acceptanceCriteria}}

        Backend deliverable:
        {{nodes.backend.output}}

        Frontend deliverable:
        {{nodes.frontend.output}}

    - id: reviewer
      type: agent
      agent: reviewer
      dependsOn: [backend, frontend]
      # Reviewer is a required quality gate. The reviewer soul's ## Approvers
      # block enforces human-in-the-loop for CRITICAL/REJECT verdicts.
      template: |
        Review all code changes from backend and frontend for correctness,
        security, and maintainability. Block on CRITICAL/REJECT.

        Backend changes:
        {{nodes.backend.output}}

        Frontend changes:
        {{nodes.frontend.output}}
      onFailure: halt

    - id: documenter
      type: agent
      agent: documenter
      dependsOn: [backend, frontend, reviewer]
      template: |
        Document API and user-facing changes based on:
        - Architecture: {{nodes.architect.output}}
        - Reviewer verdict: {{nodes.reviewer.output}}

  outputs:
    architecture:
      from: nodes.architect.output
    backendResult:
      from: nodes.backend.output
    frontendResult:
      from: nodes.frontend.output
    qaVerdict:
      from: nodes.qa.output
    reviewerVerdict:
      from: nodes.reviewer.output
    documentation:
      from: nodes.documenter.output
---

# Feature Development Workflow

Reference: source-repo/workflows/feature-development/workflow.md points at the canonical
skill `/feature-development` (source-repo/skills/feature-development/SKILL.md). This DAG
adds explicit orchestration on top of that procedure using `dependsOn` for parallelism
and the reviewer gate.

Run with:

```bash
anvio workflow run feature-development \
  task="Add JWT refresh-token endpoint" \
  acceptanceCriteria="401 on expired token, sliding session, rate-limited"
```
