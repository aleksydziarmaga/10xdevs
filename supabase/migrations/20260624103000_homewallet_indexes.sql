create index if not exists idx_budget_template_wallet_active
  on public.budget_template (wallet_id, is_active);

create index if not exists idx_monthly_budgets_wallet_period
  on public.monthly_budgets (wallet_id, period_year, period_month);

create index if not exists idx_expenses_wallet_date
  on public.expenses (wallet_id, expense_date desc);

create index if not exists idx_expenses_wallet_category_date
  on public.expenses (wallet_id, category_id, expense_date desc);

create index if not exists idx_expenses_monthly_budget
  on public.expenses (monthly_budget_id);

create index if not exists idx_monthly_budget_category_snapshots_monthly
  on public.monthly_budget_category_snapshots (monthly_budget_id);

create index if not exists idx_monthly_budget_recurring_snapshots_monthly
  on public.monthly_budget_recurring_expense_snapshots (monthly_budget_id);

create index if not exists idx_monthly_budget_savings_snapshots_monthly
  on public.monthly_budget_savings_goal_snapshots (monthly_budget_id);
