# HomeWallet F-01 Data Schema & Persistence Implementation Plan

## Overview

Implement the persistence foundation for HomeWallet so wallet configuration, monthly budgets, and expenses are durable, queryable, and safely isolated per owner. This plan establishes the domain schema, migrations, and row-level access controls that unblock S-01 through S-04.

## Current State Analysis

The project has Astro SSR + Supabase auth wired, but domain persistence is not implemented yet. There are no app tables, no domain migrations, and no RLS policies for wallet data. Auth identity is resolved in middleware and can be reused for ownership boundaries in new domain tables.

## Desired End State

After completion, the codebase has versioned SQL migrations that create all F-01 domain tables and constraints, enable owner-only RLS on all domain data, and support stable monthly-budget snapshots and category-safe expense history.

The end state is verified when a clean DB reset applies migrations successfully, owner-scoped reads/writes work, cross-owner access is denied, and core F-01 data flows (template setup, monthly snapshot, expense logging) remain consistent under category edits and period validation.

### Key Discoveries:

- F-01 explicitly requires schema + persistence and is the dependency root for S-01..S-04 (`context/foundation/roadmap.md:32`, `context/foundation/roadmap.md:52`, `context/foundation/roadmap.md:57`).
- Baseline confirms Supabase exists but there is no domain schema yet (`context/foundation/roadmap.md:45`, `README.md:114`).
- Auth identity is already available server-side via middleware locals and Supabase SSR client (`src/middleware.ts:6`, `src/middleware.ts:13`, `src/lib/supabase.ts:5`).
- Repo conventions require timestamped Supabase migrations and RLS on new tables (`CLAUDE.md:39`).

## What We're NOT Doing

- Guest access model (FR-014/FR-015) and multi-user collaboration logic.
- Bank import or external ingestion flows.
- Full CRUD service/API surface for every entity in this change (only minimal contracts required by F-01).
- Heavy pre-aggregation/materialized analytics beyond MVP indexing.

## Implementation Approach

Use forward-only Supabase SQL migrations to introduce a normalized owner-centric schema:
1) owner-to-wallet foundation, 2) template + monthly snapshot structures, 3) expense tracking with category snapshot fields, 4) strict RLS deny-by-default policies. Amounts are stored as integers in the smallest currency unit to preserve calculation accuracy. Migration steps prioritize backward compatibility and deterministic rollout.

## Phase 1: Schema foundations & invariants

### Overview

Define the core tables and relational constraints for wallets, templates, monthly budgets, categories, recurring expenses, savings goals, and expenses.

### Changes Required:

#### 1. Domain migration baseline

**File**: `supabase/migrations/<timestamp>_create_homewallet_domain_schema.sql`

**Intent**: Create the initial domain schema that maps PRD entities to relational tables with ownership anchors and integrity constraints.

**Contract**: Add tables for wallet, budget_template, budget_template_categories, recurring_expenses, savings_goals, monthly_budgets, expenses (plus required join/reference fields), with foreign keys, uniqueness constraints, and `created_at`/`updated_at` metadata.

#### 2. Monetary representation rules

**File**: `supabase/migrations/<timestamp>_create_homewallet_domain_schema.sql`

**Intent**: Enforce accurate financial math by standardizing amount storage.

**Contract**: All monetary values are integer columns in smallest currency unit (e.g., cents/grosze) with non-negative checks where applicable.

#### 3. Period and snapshot invariants

**File**: `supabase/migrations/<timestamp>_budget_period_and_snapshot_constraints.sql`

**Intent**: Protect monthly-budget consistency and preserve historical meaning.

**Contract**: Monthly budget period keys are unique per wallet; expense rows carry category snapshot fields (`category_name`, `category_type`) captured at write-time; inserts must map to an existing monthly budget period for expense date.

#### 4. Typed domain contracts

**File**: `src/types.ts`

**Intent**: Provide minimal shared types reflecting F-01 entities for later slices and API surfaces.

**Contract**: Introduce lightweight entity/DTO type contracts aligned with new schema field names and integer amount semantics.

### Success Criteria:

#### Automated Verification:

- Migration applies cleanly on reset: `npx supabase db reset`
- Domain tables, keys, and checks exist as expected (schema validation query script)
- Linting passes: `npm run lint`
- Build succeeds: `npm run build`

#### Manual Verification:

- In Supabase Studio, relational links between wallet/template/monthly/expense entities match roadmap F-01 expectations
- Seeded sample inserts confirm integer amount storage and constraint behavior for invalid rows

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation from the human that the manual testing was successful before proceeding to the next phase.

---

