#!/usr/bin/env bash
# docker-entrypoint.sh
set -euo pipefail

: "${HERMES_HOME:=/data/hermes}"
INSTALL_DIR=/app

mkdir -p \
  "$HERMES_HOME"/cron \
  "$HERMES_HOME"/sessions \
  "$HERMES_HOME"/logs \
  "$HERMES_HOME"/memories \
  "$HERMES_HOME"/skills \
  "$HERMES_HOME"/pairing \
  "$HERMES_HOME"/hooks \
  "$HERMES_HOME"/image_cache \
  "$HERMES_HOME"/audio_cache \
  "$HERMES_HOME"/whatsapp/session

if [ ! -f "$HERMES_HOME/config.yaml" ]; then
  cp "$INSTALL_DIR/cli-config.yaml.example" "$HERMES_HOME/config.yaml"
fi

if [ ! -f "$HERMES_HOME/.env" ]; then
  if [ -f "$INSTALL_DIR/.env.example" ]; then
    cp "$INSTALL_DIR/.env.example" "$HERMES_HOME/.env"
  else
    touch "$HERMES_HOME/.env"
  fi
fi

if [ ! -f "$HERMES_HOME/SOUL.md" ] && [ -f "$INSTALL_DIR/docker/SOUL.md" ]; then
  cp "$INSTALL_DIR/docker/SOUL.md" "$HERMES_HOME/SOUL.md"
fi

if [ -d "$INSTALL_DIR/skills" ] && [ -f "$INSTALL_DIR/tools/skills_sync.py" ]; then
  python3 "$INSTALL_DIR/tools/skills_sync.py"
fi

if [ -n "${MESSAGING_CWD:-}" ]; then
  mkdir -p "$MESSAGING_CWD"
fi

exec "$@"
