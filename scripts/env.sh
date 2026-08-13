#!/usr/bin/env bash
# Makes this checkout publish on ports that can't collide. Meant to be sourced.
#
# Main repo  → docker-compose.yml as committed: fixed 3000/5432, what the team expects.
# Worktree   → generates a docker-compose.override.yml that maps the container ports
#              with no host side, so Docker assigns free host ports at bind time.
#              Nothing to allocate, nothing to persist, nothing to race.
#
# Compose merges docker-compose.override.yml automatically, so this holds for any
# bare `docker compose ...` run in the directory — not just for these scripts.
#
# There's no project name here — compose derives it from the directory, and every
# worktree already lives in its own.
#
# After sourcing: IS_WORKTREE, published_port()

# Anchor on this file's location, not the CWD — otherwise one worktree's script
# invoked from another's directory would resolve to the wrong git dir.
cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.."
cd "$(git rev-parse --show-toplevel)"

# The only difference between the main repo and a worktree: in a worktree the
# private git dir (.git/worktrees/<name>) differs from the common one.
if [ "$(git rev-parse --absolute-git-dir)" != "$(cd "$(git rev-parse --git-common-dir)" && pwd)" ]; then
  IS_WORKTREE=1
  if [ ! -f docker-compose.override.yml ]; then
    # !override replaces the ports list. Without it compose *appends*, and the
    # committed "3000:3000" would still be published alongside. Needs Compose >= 2.24.
    cat > docker-compose.override.yml <<'YAML'
# Generated per worktree, gitignored. Publishes on Docker-assigned host ports.
services:
  app:
    ports: !override
      - "3000"
  db:
    ports: !override
      - "5432"
YAML
  fi
else
  IS_WORKTREE=0
fi

# Ports are chosen at bind time, so ask Docker instead of tracking them anywhere.
published_port() { docker compose port "$1" "$2" | awk -F: '{print $NF}'; }
