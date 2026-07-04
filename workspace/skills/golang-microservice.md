---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: golang-microservice
  version: "1.0.0"
  catalog: team
spec:
  name: Golang Microservice
  description: Golang microservice patterns and repository layout
  category: backend
  tags: 
    - go
    - microservice
    - backend
  permissions: 
    - read:documentation
    - read:codebase
    - write:codebase
  toolRequirements: []
  contextRequirements: 
    - project_context
---

# Golang Microservice

## Layout
```
cmd/server/main.go
internal/{domain/{entity,repository,service}, handler, repository, middleware}
pkg/{config, logger}
```

## Flow
1. Domain entities + repository interfaces
2. Business logic in domain services
3. Repository impl (SQL, Redis)
4. HTTP/gRPC handlers
5. Wire deps in main.go
6. Tests per layer
7. Dockerfile + CI

## Rules
- `internal/` for encapsulation
- Domain layer: zero external deps
- Interfaces for dependency inversion
- Structured logging (zerolog/slog)
- Graceful shutdown
- Request validation at handler layer
- `context.Context` for cancellation
- `go build ./...` + `go vet ./...` + `go test ./... -race`
