#!/usr/bin/env bash
# Tears down this worktree's environment only (including its DB volume).
set -euo pipefail

. "$(dirname "$0")/env.sh"

docker compose "${ENV_FILE_ARGS[@]}" down -v
echo "🧹 environment [$(basename "$PWD")] is down."
