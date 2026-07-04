---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: repo-conventions
  version: "1.0.0"
  catalog: team
spec:
  name: Repo Conventions
  description: Repository conventions — naming, layout, commit hygiene
  category: operations
  tags: 
    - conventions
    - style
    - git
  permissions: 
    - read:documentation
    - read:codebase
  toolRequirements: []
  contextRequirements: 
    - project_context
---

# Repository Coding Conventions

## General

- Descriptive names; functions under ~40 lines
- One file per logical concern; linters/formatters required

## Go

- `gofumpt`, `go vet`, `staticcheck`
- Errors wrapped with context; `internal/` for private code
- DI via interfaces

## Python

- PEP 8, 100 char lines, type hints on public APIs
- `ruff` + `pytest`

## TypeScript

- Strict TS (no `any`); `biome` or eslint+prettier
- Vitest; prefer functions over classes

## Git

- Conventional Commits; feature branches from `main`
- Squash merge; linear history
