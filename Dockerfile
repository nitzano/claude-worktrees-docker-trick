# The image holds *only* the dependencies. Code comes in as a bind mount at runtime.
# That's why a new worktree isn't a new build — it's the same image with a
# different directory mapped into it.
FROM node:22-alpine

# pnpm ships with Node via corepack; the exact version comes from package.json
RUN corepack enable

WORKDIR /app

# Manifests only, so this layer stays cached as long as dependencies don't change
COPY package.json pnpm-lock.yaml* ./
RUN pnpm install

# Initial copy of the code so the image also runs without a mount (e.g. in CI).
# In dev the bind mount shadows it anyway.
COPY . .

EXPOSE 3000
CMD ["pnpm", "dev"]
