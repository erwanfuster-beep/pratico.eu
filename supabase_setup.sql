-- Pratico Multiverse — initial secure database setup
-- Run once in Supabase SQL Editor. Virtual currency only.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null unique check (char_length(username) between 3 and 24 and username ~ '^[A-Za-z0-9_]+$'),
  coins bigint not null default 0 check (coins >= 0),
  last_free_pack_at timestamptz,
  created_at timestamptz not null default now()
);
create table if not exists public.cards (
  id bigint generated always as identity primary key,
  universe text not null,
  name text not null,
  rarity text not null check (rarity in ('common','rare','epic','legendary','mythic','black')),
  description text not null default '',
  image_url text,
  unique (universe, name)
);
create table if not exists public.inventory (
  user_id uuid not null references public.profiles(id) on delete cascade,
  card_id bigint not null references public.cards(id),
  quantity integer not null default 0 check (quantity >= 0),
  primary key (user_id, card_id)
);
create table if not exists public.pack_openings (
  id bigint generated always as identity primary key,
  user_id uuid not null references public.profiles(id) on delete cascade,
  opened_at timestamptz not null default now(),
  cards bigint[] not null
);
create table if not exists public.market_listings (
  id bigint generated always as identity primary key,
  seller_id uuid not null references public.profiles(id) on delete cascade,
  card_id bigint not null references public.cards(id),
  price bigint not null check (price > 0),
  status text not null default 'active' check (status in ('active','sold','cancelled')),
  buyer_id uuid references public.profiles(id),
  created_at timestamptz not null default now()
);
create index if not exists market_active_idx on public.market_listings(status, created_at desc);

alter table public.profiles enable row level security;
alter table public.cards enable row level security;
alter table public.inventory enable row level security;
alter table public.pack_openings enable row level security;
alter table public.market_listings enable row level security;

create policy "profiles publicly viewable" on public.profiles for select to authenticated using (true);
create policy "cards publicly viewable" on public.cards for select to authenticated using (true);
create policy "own inventory readable" on public.inventory for select to authenticated using (user_id = (select auth.uid()));
create policy "own openings readable" on public.pack_openings for select to authenticated using (user_id = (select auth.uid()));
create policy "listings readable" on public.market_listings for select to authenticated using (true);
-- No direct insert/update/delete policies: all game mutations go through secured RPC functions.

create or replace function public.register_player(p_username text)
returns void language plpgsql security definer set search_path = '' as $$
begin
  if auth.uid() is null then raise exception 'Sign in required'; end if;
  if p_username !~ '^[A-Za-z0-9_]{3,24}$' then raise exception 'Username must be 3-24 letters, digits or underscores'; end if;
  insert into public.profiles(id,username) values (auth.uid(),p_username)
  on conflict (id) do nothing;
end; $$;

-- Chance per card: common 50%, rare 28%, epic 15%, legendary 6%,
-- mythic 0.999%, BLACK EDITION 0.001% (one in 100,000).
create or replace function public.open_free_pack()
returns bigint[] language plpgsql security definer set search_path = '' as $$
declare
  v_user uuid := auth.uid();
  v_last timestamptz;
  v_roll integer;
  v_rarity text;
  v_card bigint;
  v_cards bigint[] := array[]::bigint[];
  v_i integer;
begin
  if v_user is null then raise exception 'Sign in required'; end if;
  select last_free_pack_at into v_last from public.profiles where id = v_user for update;
  if not found then raise exception 'Create your player profile first'; end if;
  if v_last is not null and v_last + interval '10 minutes' > now() then
    raise exception 'Next free booster is not ready yet';
  end if;
  if not exists(select 1 from public.cards) then raise exception 'Card catalogue is empty'; end if;
  -- Validate all rarity pools exist to preserve advertised probabilities.
  if exists(select 1 from (values ('common'),('rare'),('epic'),('legendary'),('mythic'),('black')) as r(name)
     where not exists(select 1 from public.cards c where c.rarity = r.name)) then
    raise exception 'All six rarity pools must contain at least one card';
  end if;
  for v_i in 1..5 loop
    v_roll := floor(random() * 100000)::integer;
    v_rarity := case when v_roll < 50000 then 'common'
      when v_roll < 78000 then 'rare'
      when v_roll < 93000 then 'epic'
      when v_roll < 99000 then 'legendary'
      when v_roll < 99999 then 'mythic'
      else 'black' end;
    select id into v_card from public.cards where rarity = v_rarity order by random() limit 1;
    v_cards := array_append(v_cards,v_card);
    insert into public.inventory(user_id,card_id,quantity) values(v_user,v_card,1)
      on conflict(user_id,card_id) do update set quantity = public.inventory.quantity + 1;
  end loop;
  update public.profiles set last_free_pack_at = now(), coins = coins + 1 where id = v_user;
  insert into public.pack_openings(user_id,cards) values(v_user,v_cards);
  return v_cards;
