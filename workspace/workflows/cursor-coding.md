---
apiVersion: anvio.io/v1
kind: Workflow
metadata:
  slug: cursor-coding
  version: "1.0.0"
  catalog: team
spec:
  description: Tech-lead clarifies criteria; backend or frontend delegates implementation to Cursor Agent; reviewer gates via /cursor-code-review.
  inputs:
    task:
      type: string
    surface:
      type: string
      default: backend
    acceptanceCriteria:
      type: string
      default: ""
  nodes:
    - id: techLead
      type: agent
      agent: tech-lead
      template: |
        Clarify acceptance criteria and implementation plan for:
        {{inputs.task}}

        Existing acceptance criteria: {{inputs.acceptanceCriteria}}
    - id: routeSurface
      type: conditional
      dependsOn: [techLead]
      condition: "{{inputs.surface == 'frontend'}}"
    - id: backend
      type: agent
      agent: backend
      dependsOn: [routeSurface]
      template: |
        Delegate backend implementation to Cursor Agent via `/cursor-coding`.
        Plan and criteria: {{nodes.techLead.output}}
    - id: frontend
      type: agent
      agent: frontend
      dependsOn: [routeSurface]
      template: |
        Delegate frontend implementation to Cursor Agent via `/cursor-coding`.
        Plan and criteria: {{nodes.techLead.output}}
    - id: reviewer
      type: agent
      agent: reviewer
      dependsOn: [backend, frontend]
      onFailure: halt
      template: |
        Delegate code review to Cursor Agent via `/cursor-code-review`.
        Backend: {{nodes.backend.output}} — Frontend: {{nodes.frontend.output}}
  outputs:
    plan:
      from: nodes.techLead.output
    reviewerVerdict:
      from: nodes.reviewer.output
---

# Cursor Coding Workflow

Anvio profiles orchestrate; Cursor Agent implements the actual code changes.
Reviewer gate uses the `/cursor-code-review` skill before merge.
