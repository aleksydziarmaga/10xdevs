create extension if not exists "pgcrypto";

do $$
begin
  if not exists (
    select 1
    from pg_type t
    join pg_namespace n on n.oid = t.typnamespace
    where t.typname = 'budget_category_type'
      and n.nspname = 'public'
  ) then
    create type public.budget_category_type as enum ('needs', 'wants', 'savings');
  end if;
end
$$;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

create table if not exists public.wallet (
  id uuid primary key default gen_random_uuid(),
  owner_user_id uuid not null unique references auth.users (id) on delete cascade,
  name text not null default 'Home wallet',
  currency_code text not null default 'PLN' check (currency_code = upper(currency_code) and char_length(currency_code) = 3),
  guideline_needs_pct smallint not null default 40 check (guideline_needs_pct between 0 and 100),
  guideline_wants_pct smallint not null default 30 check (guideline_wants_pct between 0 and 100),
  guideline_savings_pct smallint not null default 30 check (guideline_savings_pct between 0 and 100),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  check (guideline_needs_pct + guideline_wants_pct + guideline_savings_pct = 100)
);

create table if not exists public.budget_template (
  id uuid primary key default gen_random_uuid(),
  wallet_id uuid not null references public.wallet (id) on delete cascade,
  name text not null,
  monthly_income_amount integer not null check (monthly_income_amount >= 0),
  is_active boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (wallet_id, name)
);

create table if not exists public.budget_template_categories (
  id uuid primary key default gen_random_uuid(),
  template_id uuid not null references public.budget_template (id) on delete cascade,
  name text not null,
  category_type public.budget_category_type not null,
  monthly_amount integer not null check (monthly_amount >= 0),
  is_archived boolean not null default false,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (template_id, name)
);

create table if not exists public.recurring_expenses (
  id uuid primary key default gen_random_uuid(),
  template_id uuid not null references public.budget_template (id) on delete cascade,
  name text not null,
  category_type public.budget_category_type not null,
  monthly_amount integer not null check (monthly_amount >= 0),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (template_id, name)
);

create table if not exists public.savings_goals (
  id uuid primary key default gen_random_uuid(),
  template_id uuid not null references public.budget_template (id) on delete cascade,
  name text not null,
  target_monthly_amount integer not null check (target_monthly_amount >= 0),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (template_id, name)
);

create table if not exists public.monthly_budgets (
  id uuid primary key default gen_random_uuid(),
  wallet_id uuid not null references public.wallet (id) on delete cascade,
  template_id uuid references public.budget_template (id) on delete set null,
  period_year integer not null check (period_year between 2000 and 2100),
  period_month integer not null check (period_month between 1 and 12),
  monthly_income_amount integer not null check (monthly_income_amount >= 0),
  guideline_needs_pct smallint not null check (guideline_needs_pct between 0 and 100),
  guideline_wants_pct smallint not null check (guideline_wants_pct between 0 and 100),
  guideline_savings_pct smallint not null check (guideline_savings_pct between 0 and 100),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  check (guideline_needs_pct + guideline_wants_pct + guideline_savings_pct = 100),
  unique (id, wallet_id)
);

create table if not exists public.expenses (
  id uuid primary key default gen_random_uuid(),
  wallet_id uuid not null references public.wallet (id) on delete cascade,
  monthly_budget_id uuid,
  category_id uuid references public.budget_template_categories (id) on delete set null,
  expense_date date not null,
  amount integer not null check (amount > 0),
  description text,
  category_name text,
  category_type public.budget_category_type,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint expenses_monthly_budget_wallet_fk
    foreign key (monthly_budget_id, wallet_id)
    references public.monthly_budgets (id, wallet_id)
    on delete restrict
);

drop trigger if exists wallet_set_updated_at on public.wallet;
create trigger wallet_set_updated_at
before update on public.wallet
for each row
execute function public.set_updated_at();

drop trigger if exists budget_template_set_updated_at on public.budget_template;
create trigger budget_template_set_updated_at
before update on public.budget_template
for each row
execute function public.set_updated_at();

drop trigger if exists budget_template_categories_set_updated_at on public.budget_template_categories;
create trigger budget_template_categories_set_updated_at
before update on public.budget_template_categories
for each row
execute function public.set_updated_at();

drop trigger if exists recurring_expenses_set_updated_at on public.recurring_expenses;
create trigger recurring_expenses_set_updated_at
before update on public.recurring_expenses
for each row
execute function public.set_updated_at();

drop trigger if exists savings_goals_set_updated_at on public.savings_goals;
create trigger savings_goals_set_updated_at
before update on public.savings_goals
for each row
execute function public.set_updated_at();

drop trigger if exists monthly_budgets_set_updated_at on public.monthly_budgets;
create trigger monthly_budgets_set_updated_at
before update on public.monthly_budgets
for each row
execute function public.set_updated_at();

drop trigger if exists expenses_set_updated_at on public.expenses;
create trigger expenses_set_updated_at
before update on public.expenses
for each row
execute function public.set_updated_at();
