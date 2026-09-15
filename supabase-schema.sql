-- FinTrack AI — production Supabase schema
-- Run once in Supabase Dashboard -> SQL Editor -> New query -> Run.

create extension if not exists pgcrypto;

create table if not exists public.finance_operations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  client_id text not null,
  type text not null check (type in ('income','expense')),
  amount numeric(14,2) not null check (amount >= 0),
  category text not null,
  note text not null default '',
  date date not null,
  created_at timestamptz not null default now(),
  unique(user_id, client_id)
);

create index if not exists finance_operations_user_date_idx
  on public.finance_operations(user_id, date desc, created_at desc);

create table if not exists public.finance_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  budgets jsonb not null default '{}'::jsonb,
  goals jsonb not null default '[]'::jsonb,
  recurring jsonb not null default '[]'::jsonb,
  accounts jsonb not null default '[]'::jsonb,
  credits jsonb not null default '[]'::jsonb,
  credit_cards jsonb not null default '[]'::jsonb,
  categories jsonb not null default '{"expense":["Продукты","Транспорт","Жильё","Кафе и рестораны","Покупки","Здоровье","Развлечения","Связь","Образование","Подписки","Другое"],"income":["Зарплата","Подработка","Подарки","Возврат","Продажа","Инвестиции","Другое"]}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.finance_profiles add column if not exists credits jsonb not null default '[]'::jsonb;
alter table public.finance_profiles add column if not exists credit_cards jsonb not null default '[]'::jsonb;
alter table public.finance_profiles add column if not exists categories jsonb not null default '{"expense":["Продукты","Транспорт","Жильё","Кафе и рестораны","Покупки","Здоровье","Развлечения","Связь","Образование","Подписки","Другое"],"income":["Зарплата","Подработка","Подарки","Возврат","Продажа","Инвестиции","Другое"]}'::jsonb;

alter table public.finance_operations enable row level security;
alter table public.finance_profiles enable row level security;

drop policy if exists "Users can read own operations" on public.finance_operations;
drop policy if exists "Users can insert own operations" on public.finance_operations;
drop policy if exists "Users can delete own operations" on public.finance_operations;
drop policy if exists "Users can update own operations" on public.finance_operations;

create policy "Users can read own operations"
  on public.finance_operations for select
  using (auth.uid() = user_id);

create policy "Users can insert own operations"
  on public.finance_operations for insert
  with check (auth.uid() = user_id);

create policy "Users can update own operations"
  on public.finance_operations for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users can delete own operations"
  on public.finance_operations for delete
  using (auth.uid() = user_id);

drop policy if exists "Users can read own profile" on public.finance_profiles;
drop policy if exists "Users can insert own profile" on public.finance_profiles;
drop policy if exists "Users can update own profile" on public.finance_profiles;

create policy "Users can read own profile"
  on public.finance_profiles for select
  using (auth.uid() = user_id);

create policy "Users can insert own profile"
  on public.finance_profiles for insert
  with check (auth.uid() = user_id);

create policy "Users can update own profile"
  on public.finance_profiles for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Optional: create the profile automatically whenever a user registers.
create or replace function public.handle_new_user_profile()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.finance_profiles(user_id)
  values (new.id)
  on conflict (user_id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created_finance_profile on auth.users;
create trigger on_auth_user_created_finance_profile
after insert on auth.users
for each row execute procedure public.handle_new_user_profile();

create table if not exists public.telegram_link_codes (
  code text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  expires_at timestamptz not null
);
alter table public.telegram_link_codes enable row level security;
create policy "Users manage own telegram link codes" on public.telegram_link_codes for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create table if not exists public.telegram_accounts (
  telegram_chat_id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  username text,
  created_at timestamptz not null default now()
);
alter table public.telegram_accounts enable row level security;
create policy "Users view own telegram account" on public.telegram_accounts for select using (auth.uid() = user_id);

-- Telegram interactive bot session state (idempotent migration)
create table if not exists public.telegram_sessions (
  telegram_chat_id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  state jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.telegram_sessions enable row level security;
drop policy if exists "Users view own telegram sessions" on public.telegram_sessions;
create policy "Users view own telegram sessions"
  on public.telegram_sessions for select
  using (auth.uid() = user_id);
