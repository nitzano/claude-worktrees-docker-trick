#!/usr/bin/env bash
# מרים את סביבת הפיתוח של ה-worktree הנוכחי. אידמפוטנטי — מותר להריץ שוב.
set -euo pipefail

. "$(dirname "$0")/env.sh"

if ! docker info >/dev/null 2>&1; then
  echo "❌ Docker לא זמין. הפעל את Docker Desktop (ו-WSL integration אם רלוונטי)." >&2
  exit 1
fi

# המסלול האיטי רץ פעם אחת בחיים; אחריו רק up.
docker image inspect myapp-dev:latest >/dev/null 2>&1 || docker compose "${ENV_FILE_ARGS[@]}" build

docker compose "${ENV_FILE_ARGS[@]}" up -d --no-build --wait

# ווליום עם שם מקבל prefix של שם הפרויקט, כלומר כל worktree מקבל DB ריק.
# סידינג מדאמפ = שניות במקום מיגרציות מאפס.
docker compose "${ENV_FILE_ARGS[@]}" exec -T db psql -q -U dev -d app < seed.sql

echo "✅ הסביבה למעלה [${COMPOSE_PROJECT_NAME}] — APP: http://localhost:${APP_PORT} | DB: localhost:${DB_PORT}"
