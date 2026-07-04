---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: nextjs
  version: "1.0.0"
  catalog: team
spec:
  name: Nextjs
  description: Next.js architecture — App Router, RSC, streaming, edge
  category: frontend
  tags: 
    - frontend
    - nextjs
  permissions: 
    - read:documentation
    - read:codebase
    - write:codebase
  toolRequirements: []
  contextRequirements: 
    - project_context
---

# Next.js

## Practices
- App Router: layouts, loading, error boundaries
- Server Components by default; Client when needed
- Route handlers for BFF patterns
- Metadata and SEO
- Image/font optimization built-in
