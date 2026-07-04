---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: postgres-optimization
  version: "1.0.0"
  catalog: team
spec:
  name: Postgres Optimization
  description: PostgreSQL performance tuning — indexes, plans, VACUUM, partitions
  category: backend
  tags: 
    - postgresql
    - database
    - optimization
  permissions: 
    - read:documentation
    - read:codebase
    - write:codebase
  toolRequirements: 
    - psql
  contextRequirements: 
    - project_context
---

# PostgreSQL Optimization

## Diagnosis
1. `pg_stat_statements` for profiling
2. `EXPLAIN ANALYZE` on slow queries
3. Check seq scans on large tables
4. Monitor connection pool
5. Check index usage (`pg_stat_user_indexes`)
6. Check bloat (`pgstattuple`)

## Query
- Appropriate indexes (B-tree, BRIN, GiST, GIN)
- WHERE clauses for index utilization
- No `SELECT *` in production
- `LIMIT` + pagination
- `EXISTS` over `COUNT(*)` for existence

## Schema
- Normalize (3NF), denormalize strategically
- Appropriate data types, `VARCHAR` with limits
- Partition large tables
- Covering indexes for index-only scans
- Partial indexes for filtered queries

## Config
- `shared_buffers`: 25% RAM
- `effective_cache_size`: 50-75% RAM
- `random_page_cost`: SSD < HDD
