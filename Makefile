# Hermes Engineering Platform — Anvio edition
# Compose files retained from source-repo. Agent runtime = Anvio.

COMPOSE_DIR := docker
COMPOSE_FILE := $(COMPOSE_DIR)/docker-compose.yaml
COMPOSE_MEMORY := $(COMPOSE_DIR)/docker-compose.memory.yaml
COMPOSE_OBS := $(COMPOSE_DIR)/docker-compose.observability.yaml
COMPOSE_TELEMETRY := $(COMPOSE_DIR)/docker-compose.telemetry.yaml
COMPOSE := docker compose -f $(COMPOSE_FILE)

ANVIO_WORKSPACE ?= $(PWD)/workspace

.PHONY: help init validate agents skills workflows chat run \
	memory-up memory-down memory-index memory-search \
	observability-up observability-down telemetry-setup \
	cursor-delegate-setup workspace-init workspace-clone workspace-clone-all

help:
	@echo 'Anvio workspace at: $(ANVIO_WORKSPACE)'
	@echo ''
	@echo 'Common targets:'
	@echo '  init                    Initialize / validate the Anvio workspace'
	@echo '  validate                Run `anvio workspace validate`'
	@echo '  agents / skills / workflows  List declared artifacts'
	@echo '  chat AGENT=architect    Interactive chat with an agent'
	@echo '  run AGENT=architect Q="…" One-shot task'
	@echo ''
	@echo 'Ops:'
	@echo '  memory-up / memory-index / memory-search Q="…"'
	@echo '  observability-up / -down    Langfuse + OTel + Grafana stack'
	@echo ''
	@echo 'Slack is handled by Anvio native channel (spec.channels.slack in workspace/anvio.yaml).'

# ---------------------------------------------------------- Anvio CLI targets

init:
	ANVIO_WORKSPACE=$(ANVIO_WORKSPACE) anvio workspace validate || \
		{ echo 'Run: anvio init $(ANVIO_WORKSPACE) — or install: curl -fsSL https://raw.githubusercontent.com/viantonugroho11/Anvio/main/scripts/install.sh | bash'; exit 1; }

validate:
	ANVIO_WORKSPACE=$(ANVIO_WORKSPACE) anvio workspace validate

agents:
	ANVIO_WORKSPACE=$(ANVIO_WORKSPACE) anvio agents list

skills:
	ANVIO_WORKSPACE=$(ANVIO_WORKSPACE) anvio skill list

workflows:
	ANVIO_WORKSPACE=$(ANVIO_WORKSPACE) anvio workflow list

chat:
	@test -n "$(AGENT)" || (echo 'Usage: make chat AGENT=architect' && exit 1)
	ANVIO_WORKSPACE=$(ANVIO_WORKSPACE) anvio chat --agent $(AGENT)

run:
	@test -n "$(AGENT)" || (echo 'Usage: make run AGENT=architect Q="your prompt"' && exit 1)
	@test -n "$(Q)" || (echo 'Usage: make run AGENT=architect Q="your prompt"' && exit 1)
	ANVIO_WORKSPACE=$(ANVIO_WORKSPACE) anvio run $(AGENT) "$(Q)"

# ---------------------------------------------------------- Memory (PGVector)

memory-up:
	docker compose -f $(COMPOSE_MEMORY) up -d postgres-memory

memory-down:
	docker compose -f $(COMPOSE_MEMORY) down

memory-index:
	ANVIO_WORKSPACE=$(ANVIO_WORKSPACE) anvio memory index || \
		docker compose -f $(COMPOSE_MEMORY) run --rm memory-indexer

memory-search:
	@test -n "$(Q)" || (echo 'Usage: make memory-search Q="your query"' && exit 1)
	ANVIO_WORKSPACE=$(ANVIO_WORKSPACE) anvio memory search "$(Q)" --json || \
		( cd $(COMPOSE_DIR) && set -a && [ -f telemetry.env ] && . ./telemetry.env; set +a; \
		  MEMORY_DATABASE_URL=$${MEMORY_DATABASE_URL:-postgresql://hermes:hermes_memory_dev@localhost:5433/hermes_memory} \
		  python3 ../scripts/search_memory.py "$(Q)" --json )

# ---------------------------------------------------------- Observability

observability-up:
	docker compose -f $(COMPOSE_OBS) up -d

observability-down:
	docker compose -f $(COMPOSE_OBS) down

telemetry-setup:
	@test -f $(COMPOSE_DIR)/telemetry.env || cp $(COMPOSE_DIR)/telemetry.env.example $(COMPOSE_DIR)/telemetry.env
	@echo 'Edit docker/telemetry.env with your keys'

# ---------------------------------------------------------- Cursor delegation

cursor-delegate-setup:
	cd scripts/cursor-delegate && npm install
	@echo 'Cursor delegate ready. Set CURSOR_API_KEY in .env'

# ---------------------------------------------------------- Bitbucket workspaces

workspace-init:
	@mkdir -p projects
	@echo 'Workspace ready at projects/ (mounted as /workspace in containers)'

workspace-clone:
	@test -n "$(REPO)" || (echo 'Usage: make workspace-clone REPO=repo-name [WORKSPACE=projects]' && exit 1)
	@test -n "$(BITBUCKET_WORKSPACE)" || (echo 'Set BITBUCKET_WORKSPACE in docker/.env or export it' && exit 1)
	@mkdir -p $(or $(WORKSPACE),projects)
	@if [ -d "$(or $(WORKSPACE),projects)/$(REPO)/.git" ]; then \
		echo "Already cloned: $(or $(WORKSPACE),projects)/$(REPO)"; \
		cd "$(or $(WORKSPACE),projects)/$(REPO)" && git pull; \
	else \
		if ssh -o BatchMode=yes -T git@bitbucket.org 2>&1 | grep -qi authenticated; then \
			git clone "git@bitbucket.org:$(BITBUCKET_WORKSPACE)/$(REPO).git" "$(or $(WORKSPACE),projects)/$(REPO)"; \
		elif [ -n "$$BITBUCKET_USERNAME" ] && [ -n "$$BITBUCKET_APP_PASSWORD" ]; then \
			git -c 'credential.helper=!f() { echo username=$$BITBUCKET_USERNAME; echo password=$$BITBUCKET_APP_PASSWORD; }; f' \
				clone "https://bitbucket.org/$(BITBUCKET_WORKSPACE)/$(REPO).git" "$(or $(WORKSPACE),projects)/$(REPO)"; \
		else \
			echo 'Need SSH key or BITBUCKET_USERNAME + BITBUCKET_APP_PASSWORD in docker/.env' && exit 1; \
		fi; \
	fi
	@echo 'Clone at $(or $(WORKSPACE),projects)/$(REPO) → container path /workspace/$(REPO)'

workspace-clone-all:
	@test -n "$(BITBUCKET_REPOS)" || (echo 'Set BITBUCKET_REPOS in docker/.env' && exit 1)
	@for r in $$(echo "$(BITBUCKET_REPOS)" | tr ',' ' '); do \
		$(MAKE) workspace-clone REPO=$$r WORKSPACE=$(or $(WORKSPACE),projects); \
	done

