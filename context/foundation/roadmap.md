---
project: HomeWallet
version: 1
status: draft
created: 2026-06-24
updated: 2026-06-24
prd_version: 1
main_goal: speed
top_blocker: time
---

# Roadmap: HomeWallet

> Derived from `context/foundation/prd.md` (v1) + auto-researched codebase baseline.
> Edit-in-place; archive when superseded.
> Slices below are listed in dependency order. The "At a glance" table is the index.

## Vision recap

Managing home finances in Excel is not user-friendly and depends on manual data entry. HomeWallet automates categorization and gives couples immediate visibility into spending versus allocations, so users can act on budget drift while the month is still in progress. The product wedge — the one trait that, if removed, makes HomeWallet generic — is that it enforces a spending philosophy (guideline split) and highlights when actual behavior deviates from intent.

## North star

**S-01–S-02–S-03–S-04 integrated: Owner sets up a budget, tracks expenses, and sees spending vs. budget in real-time** — This is the validation milestone: if an owner can set up a budget from a template, add an expense, and see real-time summary updates, the core hypothesis (budget-vs-spending visibility works) is proven.

> The north star is the smallest end-to-end slice whose successful delivery would prove the core product hypothesis — placed as early as Prerequisites allow because everything else only matters if this works.

## At a glance

| ID | Change ID | Outcome (user can …) | Prerequisites | PRD refs | Status |
|---|---|---|---|---|---|
| F-01 | data-schema-and-persistence | (foundation) Schema for wallets, budgets, expenses, categories, savings goals persisted and queryable | — | NFR: data durability, NFR: calculation accuracy | ready |
| S-01 | owner-budget-template-setup | Owner configures a household budget template with income, recurring expenses, budget categories, and savings goal | F-01 | FR-001, FR-002, FR-003, FR-004, FR-005, US-01 | ready |
| S-02 | owner-creates-monthly-budget | Owner instantiates a monthly budget from template and sees calculated allocations per type (Needs/Wants/Savings) | S-01 | FR-006, FR-007, US-01 | ready |
| S-03 | owner-tracks-expenses | Owner adds expenses and views the list, each assigned to a category | S-02, F-01 | FR-008, FR-009, FR-010, FR-011, US-02 | ready |
| S-04 | owner-reviews-budget-summary | Owner sees real-time budget summary: allocated vs. spent vs. remaining per type | S-03 | FR-012, US-02 | ready |

## Baseline

What's already in place in the codebase as of 2026-06-24 (auto-researched + user-confirmed).
Foundations below assume these are present and do NOT re-scaffold them.

- **Frontend:** Present — Astro 6 SSR + React 19 + TailwindCSS, TypeScript, routing in `src/pages/`
- **Backend / API:** Present — Astro Server Adapter (@astrojs/cloudflare), API routes `src/pages/api/auth/*`
- **Data:** Partial — Supabase SSR client configured, `src/lib/supabase.ts`, `supabase/config.toml`; NO migrations/schema
- **Auth:** Present — Supabase SSR integration, middleware.ts, cookie-based sessions
- **Deploy / infra:** Present — Cloudflare Workers (wrangler.jsonc); NO CI/CD workflows
- **Observability:** Absent — No logging/error tracking libraries

## Foundations

### F-01: Data Schema & Persistence

- **Outcome:** (foundation) Schema for wallets, budget templates, monthly budgets, expenses, budget categories, recurring expenses, and savings goals. Migrations established. Data is persisted and queryable.
- **Change ID:** data-schema-and-persistence
- **PRD refs:** NFR: data durability, NFR: calculation accuracy, Access Control (owner wallet isolation)
- **Unlocks:** S-01, S-02, S-03, S-04
- **Prerequisites:** —
- **Parallel with:** —
- **Blockers:** —
- **Unknowns:**
  - "Optimal table structure for budget template → monthly instance relationship?" — Owner: architect. Block: no.
- **Risk:** Only 6 days to ship. Schema mistakes cascade into all slices. Mitigation: validate with S-01 logic early.
- **Status:** ready

#### F-01 acceptance checklist for S-01 handoff

- [x] Domain schema migrations exist for wallet/template/monthly/expense model
- [x] Owner isolation is enforced with RLS policies across all domain tables
- [x] Snapshot + period guard behavior is covered by reproducible SQL verification
- [x] Query-path indexes exist for wallet/period/category/date access patterns
- [x] Local verification workflow is documented and executable

## Slices

### S-01: Owner Budget Template Setup

