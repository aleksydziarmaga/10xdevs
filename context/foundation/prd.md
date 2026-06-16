---
project: HomeWallet
version: 1
status: draft
created: 2026-06-16
context_type: greenfield
product_type: web-app
target_scale:
  users: small
  qps: "# TODO: target_scale.qps — see Open Questions"
  data_volume: "# TODO: target_scale.data_volume — see Open Questions"
timeline_budget:
  mvp_weeks: 3
  hard_deadline: 2026-06-30
  after_hours_only: true
---

## Vision & Problem Statement

Managing home finances in Excel is not user-friendly, depends on manual data entry, and makes it hard to add modules and automation. Couples and small households need to set allocations, track expenses, and review spending against budget without spreadsheet overhead.

HomeWallet is positioned as a collaborative household budgeting product that automates categorization and gives immediate visibility into spending versus allocations, so users can act on budget drift while the month is still in progress.

## User & Persona

### Primary Persona

Alex (28), one half of a couple managing shared household finances.

- Situation: Splits bills and variable expenses with a partner and wants a single source of truth for monthly spending.
- Pain: Manually updating a spreadsheet after each expense is tedious and provides no immediate overspending visibility.
- Need: Set monthly budgets by category (Needs/Wants/Savings), see real-time spending versus budget, and compare actual versus projected allocations.

## Success Criteria

### Primary

- HomeWallet allows users to track and visualize expenses with a monthly budget based on a pre-configured template.

### Secondary

- Import expenses from a bank statement (nice-to-have for v1).

### Guardrails

- User data must never be lost.
- Expense calculations must always be correct (amounts, categorizations, totals).

## User Stories

### US-01: Owner Creates a Monthly Budget from Template

- **Given** Alex creates a HomeWallet with income $5,000 and sets a 40/30/30 guideline split (Needs/Wants/Savings)
- **When** she adds recurring expenses (rent $1,500 = Needs, utilities $150 = Needs, gym $30 = Wants, insurance $100 = Needs), budget categories (food $400 = Needs, cosmetics $100 = Wants, communication $50 = Wants), and a savings goal of $500, then creates a June budget from this template
- **Then** HomeWallet calculates Needs $2,150, Wants $180, Savings $500, and compares this to the guideline split ($2,000 / $1,500 / $1,500)

### US-02: Owner Tracks Expenses Against Budget

- **Given** Alex's June budget is active
- **When** she adds expenses: groceries $150 (food), dinner $45 (food), lipstick $25 (cosmetics)
- **Then** HomeWallet updates Needs spending to $195 / $2,150, Wants spending to $75 / $180, and displays remaining budget per type

### US-03: Guest Views Budget

- **Given** Alex invited her partner as a read-only guest
- **When** the partner logs in
- **Then** the partner sees the budget summary (allocations, actuals, remaining per type) and expense list in read-only mode

## Functional Requirements

### Wallet & Template Configuration

- FR-001: Owner can create a wallet. Priority: must-have
- FR-002: Owner can set a guideline revenue split percentage (Needs %, Wants %, Savings %) for the wallet. Priority: must-have
- FR-003: Owner can add recurring expenses and assign each to a type (Needs/Wants/Savings). Priority: must-have
- FR-004: Owner can add budget categories and assign each to a type (Needs/Wants/Savings) with a monthly budget amount. Priority: must-have
- FR-005: Owner can create savings goals with a target monthly savings amount. Priority: must-have

### Monthly Budget Instance

- FR-006: Owner can create a monthly budget instance from template. Priority: must-have
- FR-007: Monthly budget calculates totals: sum of recurring expenses per type (Needs/Wants) + sum of budget category allocations + savings goal = actual monthly allocation by type. Priority: must-have

### Expense Tracking & Categorization

- FR-008: Owner can add an expense with date, amount, budget category, and optional description. Priority: must-have
- FR-009: Owner can create a new budget category on-the-fly if it does not exist. Priority: must-have
- FR-010: Owner can view a list of all expenses for the current budget period. Priority: must-have
- FR-011: Every tracked expense must be assigned to a budget category. Priority: must-have

### Budget Visibility & Reports

- FR-012: Owner can view a budget summary showing total monthly income, allocated amounts per type, actual spending per type, and remaining per type. Priority: must-have
- FR-013: Owner can see visual comparisons of budgeted versus actual spending per type (Needs/Wants/Savings). Priority: nice-to-have

### Guest Access

- FR-014: Owner can invite a guest by email or share link. Priority: nice-to-have
- FR-015: Guest can view owner wallet summary and expense list (read-only). Priority: nice-to-have

## Non-Functional Requirements

- Data durability: wallet configuration, budgets, and expenses must be persisted reliably and not lost.
- Calculation accuracy: amounts, categorizations, and totals must be computed correctly, including partial-month budgets and category changes.
- Response time: budget summary and expense list should display within 2 seconds of user action.
- Accessibility: web app must be usable on desktop browsers (Chrome, Firefox, Safari) and mobile browsers (iOS Safari, Android Chrome).

## Business Logic

HomeWallet applies the user's revenue-split intent (guideline Needs/Wants/Savings %) to actual recurring bills and discretionary budgets, then tracks spending against each category to show real-time adherence and variance.

User defines a guideline split as an allocation target, assigns recurring expenses and budget categories to Needs/Wants/Savings, creates a savings goal, and generates a monthly budget instance from this template. As expenses are added during the month, HomeWallet continuously updates spending versus budget, remaining amounts per type, and variance from the original guideline.

## Access Control

Auth model: Email + password login.

- Owner: Can create wallet, set revenue, categorize expenses, configure budgets, view reports, and invite read-only guests.
- Guest (read-only): Can view wallet, expenses, and reports but cannot edit.

## Non-Goals

- Multi-tenant features in v1 (single-wallet, single-user editing model).
- Bank statement import in v1 (manual expense entry only).

## Open Questions

1. **What is the expected `target_scale.qps` ballpark?** — Owner: user. Block: no (needed to complete frontmatter precision).
2. **What is the expected `target_scale.data_volume` ballpark?** — Owner: user. Block: no (needed to complete frontmatter precision).
