do $$
declare
  owner_id constant uuid := '00000000-0000-0000-0000-000000000303';
  v_wallet_id uuid;
  v_template_id uuid;
  v_monthly_budget_id uuid;
  v_category_id uuid;
begin
  delete from public.expenses;
  delete from public.monthly_budget_category_snapshots;
  delete from public.monthly_budget_recurring_expense_snapshots;
  delete from public.monthly_budget_savings_goal_snapshots;
  delete from public.monthly_budgets;
  delete from public.savings_goals;
  delete from public.recurring_expenses;
  delete from public.budget_template_categories;
  delete from public.budget_template;
  delete from public.wallet;
  delete from auth.users where id = owner_id;

  insert into auth.users (id, email, aud, role)
  values (owner_id, 'snapshot-owner@example.com', 'authenticated', 'authenticated');

  insert into public.wallet (owner_user_id, name)
  values (owner_id, 'Snapshot Wallet')
  returning id into v_wallet_id;

  insert into public.budget_template (wallet_id, name, monthly_income_amount)
  values (v_wallet_id, 'June Template', 100000)
  returning id into v_template_id;

  insert into public.budget_template_categories (template_id, name, category_type, monthly_amount)
  values (v_template_id, 'Food', 'needs', 20000)
  returning id into v_category_id;

  insert into public.recurring_expenses (template_id, name, category_type, monthly_amount)
  values (v_template_id, 'Rent', 'needs', 40000);

  insert into public.savings_goals (template_id, name, target_monthly_amount)
  values (v_template_id, 'Emergency Fund', 15000);

  insert into public.monthly_budgets (
    wallet_id,
    template_id,
    period_year,
    period_month,
    monthly_income_amount,
    guideline_needs_pct,
    guideline_wants_pct,
    guideline_savings_pct
  )
  values (v_wallet_id, v_template_id, 2026, 6, 100000, 40, 30, 30)
  returning id into v_monthly_budget_id;

  if (select count(*) from public.monthly_budget_category_snapshots where monthly_budget_id = v_monthly_budget_id) <> 1 then
    raise exception 'Expected one category snapshot.';
  end if;

  if (select count(*) from public.monthly_budget_recurring_expense_snapshots where monthly_budget_id = v_monthly_budget_id) <> 1 then
    raise exception 'Expected one recurring snapshot.';
  end if;

  if (select count(*) from public.monthly_budget_savings_goal_snapshots where monthly_budget_id = v_monthly_budget_id) <> 1 then
    raise exception 'Expected one savings-goal snapshot.';
  end if;

  insert into public.expenses (
    wallet_id,
    monthly_budget_id,
    category_id,
    expense_date,
    amount,
    description
  )
  values (v_wallet_id, v_monthly_budget_id, v_category_id, date '2026-06-14', 4500, 'Groceries');

  update public.budget_template_categories
  set name = 'Food Renamed', category_type = 'wants'
  where id = v_category_id;

  if not exists (
    select 1
    from public.expenses e
    where e.wallet_id = v_wallet_id
      and e.category_name = 'Food'
      and e.category_type = 'needs'
  ) then
    raise exception 'Expense snapshot changed after category update.';
  end if;

  delete from public.budget_template_categories where id = v_category_id;

  if not exists (
    select 1
    from public.expenses e
    where e.wallet_id = v_wallet_id
      and e.category_name = 'Food'
      and e.category_type = 'needs'
      and e.category_id is null
  ) then
    raise exception 'Expense snapshot invalid after category delete.';
  end if;

  begin
    insert into public.expenses (
      wallet_id,
      category_name,
      category_type,
      expense_date,
      amount,
      description
    )
    values (v_wallet_id, 'Transport', 'wants', date '2026-07-01', 1200, 'Out of period');
    raise exception 'Expected out-of-period expense insert to fail.';
  exception
    when others then
      if strpos(sqlerrm, 'No monthly budget exists') = 0 then
        raise;
      end if;
  end;
end
$$;
