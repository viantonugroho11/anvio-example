---
apiVersion: anvio.io/v1
kind: Workflow
metadata:
  slug: bug-investigation
  version: "1.0.0"
  catalog: team
spec:
  description: Diagnose, fix, and validate bug fixes across research, backend/frontend, QA, and reviewer.
  inputs:
    reproSteps:
      type: string
    surface:
      type: string
      default: backend
    priority:
      type: string
      default: medium
  nodes:
    - id: researcher
      type: agent
      agent: researcher
      template: |
        Root-cause analysis for this bug.

        Reproduction steps:
        {{inputs.reproSteps}}

        Analyze logs, metrics, traces. Narrow to a component. Identify root cause and impact scope.
        Do NOT propose a fix — hand off to backend or frontend.

    - id: routeSurface
      type: conditional
      dependsOn: [researcher]
      condition: "{{inputs.surface == 'frontend'}}"

    - id: backend
      type: agent
      agent: backend
      dependsOn: [routeSurface]
      template: |
        Implement bug fix (backend surface).

        Root-cause analysis:
        {{nodes.researcher.output}}

        Design minimal fix with least risk. Write reproducing test first, then fix.

    - id: frontend
      type: agent
      agent: frontend
      dependsOn: [routeSurface]
      template: |
        Implement bug fix (frontend surface).

        Root-cause analysis:
        {{nodes.researcher.output}}

    - id: qa
      type: agent
      agent: qa
      dependsOn: [backend, frontend]
      template: |
        Validate the fix and run regression tests.
        Backend result: {{nodes.backend.output}}
        Frontend result: {{nodes.frontend.output}}

    - id: reviewer
      type: agent
      agent: reviewer
      dependsOn: [backend, frontend]
      onFailure: halt
      template: |
        Review the fix. Backend: {{nodes.backend.output}} — Frontend: {{nodes.frontend.output}}
  outputs:
    rootCause:
      from: nodes.researcher.output
    qaVerdict:
      from: nodes.qa.output
    reviewerVerdict:
      from: nodes.reviewer.output
---

# Bug Investigation Workflow

Priority mapping (from source-repo/workflows/bug-investigation): critical → hours,
high → 24h, medium → next release, low → scheduled. Priority is tracked in `inputs.priority`
and referenced by the tech-lead when scheduling follow-ups.
