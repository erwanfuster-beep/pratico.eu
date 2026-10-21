-- Practico Home - synchronisation Supabase des donnees personnelles.
-- A coller dans Supabase > SQL Editor > New query > Run.
-- Conserve les anciennes tables, les comptes et les donnees.
-- Ce script peut etre relance : les politiques deja presentes sont conservees.

create table if not exists public.practico_data (
  user_id uuid primary key references auth.users(id) on delete cascade,
  payload jsonb not null default '{"tasks":[],"habits":[],"notes":[],"sessions":[]}'::jsonb,
  updated_at timestamptz not null default now(),
  constraint practico_data_payload_is_object check (jsonb_typeof(payload) = 'object')
);

alter table public.practico_data enable row level security;

do $practico$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'practico_data'
      and policyname = 'practico_select_own'
  ) then
    create policy practico_select_own
      on public.practico_data
      for select to authenticated
      using ((select auth.uid()) = user_id);
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'practico_data'
      and policyname = 'practico_insert_own'
  ) then
    create policy practico_insert_own
      on public.practico_data
      for insert to authenticated
      with check ((select auth.uid()) = user_id);
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'practico_data'
      and policyname = 'practico_update_own'
  ) then
    create policy practico_update_own
      on public.practico_data
      for update to authenticated
      using ((select auth.uid()) = user_id)
      with check ((select auth.uid()) = user_id);
  end if;
end
$practico$;

grant select, insert, update on table public.practico_data to authenticated;

-- Le resultat doit montrer rowsecurity = true.
select tablename, rowsecurity
from pg_tables
where schemaname = 'public' and tablename = 'practico_data';
