create or replace function public.is_wallet_owner(target_wallet_id uuid)
returns boolean
language sql
stable
as $$
  select exists (
    select 1
    from public.wallet w
    where w.id = target_wallet_id
      and w.owner_user_id = auth.uid()
  );
$$;

grant execute on function public.is_wallet_owner(uuid) to authenticated;

drop policy if exists wallet_owner_rw on public.wallet;
create policy wallet_owner_rw on public.wallet
for all
to authenticated
using (owner_user_id = auth.uid())
with check (owner_user_id = auth.uid());

drop policy if exists budget_template_owner_rw on public.budget_template;
create policy budget_template_owner_rw on public.budget_template
for all
to authenticated
using (public.is_wallet_owner(wallet_id))
with check (public.is_wallet_owner(wallet_id));

drop policy if exists budget_template_categories_owner_rw on public.budget_template_categories;
create policy budget_template_categories_owner_rw on public.budget_template_categories
for all
to authenticated
using (
  exists (
    select 1
    from public.budget_template bt
    where bt.id = template_id
      and public.is_wallet_owner(bt.wallet_id)
  )
)
with check (
  exists (
    select 1
    from public.budget_template bt
    where bt.id = template_id
      and public.is_wallet_owner(bt.wallet_id)
  )
);

drop policy if exists recurring_expenses_owner_rw on public.recurring_expenses;
create policy recurring_expenses_owner_rw on public.recurring_expenses
for all
to authenticated
using (
  exists (
    select 1
    from public.budget_template bt
    where bt.id = template_id
      and public.is_wallet_owner(bt.wallet_id)
  )
)
with check (
  exists (
    select 1
    from public.budget_template bt
    where bt.id = template_id
      and public.is_wallet_owner(bt.wallet_id)
  )
);

drop policy if exists savings_goals_owner_rw on public.savings_goals;
create policy savings_goals_owner_rw on public.savings_goals
for all
to authenticated
using (
  exists (
    select 1
    from public.budget_template bt
    where bt.id = template_id
      and public.is_wallet_owner(bt.wallet_id)
  )
)
with check (
  exists (
    select 1
    from public.budget_template bt
    where bt.id = template_id
      and public.is_wallet_owner(bt.wallet_id)
  )
);

drop policy if exists monthly_budgets_owner_rw on public.monthly_budgets;
create policy monthly_budgets_owner_rw on public.monthly_budgets
for all
to authenticated
using (public.is_wallet_owner(wallet_id))
with check (public.is_wallet_owner(wallet_id));

drop policy if exists expenses_owner_rw on public.expenses;
create policy expenses_owner_rw on public.expenses
for all
to authenticated
using (public.is_wallet_owner(wallet_id))
with check (
  public.is_wallet_owner(wallet_id)
  and (
    category_id is null
    or exists (
      select 1
      from public.budget_template_categories btc
      join public.budget_template bt on bt.id = btc.template_id
      where btc.id = category_id
        and bt.wallet_id = wallet_id
    )
  )
);
