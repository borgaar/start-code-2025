# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a T3 Stack application using Next.js 15 with App Router, tRPC, Prisma, and Tailwind CSS. The stack emphasizes type-safety across the entire application from database to frontend.

## Development Commands

**Setup:**
```bash
pnpm install                    # Install dependencies (auto-runs prisma generate)
docker compose up -d            # Start PostgreSQL database
pnpm db:push                    # Push schema to database
```

**Development:**
```bash
pnpm dev                        # Start dev server with Turbopack
pnpm db:studio                  # Open Prisma Studio (database GUI)
```

**Code Quality:**
```bash
pnpm check                      # Run Biome linter/formatter checks
pnpm check:write                # Auto-fix safe issues
pnpm check:unsafe               # Auto-fix including unsafe changes
pnpm typecheck                  # Run TypeScript type checking
```

**Database:**
```bash
pnpm db:generate                # Create and apply new migration
pnpm db:migrate                 # Deploy migrations (production)
pnpm db:push                    # Push schema without migration (dev)
```

**Build & Deploy:**
```bash
pnpm build                      # Build for production
pnpm start                      # Start production server
pnpm preview                    # Build and start production server
```

## Architecture

**tRPC Setup:**
- `src/server/api/trpc.ts` - Core tRPC configuration, context creation, and procedure definitions. Includes timing middleware with artificial delay in development.
- `src/server/api/root.ts` - Main router (`appRouter`) where all sub-routers are registered. Export point for `AppRouter` type.
- `src/server/api/routers/` - Individual router modules (e.g., `post.ts`). Create new routers here and register in `root.ts`.
- `src/trpc/react.tsx` - Client-side tRPC setup with React Query integration. Export `api` object for client components.
- `src/trpc/server.ts` - Server-side tRPC caller for use in Server Components and API routes.
- `src/app/api/trpc/[trpc]/route.ts` - HTTP handler for tRPC API endpoints.

**Data Flow:**
1. Define procedures in `src/server/api/routers/*.ts` using `publicProcedure` from `trpc.ts`
2. Register routers in `src/server/api/root.ts`
3. Client components use `api.routerName.procedureName.useQuery()` from `src/trpc/react.tsx`
4. Server components use `await api.routerName.procedureName()` from `src/trpc/server.ts`

**Environment Variables:**
- Validated via `src/env.js` using `@t3-oss/env-nextjs` and Zod
- Server variables: `DATABASE_URL`, `NODE_ENV`
- Client variables must be prefixed with `NEXT_PUBLIC_`
- Add new variables to both schema and `runtimeEnv` in `env.js`

**Database:**
- PostgreSQL via Docker Compose (user: postgres, password: password, db: db, port: 5432)
- Schema defined in `prisma/schema.prisma`
- Client initialized in `src/server/db.ts`
- Use `pnpm db:push` during development, `pnpm db:generate` for migrations

**Code Standards:**
- Biome handles linting and formatting (configured in `biome.jsonc`)
- Package manager: pnpm
- TypeScript strict mode enabled
