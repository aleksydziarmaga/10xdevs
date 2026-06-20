# Repository Guidelines

This repository is an Astro 6 SSR starter for Cloudflare Workers with React islands, Tailwind 4, and Supabase auth. Use this file for repo-specific execution and review rules; use deeper references like @README.md, @CLAUDE.md, and @src/ for implementation detail.

## Hard Rules for Agents

- Keep Supabase credentials server-only: read `SUPABASE_URL` and `SUPABASE_KEY` via `astro:env/server` as in @src/lib/supabase.ts and @astro.config.mjs.
- Preserve SSR behavior (`output: "server"` in @astro.config.mjs); API changes belong under @src/pages/api/.
- For className composition, use `cn()` from @src/lib/utils.ts instead of manual string concatenation.
- Use the path alias from @tsconfig.json: import app code via `@/*` (for example `@/lib/supabase`).
- Do not bypass local quality gates: pre-commit runs `npx lint-staged` from @.husky/pre-commit and `lint-staged` rules in @package.json.

## Build, Test, and Development Commands

- `npm run dev` — local Astro dev server.
- `npm run build` — production build for Cloudflare adapter.
- `npm run preview` — serve built output.
- `npm run lint` — ESLint across the repo.
- `npm run lint:fix` — ESLint auto-fixes.
- `npm run format` — Prettier formatting pass.

## Project Structure & Module Organization

- @src/pages/ contains routes; auth UI is in @src/pages/auth/, and auth APIs are in @src/pages/api/auth/.
- @src/lib/ contains shared runtime helpers (Supabase client, utilities, environment checks).
- @src/components/ contains UI primitives and components.
- @supabase/ stores local Supabase config/migrations; @public/ contains static assets.
- Deployment/runtime config lives in @wrangler.jsonc and @astro.config.mjs.

## Coding Style & Naming Conventions

Formatting is enforced by @.prettierrc.json (2-space indent, semicolons, double quotes, width 120). Lint/type rules are in @eslint.config.js with type-aware TypeScript + Astro + React checks. Follow existing file naming and route patterns in @src/pages/ and keep helper logic in @src/lib/.

## Testing & Validation Guidelines

No dedicated test runner is configured in @package.json yet. Treat `npm run lint` and `npm run build` as the required validation gate for every change.

## Commit & Pull Request Guidelines

Recent history (`git log --oneline -n 30`) uses short, imperative, lowercase subjects (for example: `add ...`, `run ...`, `get ...`). Match that style and keep each commit scoped to one concern. Open PRs against the configured remote `https://github.com/aleksydziarmaga/10xdevs.git`.

## Security & Configuration Tips

Copy @.env.example to local env files and keep secrets out of source control. For local Cloudflare workerd development, keep runtime secrets in `.dev.vars` as described in @README.md.