- **Outcome:** Owner can configure a household budget template with monthly income, recurring expenses, budget categories with allocations, and savings goal.
- **Change ID:** owner-budget-template-setup
- **PRD refs:** FR-001, FR-002, FR-003, FR-004, FR-005, US-01
- **Prerequisites:** F-01
- **Parallel with:** —
- **Blockers:** —
- **Unknowns:**
  - "UI: wizard or single form?" — Owner: product. Block: no.
  - "Guideline split: editable percentages or presets?" — Owner: product. Block: no.
- **Risk:** Gateway slice. Template schema errors cascade. Prioritize data model correctness.
- **Status:** ready

### S-02: Owner Creates Monthly Budget

- **Outcome:** Owner instantiates a monthly budget from template and sees calculated allocations per type (Needs/Wants/Savings) vs. guideline split.
- **Change ID:** owner-creates-monthly-budget
- **PRD refs:** FR-006, FR-007, US-01
- **Prerequisites:** S-01
- **Parallel with:** —
- **Blockers:** —
- **Unknowns:**
  - "Budget creation: auto-copy template or prompt?" — Owner: product. Block: no.
- **Risk:** FR-007 calculation logic is critical. Totals must be correct or S-04 fails.
- **Status:** ready

### S-03: Owner Tracks Expenses

- **Outcome:** Owner can add an expense (date, amount, category, optional description), create a new category on-the-fly, and view all expenses for the current period. Every expense is assigned to a category.
- **Change ID:** owner-tracks-expenses
- **PRD refs:** FR-008, FR-009, FR-010, FR-011, US-02
- **Prerequisites:** S-02, F-01
- **Parallel with:** —
- **Blockers:** —
- **Unknowns:**
  - "New category: auto-assign to Needs/Wants/Savings or require user pick?" — Owner: product. Block: no.
  - "Allow expense edit/delete, or only in current period?" — Owner: product. Block: no.
- **Risk:** Expense entry broken = S-04 summary garbage. Mitigation: rigorous validation.
- **Status:** ready

### S-04: Owner Reviews Budget Summary

- **Outcome:** Owner sees real-time budget summary: monthly income, allocated amounts per type, actual spending per type, and remaining per type (Needs/Wants/Savings). Comparison to guideline split displayed.
- **Change ID:** owner-reviews-budget-summary
- **PRD refs:** FR-012, US-02
- **Prerequisites:** S-03
- **Parallel with:** —
- **Blockers:** —
- **Unknowns:**
  - "Live update on expense add or page refresh?" — Owner: product. Block: no.
  - "Month-to-date only or custom date ranges?" — Owner: product. Block: no.
- **Risk:** This is the "aha!" moment. Wrong calculation or slow response (NFR: 2s) erodes trust. Mitigation: pre-compute summary; use DB view.
- **Status:** ready

## Backlog Handoff

| Roadmap ID | Change ID | Suggested issue title | Ready for `/10x-plan` | Notes |
|---|---|---|---|---|
| F-01 | data-schema-and-persistence | Design and implement data schema and migrations for wallets, budgets, expenses, categories | yes | Start here. Target: 1–2 days. |
| S-01 | owner-budget-template-setup | Implement owner budget template setup (income, splits, expenses, categories, goals) | yes | Depends on F-01. Target: 1.5 days. |
| S-02 | owner-creates-monthly-budget | Implement monthly budget instantiation and calculation (allocations vs. guideline split) | yes | Depends on S-01. Target: 1 day. |
| S-03 | owner-tracks-expenses | Implement expense entry, category creation, expense list view | yes | Depends on S-02. Target: 1.5 days. |
| S-04 | owner-reviews-budget-summary | Implement real-time budget summary (allocated, spent, remaining per type) | yes | Depends on S-03. The "aha!" moment. Target: 1 day. |

## Open Roadmap Questions

1. **What is the expected `target_scale.qps` ballpark?** — Owner: user. Block: no (precision question; doesn't gate MVP).
2. **What is the expected `target_scale.data_volume` ballpark?** — Owner: user. Block: no (same).

## Parked

- **FR-013 (Charts/visualizations)** — Why: main_goal `speed`. Tables + numbers (S-04 summary) sufficient for v1. Charts are v1.1 polish.
- **FR-014 & FR-015 (Guest access)** — Why: Multi-user out of scope per PRD §Non-Goals. Owner-only is MVP. Guest access is v1.1.
- **Bank statement import** — Why: PRD defers to v1.1. Manual entry ships faster.

## Done

(Empty on first generation. `/10x-archive` appends entries here when changes archive.)
