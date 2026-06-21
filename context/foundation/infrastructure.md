---
project: HomeWallet
researched_at: 2026-06-21T19:32:36Z
recommended_platform: Cloudflare Workers + Pages
runner_up: Vercel
context_type: mvp
tech_stack:
  language: TypeScript (JS/TS)
  framework: Astro 6 SSR
  runtime: Cloudflare Workers (workerd)
---

## Recommendation

**Deploy on Cloudflare Workers + Pages.**

This option won because it best matches the current Astro Cloudflare adapter setup, keeps deployment flow simple (`npm run build` + `wrangler deploy`), and has the strongest low-traffic cost profile for your MVP. Your answers (cost-sensitive, no persistent-process requirement, external providers OK, single-region acceptable) also favored a serverless platform with deterministic CLI operations and low operational overhead.

## Platform Comparison

| Platform | CLI-first | Managed/Serverless | Agent-readable docs | Stable deploy API | MCP / Integration | Total |
|---|---|---|---|---|---|---|
| Cloudflare Workers + Pages | Pass | Pass | Pass | Pass | Partial | 4.5 |
| Vercel | Pass | Pass | Pass | Pass | Pass | 4.3 |
| Netlify | Pass | Pass | Partial | Pass | Partial | 3.9 |
| Railway | Pass | Partial | Partial | Partial | Pass | 3.5 |
| Render | Pass | Partial | Pass | Pass | Pass | 3.7 |
| Fly.io | Pass | Partial | Pass | Partial | Partial | 3.3 |

Cloudflare Workers + Pages scored highest for this exact stack: no adapter migration, clear CLI lifecycle (`wrangler deploy/tail/rollback`), strong docs (`llms.txt` + open docs repo), and very favorable free-tier economics at MVP request volume. MCP support exists but is still an evolving surface across multiple Cloudflare MCP projects (treated as Partial).  

Vercel is a strong second: excellent CLI/API ergonomics, mature docs, and good free-tier headroom. It loses to Cloudflare here mainly because your project is already configured for Cloudflare SSR runtime, so moving to Vercel would add migration work without a clear MVP benefit under your constraints.  

Netlify is third: solid Astro SSR support and reliable CLI/API deployment, but weaker signals on docs-source openness and less straightforward rollback ergonomics than Cloudflare/Vercel.  

Render offers strong docs/API and official MCP server integration, but Astro SSR requires Node-service setup rather than first-class Astro SSR path, and free-tier cold-start behavior can hurt UX.  

Railway has great DX, WebSocket support, and strong MCP capabilities, but pricing is usage-based (less predictable for strict cost minimization), and rollback is more dashboard-centric than top-ranked options.  

Fly.io is capable and flexible for containers and persistent workloads, but for this MVP it adds container/deployment complexity and weaker low-friction fit than serverless-first options.

### Shortlisted Platforms

#### 1. Cloudflare Workers + Pages (Recommended)

Best fit for the current codebase and deployment model. It preserves the existing Astro Cloudflare runtime path, minimizes migration risk, and offers the strongest cost-to-effort profile for a stateless MVP using external data services.

#### 2. Vercel

Excellent operational DX and automation with strong free tier. It scored close but still requires switching deployment adapter/runtime conventions from the current Cloudflare-centered setup.

#### 3. Netlify

Good balance for Astro SSR and MVP workflows, with solid deploy tooling. It ranked third due to comparatively weaker documentation-source signal and less direct rollback ergonomics.

## Anti-Bias Cross-Check: Cloudflare Workers + Pages

### Devil's Advocate — Weaknesses

1. Runtime mismatch risk: dependencies expecting full Node behavior can fail subtly on workerd.
2. Platform lock-in can grow quickly if Workers-specific services (DO/KV/R2 workflows) become core.
3. Incident debugging can be harder than on a single-region long-running host when behavior differs by runtime edge conditions.
4. Small Wrangler/config drift (assets, bindings, compatibility settings) can break deploys unexpectedly.
5. Data/rollback coupling risk remains: code rollback is fast, but DB migration rollback is still manual.

