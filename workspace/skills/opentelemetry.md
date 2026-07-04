---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: opentelemetry
  version: "1.0.0"
  catalog: team
spec:
  name: Opentelemetry
  description: OpenTelemetry instrumentation — traces, metrics, context propagation
  category: observability
  tags: 
    - observability
    - devops
  permissions: 
    - read:documentation
    - read:codebase
    - write:infrastructure
  toolRequirements: []
  contextRequirements: 
    - project_context
---

# OpenTelemetry

## Signals
- Traces: span per request/operation
- Metrics: RED/USE method
- Logs: structured, trace_id correlation

## Propagation
W3C tracecontext across services
