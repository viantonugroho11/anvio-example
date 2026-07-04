---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: grafana-dashboard
  version: "1.0.0"
  catalog: team
spec:
  name: Grafana Dashboard
  description: Grafana dashboard authoring for observability
  category: observability
  tags: 
    - grafana
    - dashboard
    - visualization
  permissions: 
    - read:documentation
    - read:codebase
    - write:infrastructure
  toolRequirements: 
    - grafana
  contextRequirements: 
    - project_context
---

# Grafana Dashboard

## Flow
1. Define purpose + audience
2. Key metrics + log sources
3. Layout with logical grouping
4. Panels with right visualizations
5. Variable selectors for filtering
6. Alert thresholds
7. Version control as JSON

## Panel Types
- Time Series: metrics over time
- Stat: single current value
- Gauge: value vs threshold
- Table: tabular data
- Bar Chart: comparisons
- Logs: log viewing
- Traces: flame graphs

## Structure
```
Row: Key Metrics → Stat panels (rate, error, latency, users)
Row: Performance → latency graphs, rate by status, throughput
Row: Resources → CPU, memory, disk, network
Row: Logs & Traces
```

## Rules
- Template variables for common filters
- Consistent colors
- Most important at top
- Use annotations for deployments/incidents
- Reasonable time range defaults
