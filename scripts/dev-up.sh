#!/usr/bin/env bash
# Brings up this worktree's dev environment. Idempotent — safe to re-run.
set -euo pipefail

. "$(dirname "$0")/env.sh"

if ! docker info >/dev/null 2>&1; then
  echo "❌ Docker unavailable. Start Docker Desktop (and WSL integration if relevant)." >&2
  exit 1
fi

# The slow path runs once in a lifetime; after that it's just `up`.
docker image inspect myapp-dev:latest >/dev/null 2>&1 || docker compose build

docker compose up -d --no-build --wait

# Named volumes are prefixed with the project name, so every worktree starts with an
# empty DB. Seeding from a dump takes seconds instead of migrating from scratch.
docker compose exec -T db psql -q -U dev -d app < seed.sql

# This line is the point: SessionStart hook stdout lands in Claude's context, so the
# agent reads the real port instead of assuming 3000.
echo "✅ environment up [$(basename "$PWD")] — APP: http://localhost:$(published_port app 3000) | DB: localhost:$(published_port db 5432)"
