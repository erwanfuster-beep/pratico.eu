-- PRACTICO : synchronisation privee des donnees personnelles
-- A executer dans Supabase > SQL Editor. Ne modifie aucune ancienne table.
create table if not exists public.practico_data (
  user_id uuid primary key references auth.users(id) on delete cascade,
  payload jsonb not null default '{"tasks":[],"habits":[],"notes":[],"sessions":[]}'::jsonb,
  updated_at timestamptz not null default now(),
  constraint practico_data_payload_is_object check (jsonb_typeof(payload) = 'object')
);
alter table public.practico_data enable row level security;
drop policy if exists "practico_select_own" on public.practico_data;
drop policy if exists "practico_insert_own" on public.practico_data;
drop policy if exists "practico_update_own" on public.practico_data;
drop policy if exists "practico_delete_own" on public.practico_data;
create policy "practico_select_own" on public.practico_data
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "practico_insert_own" on public.practico_data
  for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "practico_update_own" on public.practico_data
  for update to authenticated using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);
create policy "practico_delete_own" on public.practico_data
  for delete to authenticated using ((select auth.uid()) = user_id);
revoke all on table public.practico_data from anon;
grant select, insert, update, delete on table public.practico_data to authenticated;
