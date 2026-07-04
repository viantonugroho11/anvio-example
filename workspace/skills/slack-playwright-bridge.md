---
apiVersion: anvio.io/v1
kind: Skill
metadata:
  slug: slack-playwright-bridge
  version: "1.0.0"
  catalog: team
spec:
  name: Slack Playwright Bridge
  description: Slack ↔ Hermes/Anvio bridge via Playwright automation on macOS host
  category: operations
  tags: 
    - slack
    - playwright
    - bridge
    - hermes
  permissions: 
    - read:documentation
    - read:codebase
  toolRequirements: 
    - slack-cli
    - playwright
  contextRequirements: 
    - project_context
---

# Slack Playwright Bridge

Host-side service (`services/slack-playwright/`) monitors Slack Web and routes commands to existing Hermes profiles and Cursor Agent.

## When to use

- User asks about Slack commands (`/codereview`, `/code-task`, etc.)
- Debugging Slack bridge integration
- Do **not** reimplement — the bridge calls existing tools

## Commands (user-facing)

```text
/codereview PR-123     → cursor-bitbucket-review.sh
/code-task <prompt>    → delegate.mjs code
/summary               → hermes chat summarize
/backend|devops|...    → hermes -p {profile} chat
/help
```

## Start bridge (host Mac)

```bash
make slack-playwright-install
make slack-playwright-run
```

Requires `services/slack-playwright/.env` with `SLACK_OWNER_USER_ID` and `SLACK_CHANNEL_URL`.

## Hermes agents

When running **inside Docker**, you are Telegram/gateway — not the Slack bridge. Slack bridge runs on host and calls you via `docker exec hermes -p backend chat -q ...`.

Do not generate SSH keys or patch read-only scripts — see `/bitbucket-cli`.

## Security

Only owner or `@mention` commands are processed. Unknown commands are ignored silently.
