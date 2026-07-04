---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: prometheus-metrics
  version: "1.0.0"
  catalog: team
spec:
  name: Prometheus Metrics
  description: Design Prometheus metrics — counters, gauges, histograms, labels
  category: observability
  tags: 
    - prometheus
    - metrics
    - monitoring
  permissions: 
    - read:documentation
    - read:codebase
    - write:infrastructure
  toolRequirements: 
    - promtool
  contextRequirements: 
    - project_context
---

# Prometheus Metrics

## Types
- Counter: only increases (requests, errors)
- Gauge: up/down (connections, memory)
- Histogram: bucketed observations (latency)
- Summary: histogram + quantiles

## Naming
`{domain}_{type}_{unit}{_total}` with labels: `method`, `path`, `status`

## RED (Services): Rate, Errors, Duration
## USE (Resources): Utilization, Saturation, Errors

## Verify
- `/metrics` returns valid Prometheus format
- All services expose RED metrics
- All resources expose USE metrics
- Grafana dashboards display correctly
- Alert rules for SLO violations
