# worktree-docker-demo

A small Node app + Postgres, running in an isolated environment per worktree.

## Dev environment

- Don't run servers or the DB directly (`pnpm dev`, `docker run`). Bring the
  environment up with `./scripts/dev-up.sh`.
- The script is idempotent — re-run it if you're unsure whether the environment is up.
- **The ports here are not 3000/5432.** They live in `.env.ports`. Read them from
  there before any curl or browser check.
- Logs: `docker compose logs -f app`
- If `up` fails on a missing dependency, that's `docker compose build`, not
  `pnpm install` on the host.
- Tear down when done: `./scripts/dev-down.sh` (only affects this worktree).
