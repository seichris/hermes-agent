FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    HERMES_HOME=/data/hermes \
    VIRTUAL_ENV=/opt/venv \
    PATH="/opt/venv/bin:$PATH"

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash ca-certificates curl git build-essential python3-dev libffi-dev \
    ripgrep ffmpeg \
    && rm -rf /var/lib/apt/lists/*

RUN python -m venv "$VIRTUAL_ENV" \
    && "$VIRTUAL_ENV/bin/pip" install --upgrade pip setuptools wheel

WORKDIR /app
COPY . .

# Hermes needs the mini-swe-agent submodule for terminal execution.
RUN test -d mini-swe-agent || (echo "mini-swe-agent submodule missing; enable Git submodules in Coolify" && exit 1) \
    && pip install -e ".[messaging,cron,cli,pty,mcp]" \
    && pip install -e "./mini-swe-agent"

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["hermes", "gateway"]