## Phase 2: Ownership isolation & RLS

### Overview

Enforce owner-only access boundaries for all domain tables using row-level security.

### Changes Required:

#### 1. RLS enablement

**File**: `supabase/migrations/<timestamp>_enable_rls_on_domain_tables.sql`

**Intent**: Turn on row-level security across the full domain surface as default-safe posture.

**Contract**: `ALTER TABLE ... ENABLE ROW LEVEL SECURITY` for every F-01 domain table; default deny unless policy explicitly allows.

#### 2. Owner-scoped policies

**File**: `supabase/migrations/<timestamp>_owner_policies.sql`

**Intent**: Guarantee wallet isolation so a user can only read/write rows belonging to their own wallet graph.

**Contract**: Policies enforce `auth.uid()` ownership through wallet root, including child tables (template/monthly/category/expense/recurring/savings goal).

#### 3. Policy verification script

**File**: `supabase/seed.sql` (or dedicated SQL verification file referenced by reset flow)

**Intent**: Provide reproducible checks that positive and negative access paths behave correctly.

**Contract**: Include SQL test fixtures and assertions for owner-allowed and cross-owner-denied operations.

### Success Criteria:

#### Automated Verification:

- RLS is enabled for all domain tables (catalog query check)
- Owner policy smoke checks pass for allowed and denied access paths
- Linting passes: `npm run lint`
- Build succeeds: `npm run build`

#### Manual Verification:

- Using two test users, each can only see and mutate own wallet data
- Attempted cross-owner access fails with expected permission errors

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation from the human that the manual testing was successful before proceeding to the next phase.

---

## Phase 3: Budget lifecycle modeling

### Overview

Finalize behavioral persistence rules for template instantiation, monthly snapshots, and expense-period consistency.

### Changes Required:

#### 1. Template-to-month snapshot migration

**File**: `supabase/migrations/<timestamp>_monthly_budget_snapshot_contract.sql`

**Intent**: Keep monthly budget history stable even when template configuration changes later.

**Contract**: Creating a monthly budget persists a snapshot of relevant template allocations and settings for that period.

#### 2. Category-history-safe expenses

**File**: `supabase/migrations/<timestamp>_expense_category_snapshot_rules.sql`

**Intent**: Preserve historical reporting integrity when categories are renamed or retired.

**Contract**: Expense rows persist category snapshot fields at insertion; future category edits do not rewrite historical expense semantics.

#### 3. Out-of-period guardrails

**File**: `supabase/migrations/<timestamp>_expense_period_guards.sql`

**Intent**: Prevent orphaned expense data that cannot be attributed to a valid monthly budget period.

**Contract**: Expense insertion/update is rejected when no monthly budget exists for expense date + wallet context.

#### 4. Minimal server contracts for persistence usage

**File**: `src/lib/services/` (new domain service module[s]) and/or `src/pages/api/` contracts used by next slices

**Intent**: Add only the minimal typed access contracts needed so later slices can consume F-01 persistence safely.

**Contract**: Introduce focused read/write contract boundaries without implementing full feature APIs of S-01+.

### Success Criteria:

#### Automated Verification:

- SQL fixture proves monthly snapshot remains unchanged after template edits
- SQL fixture proves expense category snapshot remains stable after category rename/delete
- SQL fixture rejects expense outside existing monthly budget period
- Linting passes: `npm run lint`
- Build succeeds: `npm run build`

#### Manual Verification:

- Foundation-stage DB lifecycle scenario confirms stable period attribution and historical consistency (template -> monthly snapshot -> expense history under category changes), without UI dependencies.
- Full UI end-to-end verification for US-01/US-02 is deferred to slices S-01..S-04 once application flows exist.

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation from the human that the manual testing was successful before proceeding to the next phase.

---

## Phase 4: Performance baseline & developer verification workflow

### Overview

Add MVP-appropriate indexing and reproducible developer verification flow to keep summary/list queries responsive and safe for follow-up slices.

### Changes Required:

#### 1. Query-path indexes

**File**: `supabase/migrations/<timestamp>_homewallet_indexes.sql`

**Intent**: Support expected MVP query patterns for wallet-period-category-date access.

**Contract**: Add indexes for dominant access keys (`wallet_id`, period keys, `category_id`, `expense_date`) and composite paths used by summary/list queries.

#### 2. Developer verification commands alignment

**File**: `README.md`, `context/foundation/roadmap.md` (if acceptance notes need alignment), and optional SQL verification notes under `supabase/`

**Intent**: Make F-01 verification repeatable for humans and agents before S-01 starts.

