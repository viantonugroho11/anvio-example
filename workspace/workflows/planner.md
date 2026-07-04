---
apiVersion: anvio.io/v1
kind: Workflow
metadata:
  slug: planner
  version: "1.0.0"
  catalog: team
spec:
  description: |
    Canonical PLAN → EXECUTE → REVIEW → FINALIZE routing.
    Translated from source-repo/configs/planner.yaml per ADR-006.
    Complexity scoring is a transform node; phase gates are dependsOn edges;
    quality gate is the reviewer soul's ## Approvers block.
  inputs:
    request:
      type: string
    mention:
      type: string
      default: ""
    complexitySignals:
      type: string
      default: ""
  nodes:
    # ---- Complexity classification (Hermes: simple/medium/high thresholds 0.3/0.6) ----
    - id: classify
      type: transform
      template: |
        request: {{inputs.request}}
        mention: {{inputs.mention}}
        signals: {{inputs.complexitySignals}}
        (Downstream conditional nodes read this via {{nodes.classify.output}}
         and decide whether the plan phase runs.)

    # ---- PLAN phase (complexity >= 0.3 → tech-lead; fallback architect) ----
    - id: plan
      type: agent
      agent: tech-lead
      dependsOn: [classify]
      template: |
        Produce a task graph and acceptance criteria for:
        {{inputs.request}}

        Complexity signals: {{nodes.classify.output}}

    # ---- EXECUTE phase — auto-routed by mention or auto_select rules ----
    - id: executeArchitect
      type: agent
      agent: architect
      dependsOn: [plan]
      template: |
        Design architecture for the requested work.
        Plan: {{nodes.plan.output}}

    - id: executeBackend
      type: agent
      agent: backend
      dependsOn: [plan]
      template: |
        Implement backend per plan (via /cursor-coding).
        Plan: {{nodes.plan.output}}

    - id: executeFrontend
      type: agent
      agent: frontend
      dependsOn: [plan]
      template: |
        Implement frontend per plan (via /cursor-coding).
        Plan: {{nodes.plan.output}}

    - id: executeDevops
      type: agent
      agent: devops
      dependsOn: [plan]
      template: |
        Provision / update infrastructure per plan.
        Plan: {{nodes.plan.output}}

    - id: executeQa
      type: agent
      agent: qa
      dependsOn: [executeBackend, executeFrontend]
      template: |
        Validate against acceptance criteria.
        Plan: {{nodes.plan.output}}
        Backend: {{nodes.executeBackend.output}}
        Frontend: {{nodes.executeFrontend.output}}

    # ---- REVIEW phase — required gate; block on CRITICAL/REJECT ----
    - id: review
      type: agent
      agent: reviewer
      dependsOn: [executeBackend, executeFrontend, executeDevops, executeArchitect]
      onFailure: halt
      template: |
        Review all changes. Block on CRITICAL / REJECT.
        Architect: {{nodes.executeArchitect.output}}
        Backend: {{nodes.executeBackend.output}}
        Frontend: {{nodes.executeFrontend.output}}
        DevOps: {{nodes.executeDevops.output}}

    # ---- FINALIZE phase — persist memory + document ----
    - id: finalize
      type: agent
      agent: documenter
      dependsOn: [review, executeQa]
      template: |
        Persist ADRs and episodes to memory. Document API and user-facing changes.
        Reviewer verdict: {{nodes.review.output}}
        QA verdict: {{nodes.executeQa.output}}
  outputs:
    complexity:
      from: nodes.classify.output
    plan:
      from: nodes.plan.output
    reviewerVerdict:
      from: nodes.review.output
    documentation:
      from: nodes.finalize.output
---

# Planner (PLAN → EXECUTE → REVIEW → FINALIZE)

Translated from `source-repo/configs/planner.yaml` per ADR-006. Notable choices:

- **Complexity scoring** is a `transform` node whose output feeds downstream conditionals.
  The Hermes numeric thresholds (`simple 0.3`, `medium 0.6`) are represented as free-text
  signals emitted from `classify`.
- **Phase ordering** is expressed via `dependsOn`. Parallel execute branches converge
  on `review`.
- **Quality gate** is `nodes.review.onFailure: halt` plus the reviewer soul's `## Approvers`
  block (`workspace/souls/reviewer-soul/SOUL.md`).
- **Auto-routing** by mention is handled by Anvio channel routing before the workflow
  starts; the mention is passed in as `inputs.mention` for reference.

Run:

```bash
anvio workflow run planner request="Add JWT refresh-token endpoint"
```
