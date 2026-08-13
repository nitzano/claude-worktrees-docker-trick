# worktree-docker-demo

A small Node app + Postgres, running in an isolated environment per worktree.

## Dev environment

- Don't run servers or the DB directly (`pnpm dev`, `docker run`). Bring the
  environment up with `./scripts/dev-up.sh`.
- The script is idempotent — re-run it if you're unsure whether the environment is up.
- **The ports here are not 3000/5432.** Docker assigns them, so ask Docker:
  `docker compose port app 3000`. Do that before any curl or browser check —
  `dev-up.sh` also prints them when it finishes.
- **Run `source scripts/env.sh` before any ad-hoc `docker compose` command.** It sets
  `COMPOSE_FILE` so the worktree's port overlay is applied; without it compose falls
  back to the fixed 3000/5432 and collides with whatever is already there.
- Logs: `source scripts/env.sh && docker compose logs -f app`
- If `up` fails on a missing dependency, that's `docker compose build`, not
  `pnpm install` on the host.
- Tear down when done: `./scripts/dev-down.sh` (only affects this worktree).
