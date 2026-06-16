---
project: HomeWallet
context_type: greenfield
checkpoint:
  current_phase: 8
  phases_completed: [1, 2, 3, 4, 4.5, 5, 6, 7]
  frs_drafted: 15
  quality_check_status: accepted
created: 2026-06-16
updated: 2026-06-16
---

# HomeWallet: Shape Notes

## Vision & Problem Statement

From your init-idea.md, you described: **tracking and managing home budget in an excel file is not user-friendly and hard to add modules and automation.**

Let me pin this more precisely. You mentioned:

**Pain:** Managing home finances in Excel isn't user-friendly and lacks automation.  
**Person:** Individuals managing their own personal/household finances.  
**Moment:** When setting up revenue allocations, tracking expenses, or reviewing spending vs. budget.  
**Cost today:** Manual data entry, no live feedback on spending vs. categories, hard to add new rules or categories.

---

**Gray-area resolutions:**
- Pain category: Missing capability — no automated categorization, comparisons, or real-time feedback
- Insight: You know the exact revenue/expense categories people need + what budget splits work
- Primary persona: Couples and small households managing shared finances (not solo users)

This positions HomeWallet as a **collaborative household budgeting tool** that automates categorization and gives couples/households immediate visibility into spending vs. allocations.

## User & Persona

**Primary Persona: Alex (28) — half of a couple managing shared household finances**

- Situation: Splits bills and variable expenses with partner; wants a single source of truth for "where did the money go this month?"
- Pain: Manually updating a spreadsheet after each expense is tedious; no automated alerts when Wants category is overspent
- Need: A place to set monthly budgets by category (Needs/Wants/Savings per their init-idea), see real-time spending vs. budget, and compare actual vs. projected allocations

## Access Control

**Auth model:** Email + password login.

**Roles:**
- **Owner**: Can create a wallet, set revenue, categorize expenses, configure budgets, view reports. Can invite read-only guests.
- **Guest (read-only)**: Invited by owner. Can view the wallet, expenses, and reports but cannot edit anything.

**Implication**: One person (Alex) owns and edits the household budget; her partner (or family member) can view the current state but cannot make changes. Changes are owner-driven.

---

Now let's sketch the MVP — the smallest end-to-end flow that proves this app works.

## Success Criteria

**Primary:** HomeWallet allows users to track and visualize expenses with a monthly budget based on a pre-configured template.

**MVP Flow:**
1. Alex creates a wallet and sets her monthly income
2. She configures revenue splits (Needs 40%, Wants 30%, Savings 30%)
3. She sets up recurring bills and categorizes them
4. She creates savings goals with target amounts
5. She sets default expense categories
6. She creates a monthly budget based on this template
7. She begins tracking expenses and sees her spending vs. budget in real time

**Secondary:** Import expenses from a bank statement (nice-to-have for v1).

**Guardrails:** 
- User data must never be lost
- Expense calculations must always be correct (amounts, categorizations, totals)

**Timeline acknowledged:** 3 weeks of focused after-hours work is feasible for this MVP.

---

Now let's pin the concrete capabilities this flow requires.






## Functional Requirements

### Wallet & Template Configuration

- FR-001: Owner can create a wallet. Priority: must-have
- FR-002: Owner can set a guideline revenue split percentage (Needs %, Wants %, Savings %) for the wallet. Priority: must-have
- FR-003: Owner can add recurring expenses (e.g., rent $1,500, gym $30) and assign each to a type (Needs/Wants/Savings). Priority: must-have
- FR-004: Owner can add budget categories (e.g., food, cosmetics, communication) and assign each to a type (Needs/Wants/Savings) with a monthly budget amount. Priority: must-have
- FR-005: Owner can create savings goals with a target monthly savings amount. Priority: must-have

### Monthly Budget Instance

- FR-006: Owner can create a monthly budget instance from template. Priority: must-have
- FR-007: Monthly budget calculates totals: sum of recurring expenses per type (Needs/Wants) + sum of budget category allocations + savings goal = actual monthly allocation by type. Priority: must-have

### Expense Tracking & Categorization

- FR-008: Owner can add an expense with: date, amount, budget category (from pre-configured list or new), and optional description. Priority: must-have
- FR-009: Owner can create a new budget category on-the-fly if it doesn't exist. Priority: must-have
- FR-010: Owner can view a list of all expenses for the current budget period. Priority: must-have
- FR-011: Every tracked expense must be assigned to a budget category. Priority: must-have

### Budget Visibility & Reports

- FR-012: Owner can view a budget summary showing: total monthly income, allocated amounts per type (Needs/Wants/Savings), actual spending per type, and remaining per type. Priority: must-have
- FR-013: Owner can see visual charts comparing budgeted vs. actual spending per type (Needs/Wants/Savings). Priority: must-have

### Guest Access

- FR-014: Owner can invite a guest by email/link. Priority: must-have
- FR-015: Guest can view owner's wallet summary and expense list (read-only). Priority: must-have

## User Stories

### US-01: Owner Creates a Monthly Budget from Template

**Given** Alex creates a HomeWallet with income $5,000 and sets guideline split 40/30/30 (Needs/Wants/Savings)  
**When** she adds recurring expenses (rent $1,500 = Needs, utilities $150 = Needs, gym $30 = Wants, insurance $100 = Needs) and budget categories (food $400 = Needs, cosmetics $100 = Wants, communication $50 = Wants), and savings goal $500  
**And** creates a June budget from this template  
**Then** HomeWallet calculates: Needs $2,150 (rent + utilities + insurance + food), Wants $180 (gym + cosmetics + communication), Savings $500, and compares to guideline split ($2,000/$1,500/$1,500).

