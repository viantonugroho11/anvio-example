FROM nousresearch/hermes-agent:latest

# Install additional tools + Cursor CLI (local-mode SDK delegation)
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    git \
    jq \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Cursor Agent CLI — https://cursor.com/docs/cli/headless
# Requires glibc (Debian base). Install to /opt/cursor so all users can run agent.
ENV CURSOR_HOME=/opt/cursor
ENV PATH="/usr/local/bin:/opt/cursor/.local/bin:${PATH}"
RUN mkdir -p /opt/cursor \
    && bash -c 'export HOME=/opt/cursor; curl https://cursor.com/install -fsS | bash' \
    && ln -sf /opt/cursor/.local/bin/agent /usr/local/bin/agent \
    && ln -sf /opt/cursor/.local/bin/cursor-agent /usr/local/bin/cursor-agent \
    && /usr/local/bin/agent --version

# Cursor delegation bridge (Hermes → Cursor Agent via @cursor/sdk)
COPY scripts/cursor-delegate/ /opt/cursor-delegate/
RUN cd /opt/cursor-delegate && npm install --omit=dev

# Hermes helper scripts (also mounted at runtime for live edits)
COPY scripts/bitbucket-clone.sh scripts/inject-profile-env.sh scripts/sync-profile-skills.sh \
    scripts/cursor-bitbucket-review.sh scripts/bitbucket-pr-info.mjs \
    scripts/docker-gateway-start.sh scripts/setup-host-ssh.sh scripts/bitbucket-git-env.sh /opt/hermes/
RUN chmod +x /opt/hermes/*.sh

# Host SSH keys: copy from read-only mount into /opt/data/.ssh (hermes-readable)
COPY scripts/cont-init-setup-ssh.sh /etc/cont-init.d/01b-setup-host-ssh
RUN chmod +x /etc/cont-init.d/01b-setup-host-ssh

# Single foreground gateway: block s6 reconcile from competing with CMD
COPY scripts/cont-init-no-supervise.sh /etc/cont-init.d/01a-gateway-no-supervise
COPY scripts/cont-init-no-supervise.sh /etc/cont-init.d/03a-gateway-no-supervise
RUN chmod +x /etc/cont-init.d/01a-gateway-no-supervise /etc/cont-init.d/03a-gateway-no-supervise

# Copy engineering platform configuration
COPY profiles/ /home/hermes/.hermes/profiles/
COPY skills/ /home/hermes/.hermes/skills/
COPY SOUL.md /home/hermes/.hermes/SOUL.md
COPY AGENTS.md /home/hermes/.hermes/AGENTS.md

# Create profile directories
RUN for profile in architect frontend backend devops qa researcher documenter reviewer; do \
        mkdir -p /home/hermes/.hermes/profiles/$profile; \
        cp /home/hermes/.hermes/SOUL.md /home/hermes/.hermes/profiles/$profile/SOUL.md; \
        cp /home/hermes/.hermes/skills/* /home/hermes/.hermes/profiles/$profile/skills/ 2>/dev/null || true; \
    done

USER hermes

EXPOSE 8443

CMD ["hermes", "gateway", "start"]
