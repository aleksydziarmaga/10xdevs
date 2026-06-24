create or replace function public.prevent_expense_snapshot_rewrite()
returns trigger
language plpgsql
as $$
begin
  if old.category_name is distinct from new.category_name then
    raise exception 'Expense category_name snapshot cannot be rewritten.';
  end if;

  if old.category_type is distinct from new.category_type then
    raise exception 'Expense category_type snapshot cannot be rewritten.';
  end if;

  return new;
end;
$$;

drop trigger if exists expenses_snapshot_immutable_guard on public.expenses;
create trigger expenses_snapshot_immutable_guard
before update of category_name, category_type
on public.expenses
for each row
execute function public.prevent_expense_snapshot_rewrite();
