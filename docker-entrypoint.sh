#!/usr/bin/env bash
# docker-entrypoint.sh
set -euo pipefail

: "${HERMES_HOME:=/data/hermes}"

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
  cp /app/cli-config.yaml.example "$HERMES_HOME/config.yaml"
fi

if [ ! -f "$HERMES_HOME/.env" ]; then
  touch "$HERMES_HOME/.env"
fi

if [ -n "${MESSAGING_CWD:-}" ]; then
  mkdir -p "$MESSAGING_CWD"
fi

exec "$@"
