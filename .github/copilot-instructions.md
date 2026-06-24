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

## 10xDevs AI Toolkit - Module 2, Lesson 2

Turn one roadmap item into the first implementation cycle with the **change planning chain**:

```
/10x-roadmap -> /10x-new -> /10x-plan -> /10x-plan-review -> /10x-implement
```

`/10x-new`, `/10x-plan`, `/10x-plan-review`, and `/10x-implement` are the lesson focus. `/10x-frame` and `/10x-research` are not required rituals here; they are escalation paths introduced in the next lesson.

### Task Router - Where to start

| Skill | Use it when |
| --- | --- |
| **Change setup (lesson focus)** | |
| `/10x-new <change-id>` | You selected a roadmap item and need a stable change folder. Creates `context/changes/<change-id>/change.md` so planning, implementation, progress, commits, and later review all share one identity. Use AFTER roadmap selection, BEFORE `/10x-plan`. |
| **Planning (lesson focus)** | |
| `/10x-plan <change-id>` | You have a change folder and need a reviewable implementation plan. Reads roadmap context, foundation docs, codebase evidence, and any existing change notes; writes `plan.md` and `plan-brief.md` with phases, file contracts, success criteria, and `## Progress`. |
| **Plan readiness (lesson focus)** | |
| `/10x-plan-review <change-id>` | You have `plan.md` and need a light pre-code readiness check. Use it to catch missing end state, weak contracts, malformed progress, scope drift, or blind spots before code changes begin. |
| **Implementation (lesson focus)** | |
| `/10x-implement <change-id> phase <n>` | You have an approved plan and want to execute one phase with verification, manual gate, commit ritual, and SHA write-back to `## Progress`. |
| **Lifecycle closure** | |
| `/10x-archive <change-id>` | A change is merged or intentionally closed. Move it out of active `context/changes/` into archive state. |

### How the chain hands off

- `/10x-new` creates the durable change identity.
- `/10x-plan` turns that identity into an implementation contract.
- `/10x-plan-review` checks the plan before the agent mutates code.
- `/10x-implement` executes one planned phase, verifies, asks for manual confirmation when needed, commits, and records progress.

### Lesson boundaries

- Plan is the default router after roadmap selection. Start with `/10x-plan` unless the problem is unclear or external evidence is blocking.
- Do not run `/10x-frame + /10x-research` as ceremony for every change.
- Do not turn this lesson into a full end-to-end product build. A checkpoint with a planned and partially or fully implemented stream is valid.
- Code review of the implemented diff belongs to Lesson 3 via `/10x-impl-review`.
- Lifecycle closure via `/10x-archive` after a change is merged or intentionally closed.

### Paths used by this lesson

- `context/foundation/roadmap.md` - upstream roadmap
- `context/changes/<change-id>/change.md` - change identity
- `context/changes/<change-id>/plan.md` - implementation contract
- `context/changes/<change-id>/plan-brief.md` - compressed handoff
- `context/foundation/lessons.md` - recurring rules and pitfalls
- `docs/reference/contract-surfaces.md` - load-bearing names registry

Skills must not write to `context/archive/`. Archived changes are immutable; if a resolved target path starts with `context/archive/`, abort with: "This change is archived. Open a new change with `/10x-new` instead."

<!-- END @przeprogramowani/10x-cli -->
