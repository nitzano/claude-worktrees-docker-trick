#!/usr/bin/env bash
# Resolves this worktree's environment: which ports it publishes on.
# Meant to be sourced, so dev-up, dev-down and the demo all see the same values.
#
# Note there's no project name here — compose derives it from the directory name,
# and every worktree already lives in its own directory.
#
# After sourcing: APP_PORT, DB_PORT, IS_WORKTREE, ENV_FILE_ARGS

# Anchor on this file's location, not the CWD — otherwise one worktree's script
# invoked from another's directory would resolve to the wrong git dir.
cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.."
cd "$(git rev-parse --show-toplevel)"

free_port() {
  python3 -c 'import socket;s=socket.socket();s.bind(("",0));print(s.getsockname()[1]);s.close()'
}

# The only difference between the main repo and a worktree: in a worktree the
# private git dir (.git/worktrees/<name>) differs from the common one.
if [ "$(git rev-parse --absolute-git-dir)" != "$(cd "$(git rev-parse --git-common-dir)" && pwd)" ]; then
  IS_WORKTREE=1
  # Ports are drawn once and persisted, so the environment's address stays stable
  # for as long as the worktree lives.
  if [ ! -f .env.ports ]; then
    printf 'APP_PORT=%s\nDB_PORT=%s\n' "$(free_port)" "$(free_port)" > .env.ports
  fi
else
  IS_WORKTREE=0
  # Main repo: the fixed ports everyone on the team already expects.
  printf 'APP_PORT=3000\nDB_PORT=5432\n' > .env.ports
fi

set -a
. ./.env.ports
set +a

# Gotcha: --env-file disables the automatic .env load. Pass both when .env exists.
# (A full if, not &&: a sourced file must end successfully or set -e kills the caller.)
if [ -f .env ]; then
  ENV_FILE_ARGS=(--env-file .env --env-file .env.ports)
else
  ENV_FILE_ARGS=(--env-file .env.ports)
fi
