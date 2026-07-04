---
apiVersion: anvio.io/v1
kind: Workflow
metadata:
  slug: code-review
  version: "1.0.0"
  catalog: team
spec:
  description: Structured code review — delegates to the /code-review skill via the reviewer agent.
  inputs:
    changeset:
      type: string
  nodes:
    - id: reviewer
      type: agent
      agent: reviewer
      onFailure: halt
      template: |
        Perform a structured code review of the following changeset. Use the
        `/code-review` skill. Emit verdict: APPROVE | CHANGES_REQUESTED | REJECT.

        Changeset:
        {{inputs.changeset}}
  outputs:
    verdict:
      from: nodes.reviewer.output
---

# Code Review Workflow

Thin wrapper around the canonical `/code-review` skill; reviewer is the required gate.
