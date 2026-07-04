---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: kafka-consumer
  version: "1.0.0"
  catalog: team
spec:
  name: Kafka Consumer
  description: Kafka consumer implementation patterns (idempotency, batching, DLQ)
  category: backend
  tags: 
    - kafka
    - consumer
    - event-driven
  permissions: 
    - read:documentation
    - read:codebase
    - write:codebase
  toolRequirements: 
    - kafka-topics
    - kcat
  contextRequirements: 
    - project_context
---

# Kafka Consumer

## Flow
1. Define message schema (protobuf/Avro/JSON)
2. Configure consumer group, topic, partitioning
3. Deserialize with schema validation
4. Idempotent processing (same message may deliver twice)
5. Commit offset after success
6. Retry (3x, exponential backoff) → Dead Letter Topic → Alert

## Rules
- Process within configurable timeout
- Monitor consumer lag
- Graceful shutdown
- Schema registry for evolution
- Consumer group rebalance listeners
