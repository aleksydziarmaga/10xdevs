do $$
declare
  expected_indexes text[] := array[
    'idx_budget_template_wallet_active',
    'idx_monthly_budgets_wallet_period',
    'idx_expenses_wallet_date',
    'idx_expenses_wallet_category_date',
    'idx_expenses_monthly_budget',
    'idx_monthly_budget_category_snapshots_monthly',
    'idx_monthly_budget_recurring_snapshots_monthly',
    'idx_monthly_budget_savings_snapshots_monthly'
  ];
  idx text;
begin
  foreach idx in array expected_indexes loop
    if not exists (
      select 1
      from pg_indexes
      where schemaname = 'public'
        and indexname = idx
    ) then
      raise exception 'Missing expected index: %', idx;
    end if;
  end loop;
end
$$;
