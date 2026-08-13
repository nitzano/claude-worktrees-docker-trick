#!/usr/bin/env bash
# Tears down this worktree's environment only (including its DB volume).
set -euo pipefail

. "$(dirname "$0")/env.sh"

docker compose down -v
echo "🧹 environment [$(basename "$PWD")] is down."
