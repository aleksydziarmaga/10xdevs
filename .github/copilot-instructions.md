# Copilot Instructions

Use this file as the Copilot-specific companion to `AGENTS.md` and `CLAUDE.md`.

## Build, lint, and validation commands

- `npm run dev` — run Astro dev server (Cloudflare workerd runtime).
- `npm run build` — production build (SSR via `@astrojs/cloudflare`).
- `npm run preview` — preview built output.
- `npm run lint` — run ESLint for the whole repo.
- `npm run lint -- src/path/to/file.tsx` — lint a single file.
- `npm run lint:fix` — ESLint autofix.
- `npm run format` — Prettier formatting.

There is currently no test runner configured in `package.json`.

## High-level architecture

- This is an Astro SSR app (`output: "server"` in `astro.config.mjs`) deployed to Cloudflare Workers (`@astrojs/cloudflare` adapter + `wrangler.jsonc`).
- Auth is cookie-based Supabase SSR:
  - `src/lib/supabase.ts` creates the server client from request headers + Astro cookies.
  - `src/pages/api/auth/*.ts` handle sign in/up/out as form POST endpoints.
  - `src/middleware.ts` resolves `context.locals.user` and redirects unauthenticated requests for routes in `PROTECTED_ROUTES`.
  - Protected pages (for example `src/pages/dashboard.astro`) read `Astro.locals.user`.
- Auth UI uses Astro pages with React islands:
  - Pages in `src/pages/auth/*.astro` render shell/layout and mount forms with `client:load`.
  - React form components in `src/components/auth/*` post directly to `/api/auth/*`.
- Runtime configuration status is surfaced globally:
  - `src/lib/config-status.ts` detects missing env configuration.
  - `src/layouts/Layout.astro` shows banner warnings for missing config on every page.

## Key conventions in this repository

- Keep Supabase secrets server-only: use `astro:env/server` (`SUPABASE_URL`, `SUPABASE_KEY`) and do not expose them client-side.
- `createClient` can return `null` when env is missing; all auth API handlers and middleware should guard for that path.
- Auth API endpoints return redirects with `?error=...` query params (not JSON responses); auth pages read `Astro.url.searchParams.get("error")`.
- Use the `@/*` path alias from `tsconfig.json` for app imports.
- For className composition, use `cn()` from `src/lib/utils.ts` (clsx + tailwind-merge), not manual string concatenation.
- Prefer Astro components for non-interactive UI and React only for interactive islands.
- Keep route protection centralized in `src/middleware.ts` by updating `PROTECTED_ROUTES`.
- Pre-commit runs `npx lint-staged` via `.husky/pre-commit`; lint-staged applies `eslint --fix` to `*.{ts,tsx,astro}` and Prettier to `*.{json,css,md}`.

<!-- BEGIN @przeprogramowani/10x-cli -->

## 10xDevs AI Toolkit - Module 2, Lesson 1

Move from sprint-zero setup to project orchestration with the **roadmap chain**:

```
(Module 1 foundation docs) -> /10x-roadmap -> backlog-ready roadmap items
```

`/10x-roadmap` is the lesson focus. `/10x-new` is intentionally introduced in Module 2, Lesson 2, when a selected roadmap item becomes an implementation change folder.

### Task Router - Where to start

| Skill | Use it when |
| --- | --- |
| **Roadmap (lesson focus)** | |
| `/10x-roadmap` | You have `context/foundation/prd.md` and a scaffolded project baseline, and you need a vertical-first MVP roadmap. The skill reads the PRD, inspects the code baseline, uses available foundation docs such as `tech-stack.md`, `infrastructure.md`, and `deploy-plan.md`, then writes `context/foundation/roadmap.md`. Use it BEFORE creating per-change folders or implementation plans. |
| **Re-run upstream if needed** | |
| `/10x-shape` / `/10x-prd` / `/10x-tech-stack-selector` / `/10x-bootstrapper` / `/10x-agents-md` / `/10x-infra-research` | Bundled from Module 1 so foundation contracts can be fixed before roadmap sequencing. If roadmap generation exposes a PRD gap, repair the PRD before pretending the backlog is ready. |

### How the chain hands off

- `/10x-roadmap` bridges product and implementation. It does not choose frameworks, design schemas, or write a per-change implementation plan.
- The output is `context/foundation/roadmap.md`: ordered milestones, vertical slices, bounded foundations, dependencies, unknowns, risk, and backlog handoff fields.
- Roadmap items should receive stable human-readable identifiers in backlog tools. The actual `context/changes/<change-id>/` folder is created in Lesson 2 with `/10x-new`.

### Roadmap boundaries

- Default to vertical slices: user-visible outcomes that cross UI, data, business logic, and integrations.
- Horizontal work is allowed only as a bounded enabler that names the downstream vertical milestone it unlocks.
- Avoid orphan horizontal work such as "build the whole database", "build all API endpoints", or "design the whole UI" before the first user-visible flow.
- Roadmap is not a calendar estimate. Do not invent dates, story points, or sprint velocity unless the user explicitly asks for a separate planning artifact.

### Foundation paths used by this lesson

- `context/foundation/prd.md` - input
- `context/foundation/tech-stack.md` - optional input
- `context/foundation/infrastructure.md` - optional input
- `context/deployment/deploy-plan.md` - optional input
- `context/foundation/roadmap.md` - output
- `context/foundation/lessons.md` - recurring rules and pitfalls
- `docs/reference/contract-surfaces.md` - load-bearing names registry

Skills must not write to `context/archive/`. Archived changes are immutable; if a resolved target path starts with `context/archive/`, abort with: "This change is archived. Open a new change with `/10x-new` instead."

<!-- END @przeprogramowani/10x-cli -->