### US-02: Owner Tracks Expenses Against Budget

**Given** Alex's June budget is active  
**When** she adds expenses: groceries $150 (food), dinner $45 (food), lipstick $25 (cosmetics)  
**Then** HomeWallet updates: Needs spending $195/2,150, Wants spending $75/180, shows charts, and displays remaining budget per type.

### US-03: Guest Views Budget

**Given** Alex invited her partner as read-only guest  
**When** partner logs in  
**Then** partner sees budget summary (allocations, actuals, remaining per type) and expense list—read-only.

---

Now let's stress-test each FR with a Socrates round.

### Socrates Challenge Results

- FR-001: No counter-argument; keeper (wallet isolation is owner-driven by design).
- FR-002: Guidelines are useful for pre-allocation and later comparison; keeper.
- FR-003: Recurring expenses are template-based, added once; keeper.
- FR-004: User-creatable categories necessary; keeper.
- FR-005: Explicit savings goals are necessary; keeper.
- FR-006: Owner should close monthly budget and open new; budget lifecycle is important (implication for UI/state management).
- FR-007: Real-time calculation validated; keeper.
- FR-008: Manual expense entry for v1; keeper.
- FR-009: No counter-argument; keeper.
- FR-010: Expense list is important for v1; keeper.
- FR-011: Unassigned expenses rejected; force categorization at entry (refines FR).
- FR-012: Real-time summary update validated; keeper.
- FR-013: **Deprioritized**: Charts aren't essential for v1; tables/numbers sufficient. Move to nice-to-have for v1.1.
- FR-014 & FR-015: **Deprioritized**: Guest access is out of scope for v1. Move to nice-to-have for v1.1.

**Result**: v1 focuses on owner's personal budget workflow (setup → tracking → summary view). Guest sharing and charts are v1.1.

Updated FRs for v1:
- FR-001 through FR-012 are must-have for v1.
- FR-013 (charts), FR-014 (invites), FR-015 (guest view) are nice-to-have for v1.1.

---

## Business Logic

**One-sentence rule:** HomeWallet applies the user's revenue-split intent (guideline Needs/Wants/Savings %) to actual recurring bills and discretionary budgets, then tracks spending against each category to show real-time adherence and variance.

**How it works:**
1. User defines a guideline split (e.g., 40% Needs, 30% Wants, 30% Savings) as an allocation target.
2. User assigns each recurring expense (rent, utilities, gym) to a type (Needs/Wants/Savings).
3. User creates budget categories (food, cosmetics, communication) and assigns each to a type with a monthly budget amount.
4. HomeWallet calculates the actual allocation: sum of recurring expenses per type + sum of budget category allocations + savings goal.
5. User tracks expenses during the month, assigning each to a budget category.
6. HomeWallet updates a live summary: actual spending vs. budgeted, remaining per type, and comparison to guideline split.
7. User can see if actual spending adheres to guideline or if types are imbalanced (e.g., Wants is 35% instead of 30%).

**Domain insight**: HomeWallet doesn't just store expenses—it enforces a spending philosophy (the guideline split) and highlights when actual behavior deviates from intent. This moves the user from "where did it go?" to "am I on track with my own rules?"

---

## Non-Functional Requirements

- **Data durability**: User data (wallet config, budget, expenses) must be persisted reliably and never lost.
- **Calculation accuracy**: All amounts, categorizations, and totals must be computed correctly. Edge cases (partial-month budgets, category changes mid-month) must not corrupt data.
- **Response time**: Budget summary and expense list should display within 2 seconds of user action (page load, expense add).
- **Accessibility**: Web app must be usable on desktop browsers (Chrome, Firefox, Safari) and mobile browsers (iOS Safari, Android Chrome).

---


## Product Framing

**Product type:** Web app (browser-based, desktop + mobile responsive).

**Target scale:** Small (just me / handful of people). This is a personal budgeting tool, not a multi-tenant SaaS platform.

**Timeline & budget:**
- Hard deadline: June 30, 2026 (2 weeks from shape start)
- Mode: After-hours work (evenings/weekends)
- Estimated MVP: 3 weeks of focused after-hours effort

**Note:** The hard deadline (June 30) is earlier than the estimated MVP (3 weeks). This is a tight but achievable target if work is sustained and focused.

## Non-Goals (v1)

- **Avoid: Multi-tenant features.** v1 is single-wallet, single-user. Guest sharing and household collaboration are deferred to v1.1.
- **Avoid: Bank API integration.** v1 uses manual expense entry only. Bank statement import (secondary FR-NNN nice-to-have) is deferred to v1.1.

---


## Quality Cross-Check

✓ Access Control: Present (Owner + Guest roles defined; auth model specified)
✓ Business Logic: Present (one-sentence rule + 7-step domain explanation)
✓ Project artifacts: Present (shape-notes.md with frontmatter checkpoint)
✓ Timeline-cost acknowledged: Present (3-week MVP with hard deadline June 30; tight but accepted)
✓ Non-Goals: Present (multi-tenant avoidance + bank API avoidance)
✓ Constraints: Present (data durability, calculation accuracy, response time, accessibility)

**Quality status: ACCEPTED.** All elements are present. No gaps.

---

