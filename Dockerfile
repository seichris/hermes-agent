FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    HERMES_HOME=/data/hermes \
    VIRTUAL_ENV=/opt/venv \
    PATH="/opt/venv/bin:$PATH"

ARG INSTALL_BROWSER_STACK=false
ARG INSTALL_WHATSAPP_BRIDGE=false

# Install system dependencies in one layer, clear APT cache.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    bash ca-certificates curl git build-essential python3-dev libffi-dev \
    ripgrep ffmpeg \
    && if [ "$INSTALL_BROWSER_STACK" = "true" ] || [ "$INSTALL_WHATSAPP_BRIDGE" = "true" ]; then \
         apt-get install -y --no-install-recommends nodejs npm; \
       fi \
    && rm -rf /var/lib/apt/lists/*

RUN python -m venv "$VIRTUAL_ENV" \
    && "$VIRTUAL_ENV/bin/pip" install --upgrade pip setuptools wheel

WORKDIR /app
COPY . .

ARG MINI_SWE_AGENT_REPO=https://github.com/SWE-agent/mini-swe-agent
ARG MINI_SWE_AGENT_REF=07aa6a738556e44b30d7b5c3bbd5063dac871d25

# Hermes needs the mini-swe-agent submodule contents for terminal execution.
# Some deploy platforms clone the repo without hydrating submodules, leaving an
# empty placeholder directory behind. If that happens, fetch the pinned commit.
RUN if [ ! -f mini-swe-agent/pyproject.toml ]; then \
        echo "mini-swe-agent submodule missing; cloning pinned fallback" >&2; \
        rm -rf mini-swe-agent; \
        git clone "$MINI_SWE_AGENT_REPO" mini-swe-agent; \
        git -C mini-swe-agent checkout "$MINI_SWE_AGENT_REF"; \
    fi \
    && pip install -e ".[messaging,cron,cli,pty,mcp]" \
    && pip install -e "./mini-swe-agent" \
    && if [ "$INSTALL_BROWSER_STACK" = "true" ]; then \
         npm install && npx playwright install --with-deps chromium; \
       fi \
    && if [ "$INSTALL_WHATSAPP_BRIDGE" = "true" ]; then \
         npm --prefix scripts/whatsapp-bridge install; \
       fi

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["hermes", "gateway"]
