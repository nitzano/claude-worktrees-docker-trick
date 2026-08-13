# Ten parallel dev environments — demo

A minimal repo (Node + Postgres) demonstrating the setup from the post: every git
worktree gets its own Docker environment, with free ports and a separate DB, with
no rebuild and no collisions.

## Quick start

```bash
cp .env.example .env
./scripts/demo.sh 3     # creates 3 worktrees, brings each environment up, cleans up after
```

`KEEP=1 ./scripts/demo.sh` leaves the worktrees around to poke at by hand.

## What's here

| File | Role |
| --- | --- |
| [docker-compose.yml](docker-compose.yml) | ports as variables with defaults; code mounted in |
| [Dockerfile](Dockerfile) | dependencies only — built once |
| [scripts/env.sh](scripts/env.sh) | the core: worktree detection, port allocation, `COMPOSE_PROJECT_NAME` |
| [scripts/dev-up.sh](scripts/dev-up.sh) | idempotent bring-up + seeding from a dump |
| [scripts/dev-down.sh](scripts/dev-down.sh) | tears down this environment only |
| [scripts/demo.sh](scripts/demo.sh) | the end-to-end demo |
| [CLAUDE.md](CLAUDE.md) | the wiring for Claude — reaches every worktree via git |
| [.claude/settings.json](.claude/settings.json) | `SessionStart` hook that brings the environment up on its own |
| [.worktreeinclude](.worktreeinclude) | non-git files that still need to reach a worktree |

## Three things that are easy to miss

1. **A distinct `COMPOSE_PROJECT_NAME` per worktree.** Without it compose treats them
   all as the same environment and tears down one container as you bring up the next.
2. **Only the host-side ports vary.** Inside the compose network the app still talks
   to `db:5432`, so no internal config needs to know which environment it's in.
3. **`--env-file` disables the automatic `.env` load.** That's why
   [scripts/env.sh](scripts/env.sh) passes both when a `.env` exists.