**Contract**: Document reset/migration/check steps and expected outcomes for schema + policy + snapshot behavior.

#### 3. Seed/config hygiene

**File**: `supabase/seed.sql`, `supabase/config.toml` (only if required to align schema/seed paths)

**Intent**: Ensure local resets and deterministic smoke data work consistently.

**Contract**: Seed and config references are valid and executable in local Supabase workflow.

### Success Criteria:

#### Automated Verification:

- Indexes exist for agreed high-frequency query paths
- Local reset + seed workflow runs without missing-file or ordering errors
- Linting passes: `npm run lint`
- Build succeeds: `npm run build`

#### Manual Verification:

- Budget summary and expense-list representative SQL queries run within acceptable MVP expectations on local sample data
- F-01 acceptance checklist in roadmap is fully satisfied and ready to hand off to S-01 planning

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation from the human that the manual testing was successful before proceeding to the next phase.

## Testing Strategy

### Unit Tests:

- SQL-level verification scripts for constraints (uniqueness, foreign keys, period guards)
- SQL-level verification scripts for category snapshot and template snapshot behavior
- RLS allow/deny checks with multi-user fixtures

### Integration Tests:

- Schema + seed + policy checks in a clean reset flow
- Wallet-scoped read/write queries across linked tables

### Manual Testing Steps:

1. Create two users and two wallets, verify strict owner isolation.
2. Build template data, instantiate a monthly budget, then modify template and confirm monthly snapshot stability.
3. Log expenses, rename/delete category, and confirm expense history remains semantically correct.

## Performance Considerations

- Target scale is small MVP, so prioritize correct indexes over advanced partitioning.
- Use integer amounts to reduce computational drift and simplify deterministic aggregate checks.
- Keep index set focused on wallet + period + category + date access to avoid premature over-indexing.

## Migration Notes

- Use forward-only, timestamped migrations; avoid destructive operations in first pass.
- If a correction is needed, add a new migration rather than rewriting applied files.
- Keep migration ordering deterministic and compatible with `npx supabase db reset`.

## References

- Roadmap F-01 definition: `context/foundation/roadmap.md:52`
- Dependency chain and handoff target: `context/foundation/roadmap.md:57`
- PRD data durability & accuracy: `context/foundation/prd.md:103`
- Entity requirements (FR-001..FR-012 subset): `context/foundation/prd.md:73`
- Existing auth/user context pattern: `src/middleware.ts:6`
- Supabase server client setup: `src/lib/supabase.ts:5`
- Migration and RLS conventions: `CLAUDE.md:39`

## Progress

> Convention: `- [ ]` pending, `- [x]` done. Append ` — <commit sha>` when a step lands. Do not rename step titles. See `references/progress-format.md`.

### Phase 1: Schema foundations & invariants

#### Automated

- [x] 1.1 Migration applies cleanly on reset — ebafcf2
- [x] 1.2 Domain tables keys and checks exist as expected — ebafcf2
- [x] 1.3 Linting passes — ebafcf2
- [x] 1.4 Build succeeds — ebafcf2

#### Manual

- [x] 1.5 Relational links match roadmap F-01 expectations — ebafcf2
- [x] 1.6 Sample inserts validate integer amount and constraints behavior — ebafcf2

### Phase 2: Ownership isolation & RLS

#### Automated

- [x] 2.1 RLS is enabled for all domain tables — fc10454
- [x] 2.2 Owner policy smoke checks pass for allowed and denied paths — fc10454
- [x] 2.3 Linting and build pass — fc10454

#### Manual

- [x] 2.4 Two users can only access their own wallet data — fc10454
- [x] 2.5 Cross-owner access attempts fail with expected permission errors — fc10454

### Phase 3: Budget lifecycle modeling

#### Automated

- [x] 3.1 Monthly snapshot remains unchanged after template edits
- [x] 3.2 Expense category snapshot remains stable after category rename or delete
- [x] 3.3 Expense outside existing monthly period is rejected
- [x] 3.4 Linting and build pass

#### Manual

- [x] 3.5 US-01 and US-02 base data scenario confirms period and history consistency — 2895ddb

### Phase 4: Performance baseline & developer verification workflow

#### Automated

- [x] 4.1 Agreed indexes exist for high-frequency query paths — 2895ddb
- [x] 4.2 Local reset and seed workflow runs without missing-file or ordering errors — 2895ddb
- [x] 4.3 Linting and build pass — 2895ddb

#### Manual

- [x] 4.4 Representative summary and list queries meet MVP responsiveness expectations — 2895ddb
- [x] 4.5 F-01 acceptance checklist is ready for S-01 handoff — 2895ddb
