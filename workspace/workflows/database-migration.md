---
apiVersion: anvio.io/v1
kind: Workflow
metadata:
  slug: database-migration
  version: "1.0.0"
  catalog: team
spec:
  description: Plan and execute safe database schema migrations with zero downtime.
  inputs:
    schemaChange:
      type: string
    strategy:
      type: string
      default: expand-migrate-contract
  nodes:
    - id: architect
      type: agent
      agent: architect
      template: |
        Review the proposed schema change and recommend a migration strategy.
        Consider backward compatibility, locking, and estimated execution time.

        Schema change: {{inputs.schemaChange}}
        Preferred strategy: {{inputs.strategy}}
    - id: backend
      type: agent
      agent: backend
      dependsOn: [architect]
      template: |
        Author up + down migration scripts, prioritise reversibility, mark large-table
        indexes as CONCURRENTLY. Migration strategy: {{nodes.architect.output}}
        Change: {{inputs.schemaChange}}
    - id: reviewer
      type: agent
      agent: reviewer
      dependsOn: [backend]
      onFailure: halt
      template: |
        Review migration for correctness, rollback safety, and locking concerns.
        Migration scripts: {{nodes.backend.output}}
    - id: qa
      type: agent
      agent: qa
      dependsOn: [reviewer]
      template: |
        Test migration on staging with production-sized dataset. Verify data integrity
        and rollback procedure.
        Migration and review verdict: {{nodes.reviewer.output}}
    - id: devops
      type: agent
      agent: devops
      dependsOn: [qa]
      onFailure: halt
      template: |
        Execute production migration during low-traffic window. Back up first.
        Monitor for locks and performance. Verify post-migration state.
        Approved migration: {{nodes.reviewer.output}}
        QA verdict: {{nodes.qa.output}}
  outputs:
    strategy:
      from: nodes.architect.output
    migrationScripts:
      from: nodes.backend.output
    devopsExecution:
      from: nodes.devops.output
---

# Database Migration Workflow

Strategies (from source-repo): expand-migrate-contract (zero downtime, read locks),
online-schema-change (minimal, brief), blue/green DB (zero, none), backward-compatible
(zero, none). Default: expand-migrate-contract.
