#!/usr/bin/env bash
# מוריד את הסביבה של ה-worktree הנוכחי בלבד (כולל הווליום של ה-DB).
set -euo pipefail

. "$(dirname "$0")/env.sh"

docker compose "${ENV_FILE_ARGS[@]}" down -v
echo "🧹 הסביבה [${COMPOSE_PROJECT_NAME}] ירדה."
