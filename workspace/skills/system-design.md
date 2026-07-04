---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: system-design
  version: "1.0.0"
  catalog: team
spec:
  name: System Design
  description: System design — components, contracts, non-functional requirements
  category: architecture
  routing: planning
  tags: 
    - architecture
    - design
  permissions: 
    - read:documentation
    - read:codebase
  toolRequirements: []
  contextRequirements: 
    - project_context
    - requirements
---

# System Design

## Process
1. Clarify functional + non-functional requirements
2. Identify constraints (latency, cost, compliance)
3. Propose 2-3 options with trade-offs
4. Recommend design with migration path

## Outputs
- Component diagram (text/mermaid)
- Data flow and boundaries
- NFR mapping (scalability, availability, cost)
