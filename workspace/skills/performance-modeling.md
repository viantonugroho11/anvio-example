---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: performance-modeling
  version: "1.0.0"
  catalog: team
spec:
  name: Performance Modeling
  description: Performance modeling and capacity planning
  category: architecture
  tags: 
    - performance
    - architecture
  permissions: 
    - read:documentation
    - read:codebase
  toolRequirements: []
  contextRequirements: 
    - project_context
---

# Performance Modeling

## Approach
1. Define SLOs (p50/p99 latency, throughput)
2. Identify critical path and bottlenecks
3. Estimate capacity (QPS, connections, queue depth)
4. Load test assumptions vs measurements

## Output
Capacity plan, scaling triggers, risk areas
