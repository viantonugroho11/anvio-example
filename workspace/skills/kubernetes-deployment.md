---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: kubernetes-deployment
  version: "1.0.0"
  catalog: team
spec:
  name: Kubernetes Deployment
  description: Kubernetes deployment patterns — Deployments, StatefulSets, HPA, rolling updates
  category: devops
  tags: 
    - kubernetes
    - deployment
    - devops
  permissions: 
    - read:documentation
    - read:codebase
    - write:infrastructure
  toolRequirements: 
    - kubectl
    - helm
  contextRequirements: 
    - project_context
---

# Kubernetes Deployment

## Flow
1. Multi-stage Docker build
2. Manifests: Deployment, Service, Ingress, ConfigMap, Secret
3. Resource requests + limits
4. Liveness + readiness + startup probes
5. Pod anti-affinity + topology spread
6. HPA + PDB
7. Network policies
8. Rollout strategy
9. Monitor health

## Strategies
- RollingUpdate: maxSurge 25%, maxUnavailable 25%
- Blue/Green: switch via service selector
- Canary: %-based traffic shift

## Rules
- CPU/memory requests+limits on all containers
- Probes on all pods
- Anti-affinity for HA
- PDB for critical services
- Non-root user, read-only root FS where possible
