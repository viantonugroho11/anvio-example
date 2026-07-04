---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: code-review
  version: "1.0.0"
  catalog: team
spec:
  name: Code Review
  description: Structured code review with security and maintainability focus
  category: review
  routing: coding
  tags: 
    - code-review
    - quality
  permissions: 
    - read:documentation
    - read:codebase
    - call:external_agent
  toolRequirements: []
  contextRequirements: 
    - project_context
    - changeset
---

# Code Review

> **Execution:** For Hermes profiles, prefer `/cursor-code-review` — Hermes orchestrates, Cursor Agent performs the review. This skill remains the checklist and output format reference.

## Checklist
- Correctness: requirements, edge cases, error handling, concurrency
- Security: input validation, auth, secrets, injection
- Performance: N+1 queries, caching, allocations, pagination
- Maintainability: clean, readable, sized functions, clear names
- Testing: unit tests for new logic, edge cases, integration tests

## Process
1. Understand context + requirements
2. Read diff systematically
3. Leave constructive, specific, actionable comments
4. Explain WHY, not just WHAT

## Chat Review Format
```
File: path | Line: N
[🔴 Critical | 🟡 Warning | 🔵 Suggestion | ⚪ Question]
Issue: ...
Suggestion: ...
```

## Output
```
## Review Overview
[summary + assessment]
## [🔴 Critical | 🟡 Warnings | 🔵 Suggestions]
...
## Summary: ✅ Approve / ❌ Changes Requested
```
