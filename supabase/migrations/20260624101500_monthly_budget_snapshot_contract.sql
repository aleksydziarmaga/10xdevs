create table if not exists public.monthly_budget_category_snapshots (
  id uuid primary key default gen_random_uuid(),
  monthly_budget_id uuid not null references public.monthly_budgets (id) on delete cascade,
  source_category_id uuid references public.budget_template_categories (id) on delete set null,
  name text not null,
  category_type public.budget_category_type not null,
  monthly_amount integer not null check (monthly_amount >= 0),
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.monthly_budget_recurring_expense_snapshots (
  id uuid primary key default gen_random_uuid(),
  monthly_budget_id uuid not null references public.monthly_budgets (id) on delete cascade,
  source_recurring_expense_id uuid references public.recurring_expenses (id) on delete set null,
  name text not null,
  category_type public.budget_category_type not null,
  monthly_amount integer not null check (monthly_amount >= 0),
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.monthly_budget_savings_goal_snapshots (
  id uuid primary key default gen_random_uuid(),
  monthly_budget_id uuid not null references public.monthly_budgets (id) on delete cascade,
  source_savings_goal_id uuid references public.savings_goals (id) on delete set null,
  name text not null,
  target_monthly_amount integer not null check (target_monthly_amount >= 0),
  created_at timestamptz not null default timezone('utc', now())
);

create or replace function public.snapshot_monthly_budget_from_template()
returns trigger
language plpgsql
as $$
begin
  if new.template_id is null then
    return new;
  end if;

  insert into public.monthly_budget_category_snapshots (
    monthly_budget_id,
    source_category_id,
    name,
    category_type,
    monthly_amount
  )
  select
    new.id,
    btc.id,
    btc.name,
    btc.category_type,
    btc.monthly_amount
  from public.budget_template_categories btc
  where btc.template_id = new.template_id
    and btc.is_archived = false;

  insert into public.monthly_budget_recurring_expense_snapshots (
    monthly_budget_id,
    source_recurring_expense_id,
    name,
    category_type,
    monthly_amount
  )
  select
    new.id,
    re.id,
    re.name,
    re.category_type,
    re.monthly_amount
  from public.recurring_expenses re
  where re.template_id = new.template_id;

  insert into public.monthly_budget_savings_goal_snapshots (
    monthly_budget_id,
    source_savings_goal_id,
    name,
    target_monthly_amount
  )
  select
    new.id,
    sg.id,
    sg.name,
    sg.target_monthly_amount
  from public.savings_goals sg
  where sg.template_id = new.template_id;

  return new;
end;
$$;

drop trigger if exists monthly_budget_snapshot_from_template on public.monthly_budgets;
create trigger monthly_budget_snapshot_from_template
after insert on public.monthly_budgets
for each row
execute function public.snapshot_monthly_budget_from_template();
