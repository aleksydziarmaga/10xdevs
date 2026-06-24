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

## 10xDevs AI Toolkit - Module 2, Lesson 3

Review AI-generated code before merge with the **implementation review chain**:

```
/10x-implement -> /10x-impl-review -> triage -> (/10x-lesson | fix | skip | disagree)
```

`/10x-impl-review` is the lesson focus. Review is a quality gate, not an instruction to fix every finding.

### Task Router - Where to start

| Skill | Use it when |
| --- | --- |
| **Code review (lesson focus)** | |
| `/10x-impl-review <change-id>` | You have implemented code and want a structured review before merge. The skill checks plan adherence, scope discipline, safety and quality, architecture, pattern consistency, and success criteria, then presents findings for triage. |
| **Recurring lesson outcome** | |
| `/10x-lesson` | A finding reveals a recurring project rule or agent failure pattern. Record it in `context/foundation/lessons.md` instead of treating it as a one-off note. |

### Triage discipline

- Severity says how bad the finding is. Impact says how much the decision matters now.
- Valid outcomes: fix now, fix differently, skip, accept as risk, record as recurring rule (`/10x-lesson`), disagree.
- Fix critical findings. Do not burn hours on low-impact observations just because the agent found them.
- Conscious skipping of low-impact findings is a valid review outcome, not negligence.
- If you disagree with a finding, record why. Wrong agent reasoning is also signal.

### Review boundaries

- This lesson reviews implemented code. It does not create the plan, execute new phases, or teach CI review.
- Testing strategy and quality gates are introduced in Module 3.
- Do not use `/10x-contract` as a triage outcome in this lesson.

### Paths used by this lesson

- `context/changes/<change-id>/plan.md` - expected implementation contract
- `context/changes/<change-id>/reviews/` - review output
- `context/foundation/lessons.md` - recurring lessons

Skills must not write to `context/archive/`. Archived changes are immutable; if a resolved target path starts with `context/archive/`, abort with: "This change is archived. Open a new change with `/10x-new` instead."

<!-- END @przeprogramowani/10x-cli -->
