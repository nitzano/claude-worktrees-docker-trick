#!/usr/bin/env bash
# End-to-end demo: creates a few worktrees and shows each one getting its own environment.
#
#   ./scripts/demo.sh          # 3 environments
#   ./scripts/demo.sh 5        # 5 environments
#   KEEP=1 ./scripts/demo.sh   # skip cleanup, to poke at them by hand
#
# Without Docker installed the demo still runs the whole isolation logic
# (project name + ports) and only skips bringing the containers up.
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
  [ "${KEEP:-0}" = "1" ] && { echo "↩︎  KEEP=1 — worktrees left in $WT_ROOT"; return; }
  echo
  echo "── cleanup ──"
  for name in "${names[@]}"; do
    wt="$WT_ROOT/$name"
    [ -d "$wt" ] || continue
    [ "$HAS_DOCKER" = "1" ] && (cd "$wt" && ./scripts/dev-down.sh >/dev/null 2>&1 || true)
    git -C "$ROOT" worktree remove --force "$wt" >/dev/null 2>&1 || true
    git -C "$ROOT" branch -D "$name" >/dev/null 2>&1 || true
  done
  rmdir "$WT_ROOT" 2>/dev/null || true
  echo "✓ all cleaned up."
}
trap cleanup EXIT

echo "── creating $COUNT worktrees ──"
for name in "${names[@]}"; do
  git worktree add -b "$name" "$WT_ROOT/$name" >/dev/null
  # Claude Code does this itself from .worktreeinclude; here we simulate it.
  [ -f "$ROOT/.env" ] && cp "$ROOT/.env" "$WT_ROOT/$name/.env"
  echo "  ✓ $name"
done

echo
printf '%-28s %-22s %-8s %-8s\n' "WORKTREE" "COMPOSE_PROJECT_NAME" "APP" "DB"
printf '%-28s %-22s %-8s %-8s\n' "----------------------------" "----------------------" "--------" "--------"

# The main repo — the defaults the rest of the team is used to
( . "$ROOT/scripts/env.sh"
  printf '%-28s %-22s %-8s %-8s\n' "(main repo)" "$COMPOSE_PROJECT_NAME" "$APP_PORT" "$DB_PORT" )

for name in "${names[@]}"; do
  ( . "$WT_ROOT/$name/scripts/env.sh"
    printf '%-28s %-22s %-8s %-8s\n' "$name" "$COMPOSE_PROJECT_NAME" "$APP_PORT" "$DB_PORT" )
done

if [ "$HAS_DOCKER" = "0" ]; then
  echo
  echo "⚠️  Docker unavailable — skipping the actual bring-up."
  echo "    With Docker, the demo would run dev-up.sh in each worktree and curl each one."
  exit 0
fi

echo
echo "── bringing every environment up ──"
for name in "${names[@]}"; do
  (cd "$WT_ROOT/$name" && ./scripts/dev-up.sh)
done

echo
echo "── checking each environment answers on its own port ──"
for name in "${names[@]}"; do
  port=$(grep '^APP_PORT=' "$WT_ROOT/$name/.env.ports" | cut -d= -f2)
  echo "  $name → localhost:$port"
  curl -s "http://localhost:$port/" | sed 's/^/    /'
done

echo
echo "── running environments ──"
docker compose ls
