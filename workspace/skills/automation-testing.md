---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: automation-testing
  version: "1.0.0"
  catalog: team
spec:
  name: Automation Testing
  description: Test automation frameworks and CI-integrated regression suites
  category: qa
  routing: qa
  tags: 
    - qa
    - testing
  permissions: 
    - read:documentation
    - read:codebase
    - write:codebase
  toolRequirements: []
  contextRequirements: 
    - project_context
    - acceptance_criteria
---

# Automation Testing

## CI
- Fast unit suite on every PR
- Integration on merge
- Nightly e2e/perf

## Rules
- Stable selectors; no flaky waits
- Fail fast with actionable logs
