#!/usr/bin/env bash
# Makes this checkout publish on ports that can't collide. Meant to be sourced.
#
# Main repo  → docker-compose.yml alone: fixed 3000/5432, what the team expects.
# Worktree   → docker-compose.worktree.yml layered on top, so Docker assigns free
#              host ports at bind time. Nothing to allocate, persist, or race.
#
# COMPOSE_FILE is read by compose itself, so every `docker compose ...` in a shell
# that sourced this file picks up the overlay — no -f flags to remember.
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
  export COMPOSE_FILE=docker-compose.yml:docker-compose.worktree.yml
else
  IS_WORKTREE=0
fi

# Ports are chosen at bind time, so ask Docker instead of tracking them anywhere.
published_port() { docker compose port "$1" "$2" | awk -F: '{print $NF}'; }
