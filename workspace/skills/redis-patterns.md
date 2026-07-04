---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: redis-patterns
  version: "1.0.0"
  catalog: team
spec:
  name: Redis Patterns
  description: Redis usage patterns — caching, pub/sub, streams, rate limiting
  category: backend
  tags: 
    - redis
    - caching
    - backend
  permissions: 
    - read:documentation
    - read:codebase
    - write:codebase
  toolRequirements: 
    - redis-cli
  contextRequirements: 
    - project_context
---

# Redis Patterns

## Common
- Cache-Aside: check cache → miss → query DB → set cache with TTL
- Distributed Lock: acquire → operate → release (TTL for safety)
- Rate Limiter: sliding window via INCR + EXPIRE
- Session Store: SET with TTL
- Pub/Sub: PUBLISH + SUBSCRIBE for real-time

## Rules
- TTL on all cached data
- Connection pooling
- Monitor cache hit ratio
- Pipeline for batch ops
- Lua scripts for atomic multi-key ops
- Avoid: hot keys, cache stampede, unbounded keys