end; $$;

create or replace function public.list_card(p_card_id bigint, p_price bigint)
returns bigint language plpgsql security definer set search_path = '' as $$
declare v_id bigint; v_qty integer;
begin
  if auth.uid() is null then raise exception 'Sign in required'; end if;
  if p_price is null or p_price < 1 then raise exception 'Invalid price'; end if;
  select quantity into v_qty from public.inventory where user_id=auth.uid() and card_id=p_card_id for update;
  if coalesce(v_qty,0) < 1 then raise exception 'Card not owned'; end if;
  update public.inventory set quantity=quantity-1 where user_id=auth.uid() and card_id=p_card_id;
  insert into public.market_listings(seller_id,card_id,price) values(auth.uid(),p_card_id,p_price) returning id into v_id;
  return v_id;
end; $$;

create or replace function public.buy_listing(p_listing_id bigint)
returns void language plpgsql security definer set search_path = '' as $$
declare v_listing public.market_listings%rowtype; v_coins bigint;
begin
  if auth.uid() is null then raise exception 'Sign in required'; end if;
  select * into v_listing from public.market_listings where id=p_listing_id for update;
  if not found or v_listing.status <> 'active' then raise exception 'Listing unavailable'; end if;
  if v_listing.seller_id=auth.uid() then raise exception 'Cannot buy your own listing'; end if;
  select coins into v_coins from public.profiles where id=auth.uid() for update;
  if coalesce(v_coins,0) < v_listing.price then raise exception 'Insufficient coins'; end if;
  update public.profiles set coins=coins-v_listing.price where id=auth.uid();
  update public.profiles set coins=coins+v_listing.price where id=v_listing.seller_id;
  insert into public.inventory(user_id,card_id,quantity) values(auth.uid(),v_listing.card_id,1)
    on conflict(user_id,card_id) do update set quantity=public.inventory.quantity+1;
  update public.market_listings set status='sold',buyer_id=auth.uid() where id=p_listing_id;
end; $$;

create or replace function public.cancel_listing(p_listing_id bigint)
returns void language plpgsql security definer set search_path = '' as $$
declare v_listing public.market_listings%rowtype;
begin
  if auth.uid() is null then raise exception 'Sign in required'; end if;
  select * into v_listing from public.market_listings where id=p_listing_id for update;
  if not found or v_listing.status <> 'active' or v_listing.seller_id <> auth.uid() then
    raise exception 'Listing unavailable';
  end if;
  update public.market_listings set status='cancelled' where id=p_listing_id;
  insert into public.inventory(user_id,card_id,quantity) values(auth.uid(),v_listing.card_id,1)
    on conflict(user_id,card_id) do update set quantity=public.inventory.quantity+1;
end; $$;

revoke all on function public.register_player(text) from public;
revoke all on function public.open_free_pack() from public;
revoke all on function public.list_card(bigint,bigint) from public;
revoke all on function public.buy_listing(bigint) from public;
revoke all on function public.cancel_listing(bigint) from public;
grant execute on function public.register_player(text) to authenticated;
grant execute on function public.open_free_pack() to authenticated;
grant execute on function public.list_card(bigint,bigint) to authenticated;
grant execute on function public.buy_listing(bigint) to authenticated;
grant execute on function public.cancel_listing(bigint) to authenticated;

-- Starter fictional placeholders; replace with properly licensed art and catalogue data.
insert into public.cards(universe,name,rarity,description) values
 ('Fortnite','Explorateur des failles','common','Carte originale de démonstration'),
 ('Minecraft','Mineur des profondeurs','rare','Carte originale de démonstration'),
 ('Rocket League','Pilote du néon','epic','Carte originale de démonstration'),
 ('Pokémon','Gardien des éclairs','legendary','Carte originale de démonstration'),
 ('Call of Duty','Opérateur fantôme','mythic','Carte originale de démonstration'),
 ('CS2','Dragon noir','black','Carte originale de démonstration BLACK EDITION')
on conflict(universe,name) do nothing;
