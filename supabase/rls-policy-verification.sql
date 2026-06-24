do $$
declare
  owner_a constant uuid := '00000000-0000-0000-0000-000000000101';
  owner_b constant uuid := '00000000-0000-0000-0000-000000000202';
  owner_a_wallet uuid;
  visible_wallet_count integer;
begin
  delete from public.expenses;
  delete from public.monthly_budgets;
  delete from public.savings_goals;
  delete from public.recurring_expenses;
  delete from public.budget_template_categories;
  delete from public.budget_template;
  delete from public.wallet;
  delete from auth.users where id in (owner_a, owner_b);

  insert into auth.users (id, email, aud, role)
  values
    (owner_a, 'owner-a@example.com', 'authenticated', 'authenticated'),
    (owner_b, 'owner-b@example.com', 'authenticated', 'authenticated');

  insert into public.wallet (owner_user_id, name) values (owner_a, 'Wallet A') returning id into owner_a_wallet;
  insert into public.wallet (owner_user_id, name) values (owner_b, 'Wallet B');

  execute 'set local role authenticated';
  perform set_config('request.jwt.claim.role', 'authenticated', true);

  perform set_config('request.jwt.claim.sub', owner_a::text, true);
  select count(*) into visible_wallet_count from public.wallet;
  if visible_wallet_count <> 1 then
    raise exception 'Owner A should only see one wallet, found %.', visible_wallet_count;
  end if;

  perform set_config('request.jwt.claim.sub', owner_b::text, true);
  select count(*) into visible_wallet_count from public.wallet;
  if visible_wallet_count <> 1 then
    raise exception 'Owner B should only see one wallet, found %.', visible_wallet_count;
  end if;

  update public.wallet
  set name = 'Wallet A Hacked'
  where id = owner_a_wallet;

  if exists (
    select 1
    from public.wallet
    where id = owner_a_wallet
      and name = 'Wallet A Hacked'
  ) then
    raise exception 'Owner B should not be able to update Owner A wallet.';
  end if;

  perform set_config('request.jwt.claim.sub', owner_a::text, true);

  update public.wallet
  set name = 'Wallet A Updated'
  where id = owner_a_wallet;

  if not exists (
    select 1
    from public.wallet
    where id = owner_a_wallet
      and name = 'Wallet A Updated'
  ) then
    raise exception 'Owner A update should succeed.';
  end if;
end
$$;
