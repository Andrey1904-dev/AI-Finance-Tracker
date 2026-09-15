-- Run this in Supabase Dashboard -> SQL Editor -> New query -> Run.
create table if not exists public.finance_operations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  client_id text not null,
  type text not null check (type in ('income','expense')),
  amount numeric(14,2) not null check (amount >= 0),
  category text not null,
  note text default '',
  date date not null,
  created_at timestamptz not null default now(),
  unique(user_id, client_id)
);

alter table public.finance_operations enable row level security;

drop policy if exists "Users can read own operations" on public.finance_operations;
drop policy if exists "Users can insert own operations" on public.finance_operations;
drop policy if exists "Users can delete own operations" on public.finance_operations;

create policy "Users can read own operations" on public.finance_operations for select using (auth.uid() = user_id);
create policy "Users can insert own operations" on public.finance_operations for insert with check (auth.uid() = user_id);
create policy "Users can delete own operations" on public.finance_operations for delete using (auth.uid() = user_id);

-- Enable anonymous sign-ins in Authentication -> Providers -> Anonymous.
