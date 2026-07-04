---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: observability-stack
  version: "1.0.0"
  catalog: team
spec:
  name: Observability Stack
  description: Assemble an observability stack (metrics, logs, traces) with OTel
  category: observability
  tags: 
    - observability
    - monitoring
    - prometheus
    - grafana
  permissions: 
    - read:documentation
    - read:codebase
  toolRequirements: []
  contextRequirements: 
    - project_context
---

# Observability Stack

## Pillars
1. Metrics (Prometheus) — numerical over time
2. Logs (Loki) — timestamped events
3. Traces (Tempo) — request lifecycle

## Flow
App → OpenTelemetry SDK → OTel Collector → Prometheus/Loki/Tempo → Grafana → Alertmanager → notifications

## Process
1. Instrument with OpenTelemetry SDK
2. Configure OTel Collector
3. Prometheus for metrics
4. Loki for logs
5. Tempo for traces
6. Grafana dashboards
7. Alertmanager rules
8. Define SLIs + SLOs

## Rules
- RED metrics for services (Rate, Errors, Duration)
- USE metrics for resources (Utilization, Saturation, Errors)
- Business metrics alongside technical
- Structured logging (JSON)
- Propagate trace context across services
- Synthetic monitoring for critical paths
- Runbooks for all alerts
