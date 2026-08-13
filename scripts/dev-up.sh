#!/usr/bin/env bash
# Brings up this worktree's dev environment. Idempotent — safe to re-run.
set -euo pipefail

. "$(dirname "$0")/env.sh"

if ! docker info >/dev/null 2>&1; then
  echo "❌ Docker unavailable. Start Docker Desktop (and WSL integration if relevant)." >&2
  exit 1
fi

# The slow path runs once in a lifetime; after that it's just `up`.
docker image inspect myapp-dev:latest >/dev/null 2>&1 || docker compose "${ENV_FILE_ARGS[@]}" build

docker compose "${ENV_FILE_ARGS[@]}" up -d --no-build --wait

# Named volumes get the project name as a prefix, so every worktree starts with an
# empty DB. Seeding from a dump takes seconds instead of migrating from scratch.
docker compose "${ENV_FILE_ARGS[@]}" exec -T db psql -q -U dev -d app < seed.sql

echo "✅ environment up [${COMPOSE_PROJECT_NAME}] — APP: http://localhost:${APP_PORT} | DB: localhost:${DB_PORT}"
