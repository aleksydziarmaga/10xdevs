alter table public.monthly_budgets
  add constraint monthly_budgets_wallet_period_unique unique (wallet_id, period_year, period_month);

create or replace function public.enforce_expense_period_and_snapshot()
returns trigger
language plpgsql
as $$
declare
  derived_monthly_budget_id uuid;
  budget_period_start date;
  budget_wallet_id uuid;
  snapshot_category_name text;
  snapshot_category_type public.budget_category_type;
begin
  if new.amount <= 0 then
    raise exception 'Expense amount must be greater than zero.';
  end if;

  if new.monthly_budget_id is null then
    select mb.id
      into derived_monthly_budget_id
      from public.monthly_budgets mb
      where mb.wallet_id = new.wallet_id
        and mb.period_year = extract(year from new.expense_date)::integer
        and mb.period_month = extract(month from new.expense_date)::integer
      limit 1;

    new.monthly_budget_id = derived_monthly_budget_id;
  end if;

  if new.monthly_budget_id is null then
    raise exception 'No monthly budget exists for wallet % and date %.', new.wallet_id, new.expense_date;
  end if;

  select make_date(mb.period_year, mb.period_month, 1), mb.wallet_id
    into budget_period_start, budget_wallet_id
    from public.monthly_budgets mb
    where mb.id = new.monthly_budget_id;

  if budget_period_start is null then
    raise exception 'Monthly budget % does not exist.', new.monthly_budget_id;
  end if;

  if budget_wallet_id <> new.wallet_id then
    raise exception 'Monthly budget % does not belong to wallet %.', new.monthly_budget_id, new.wallet_id;
  end if;

  if date_trunc('month', new.expense_date)::date <> budget_period_start then
    raise exception
      'Expense date % must be in monthly budget period %.',
      new.expense_date,
      to_char(budget_period_start, 'YYYY-MM');
  end if;

  if new.category_id is not null then
    select btc.name, btc.category_type
      into snapshot_category_name, snapshot_category_type
      from public.budget_template_categories btc
      join public.budget_template bt on bt.id = btc.template_id
      where btc.id = new.category_id
        and bt.wallet_id = new.wallet_id
      limit 1;

    if snapshot_category_name is null then
      raise exception 'Category % does not belong to wallet %.', new.category_id, new.wallet_id;
    end if;

    new.category_name = snapshot_category_name;
    new.category_type = snapshot_category_type;
  end if;

  if new.category_name is null or btrim(new.category_name) = '' then
    raise exception 'Expense category_name snapshot is required.';
  end if;

  if new.category_type is null then
    raise exception 'Expense category_type snapshot is required.';
  end if;

  return new;
end;
$$;

drop trigger if exists expenses_period_and_snapshot_guard on public.expenses;
create trigger expenses_period_and_snapshot_guard
before insert or update of wallet_id, monthly_budget_id, category_id, expense_date, amount, category_name, category_type
on public.expenses
for each row
execute function public.enforce_expense_period_and_snapshot();

alter table public.expenses
  alter column monthly_budget_id set not null,
  alter column category_name set not null,
  alter column category_type set not null;