### Pre-Mortem — How This Could Fail

The team chose Cloudflare because it looked cheapest and matched the starter template, then prioritized shipping over validating runtime compatibility deeply. Early milestones succeeded, but a few dependencies relied on Node-specific behavior and started failing under production conditions that local tests did not reproduce. To keep velocity, the team added piecemeal compatibility fixes and extra config flags, which made the deployment surface harder to reason about. As features expanded, Cloudflare-specific primitives were added for speed, tightening coupling to platform semantics. By month six, product needs shifted toward workflows that would have been simpler on a conventional long-running backend. Migration became painful because build scripts, runtime assumptions, and operational playbooks were now Cloudflare-specific. No single outage caused the failure; instead, the team suffered compounding friction: slower debugging, fragile releases, and rising change cost. What started as a fast MVP platform became a delivery drag because platform constraints were underestimated and long-term portability was not planned early.

### Unknown Unknowns

- `compatibility_date` policy can materially change runtime behavior over time; update cadence must be deliberate.
- Local dev fidelity can still diverge from deployed runtime for some package/runtime edge cases.
- Preview and production environments can drift if bindings/secrets are not managed in lockstep.
- Rollback generally restores code fast, but stateful data changes still need separate migration strategy.
- Platform tooling and docs evolve quickly; stale tutorials can produce incorrect setup for current versions.

## Operational Story

- **Preview deploys**: Use branch/PR preview deployments via Cloudflare Pages or preview environments in Worker workflows; if sensitive, protect previews with Cloudflare Access. Availability can vary for external/forked PR pipelines depending on CI token permissions.
- **Secrets**: Store runtime secrets in Cloudflare Worker/Pages secrets and CI-level GitHub Secrets. Restrict read access to maintainers; rotate with `wrangler secret put` and revoke old values after rollout.
- **Rollback**: Use `wrangler rollback` (Workers) or Pages rollback in dashboard/API. Typical code rollback is minutes; database schema/data changes require explicit backward-compatible migration handling.
- **Approval**: Human approval required for production publish gates, primary secret rotation, and destructive data actions. Agent-safe unattended actions: preview deploys, log reads, non-destructive diagnostics.
- **Logs**: Runtime logs via `npx wrangler tail`; pipeline/deploy status via CI logs and Cloudflare deployment history APIs/UI in read-only mode.

## Risk Register

| Risk | Source | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| Node-compat package breakage in production | Devil's advocate | M | H | Maintain a dependency compatibility checklist and run staging smoke tests on real Cloudflare runtime before prod promote. |
| Progressive platform lock-in | Pre-mortem | M | M | Keep domain logic/storage interfaces portable; avoid unnecessary adoption of platform-specific primitives in core business paths. |
| Hard-to-reproduce runtime incidents | Devil's advocate | M | M | Standardize structured logging and error fingerprints; keep reproducible minimal repro scripts in repo. |
| Config drift between preview and production | Unknown unknowns | M | H | Manage bindings/secrets via audited config workflows and parity checks before releases. |
| Code rollback succeeds but data rollback fails | Unknown unknowns | L | H | Enforce backward-compatible DB migrations and define explicit rollback playbooks for each migration. |
| Feature/status drift in evolving platform tooling | Research finding | M | M | Re-validate non-GA or recently changed features before each major release and update operational runbooks quarterly. |

## Getting Started

1. Ensure project secrets are set for runtime: `npx wrangler secret put SUPABASE_URL` and `npx wrangler secret put SUPABASE_KEY`.
2. Build the app with the current stack path: `npm run build`.
3. Deploy using Wrangler (repo-standard flow): `npx wrangler deploy`.
4. Confirm runtime behavior and auth flows in deployed environment, then enable/verify preview protection rules if needed.
5. Document rollback and secret-rotation steps in your ops runbook before first public release.

## Out of Scope

The following were not evaluated in this research:
- Docker image configuration
- CI/CD pipeline setup
- Production-scale architecture (multi-region, HA, DR)
