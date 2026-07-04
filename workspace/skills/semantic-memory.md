---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: semantic-memory
  version: "1.0.0"
  catalog: team
spec:
  name: Semantic Memory
  description: PGVector semantic memory — index, search, curate long-term knowledge
  category: operations
  tags: 
    - memory
    - rag
    - pgvector
  permissions: 
    - read:documentation
    - read:codebase
    - write:memory_index
  toolRequirements: 
    - mcp:hermes-memory
  contextRequirements: 
    - project_context
---

# Semantic Memory (PGVector)

## When to Use

Before designing or implementing, search team memory for ADRs, standards, conventions, and past episodes.

## Search

```bash
python scripts/search_memory.py "your query" --json
# or: make memory-search Q="kafka partitioning strategy"
```

## Index (after updating memory/)

```bash
make memory-index
```

## Filters

- `--doc-type adr|standard|convention|episode`
- `--team-id default`
- `--top-k 5`

## Rules

- Prefer retrieved ADRs over generic advice
- Cite `source_path` when using memory content
- Write new ADRs to `memory/decisions/` then re-index
