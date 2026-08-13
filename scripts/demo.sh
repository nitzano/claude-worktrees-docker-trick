#!/usr/bin/env bash
# הדגמה מקצה לקצה: יוצר כמה worktrees ומראה שכל אחד מקבל סביבה נפרדת.
#
#   ./scripts/demo.sh          # 3 סביבות
#   ./scripts/demo.sh 5        # 5 סביבות
#   KEEP=1 ./scripts/demo.sh   # לא לנקות בסוף (כדי לשחק עם זה ידנית)
#
# בלי Docker מותקן — הדמו עדיין מריץ את כל לוגיקת הבידוד (שם פרויקט + פורטים)
# ורק מדלג על ההרמה עצמה.
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
ROOT="$PWD"
COUNT="${1:-3}"
WT_ROOT="$(dirname "$ROOT")/$(basename "$ROOT")-worktrees"
HAS_DOCKER=0
docker info >/dev/null 2>&1 && HAS_DOCKER=1

names=()
for i in $(seq 1 "$COUNT"); do names+=("feature-$i"); done

cleanup() {
  [ "${KEEP:-0}" = "1" ] && { echo "↩︎  KEEP=1 — ה-worktrees נשארו ב-$WT_ROOT"; return; }
  echo
  echo "── ניקוי ──"
  for name in "${names[@]}"; do
    wt="$WT_ROOT/$name"
    [ -d "$wt" ] || continue
    [ "$HAS_DOCKER" = "1" ] && (cd "$wt" && ./scripts/dev-down.sh >/dev/null 2>&1 || true)
    git -C "$ROOT" worktree remove --force "$wt" >/dev/null 2>&1 || true
    git -C "$ROOT" branch -D "$name" >/dev/null 2>&1 || true
  done
  rmdir "$WT_ROOT" 2>/dev/null || true
  echo "✓ הכל נוקה."
}
trap cleanup EXIT

echo "── יוצר $COUNT worktrees ──"
for name in "${names[@]}"; do
  git worktree add -b "$name" "$WT_ROOT/$name" >/dev/null
  # Claude Code עושה את זה לבד לפי .worktreeinclude; כאן מדמים ידנית.
  [ -f "$ROOT/.env" ] && cp "$ROOT/.env" "$WT_ROOT/$name/.env"
  echo "  ✓ $name"
done

echo
printf '%-28s %-22s %-8s %-8s\n' "WORKTREE" "COMPOSE_PROJECT_NAME" "APP" "DB"
printf '%-28s %-22s %-8s %-8s\n' "----------------------------" "----------------------" "--------" "--------"

# הריפו הראשי — ברירת המחדל שכולם בצוות רגילים אליה
( . "$ROOT/scripts/env.sh"
  printf '%-28s %-22s %-8s %-8s\n' "(main repo)" "$COMPOSE_PROJECT_NAME" "$APP_PORT" "$DB_PORT" )

for name in "${names[@]}"; do
  ( . "$WT_ROOT/$name/scripts/env.sh"
    printf '%-28s %-22s %-8s %-8s\n' "$name" "$COMPOSE_PROJECT_NAME" "$APP_PORT" "$DB_PORT" )
done

if [ "$HAS_DOCKER" = "0" ]; then
  echo
  echo "⚠️  Docker לא זמין — מדלג על ההרמה בפועל."
  echo "    עם Docker, הדמו היה מריץ dev-up.sh בכל worktree ו-curl לכל אחד."
  exit 0
fi

echo
echo "── מרים את כל הסביבות ──"
for name in "${names[@]}"; do
  (cd "$WT_ROOT/$name" && ./scripts/dev-up.sh)
done

echo
echo "── בודק שכל סביבה עונה על הפורט שלה ──"
for name in "${names[@]}"; do
  port=$(grep '^APP_PORT=' "$WT_ROOT/$name/.env.ports" | cut -d= -f2)
  echo "  $name → localhost:$port"
  curl -s "http://localhost:$port/" | sed 's/^/    /'
done

echo
echo "── קונטיינרים שרצים עכשיו ──"
docker compose ls
