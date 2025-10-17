FROM node:22-alpine AS base

FROM base AS builder

WORKDIR /app

RUN npm install -g pnpm

COPY pnpm-lock.yaml ./
COPY package.json ./

RUN pnpm i --frozen-lockfile

COPY . .

RUN pnpm dlx prisma generate

RUN pnpm build

RUN pnpm prune --prod

FROM base AS runner

WORKDIR /app

# Don't run production as root
RUN addgroup --system --gid 1001 hono
RUN adduser --system --uid 1001 hono

USER hono

ENV NODE_ENV=production

COPY --from=builder --chown=hono:hono /app/dist ./dist
COPY --from=builder --chown=hono:hono /app/node_modules ./node_modules

ENTRYPOINT ["pnpm", "start"]
