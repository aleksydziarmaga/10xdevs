do $$
declare
  required_tables text[] := array[
    'wallet',
    'budget_template',
    'budget_template_categories',
    'recurring_expenses',
    'savings_goals',
    'monthly_budgets',
    'expenses'
  ];
  required_table_name text;
begin
  foreach required_table_name in array required_tables loop
    if not exists (
      select 1
      from information_schema.tables t
      where t.table_schema = 'public'
        and t.table_name = required_table_name
    ) then
      raise exception 'Missing required table: %', required_table_name;
    end if;
  end loop;

  if not exists (
    select 1
    from pg_constraint c
    join pg_class t on t.oid = c.conrelid
    join pg_namespace n on n.oid = t.relnamespace
    where n.nspname = 'public'
      and t.relname = 'monthly_budgets'
      and c.conname = 'monthly_budgets_wallet_period_unique'
  ) then
    raise exception 'Missing monthly budget period uniqueness constraint.';
  end if;

  if not exists (
    select 1
    from information_schema.columns c
    where c.table_schema = 'public'
      and c.table_name = 'expenses'
      and c.column_name in ('category_name', 'category_type')
    group by c.table_schema, c.table_name
    having count(*) = 2
  ) then
    raise exception 'Missing expense snapshot columns.';
  end if;
end;
$$;
