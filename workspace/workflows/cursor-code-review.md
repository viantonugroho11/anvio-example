---
apiVersion: anvio.io/v1
kind: Workflow
metadata:
  slug: cursor-code-review
  version: "1.0.0"
  catalog: team
spec:
  description: Scope review in the reviewer profile; execute via Cursor Agent through /cursor-code-review skill.
  inputs:
    prReference:
      type: string
  nodes:
    - id: reviewer
      type: agent
      agent: reviewer
      onFailure: halt
      template: |
        Scope this review, compose the Cursor prompt, and run `/cursor-code-review`.
        Deliver verdict: APPROVE | CHANGES_REQUESTED | REJECT.

        PR reference: {{inputs.prReference}}
  outputs:
    verdict:
      from: nodes.reviewer.output
---

# Cursor Code Review Workflow

Anvio (reviewer soul) orchestrates; Cursor Agent executes the review.
Optional post-step: post inline comments via Bitbucket / GitHub MCP.
