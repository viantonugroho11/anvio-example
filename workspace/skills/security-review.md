---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: security-review
  version: "1.0.0"
  catalog: team
spec:
  name: Security Review
  description: Security review — OWASP Top 10, threat modeling, secret handling
  category: security
  routing: planning
  tags: 
    - security
    - review
    - audit
  permissions: 
    - read:documentation
    - read:codebase
    - call:external_agent
  toolRequirements: []
  contextRequirements: 
    - project_context
    - changeset
---

# Security Review

## OWASP Top 10
- Broken access control (server-side enforcement)
- Cryptographic failures (encrypt at rest + in transit)
- Injection (SQL, NoSQL, OS, LDAP neutralized)
- Insecure design (security in architecture)
- Security misconfiguration (secure defaults)
- Vulnerable components (SCA for CVEs)
- Authentication failures (MFA, hashed passwords)
- Integrity failures (signed CI/CD artifacts)
- Logging & monitoring (security events alerted)
- SSRF (restrict outbound to allowlist)

## Process
1. Architecture security design flaws
2. Code implementation vulnerabilities
3. Dependency SCA scanning
4. Auth + authorization flows
5. Data handling (PII, secrets, encryption)
6. API security (rate limit, input validation)
7. Infrastructure security (network, IAM)

## Severity
- Critical: fix immediately
- High: fix this sprint
- Medium: fix next iteration
- Low: consider fixing
