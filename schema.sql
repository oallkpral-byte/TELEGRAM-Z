-- TELEGRAM X starter schema. Run in Supabase SQL Editor.
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null,
  display_name text,
  created_at timestamptz not null default now()
);

create table if not exists public.conversations (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now()
);

create table if not exists public.conversation_members (
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  primary key (conversation_id, user_id)
);

create table if not exists public.messages (
  id bigint generated always as identity primary key,
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  sender_id uuid not null references public.profiles(id) on delete cascade,
  body text not null check (char_length(body) between 1 and 10000),
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.conversations enable row level security;
alter table public.conversation_members enable row level security;
alter table public.messages enable row level security;

create policy "Profiles visible to signed-in users" on public.profiles
for select to authenticated using (true);
create policy "Users can create own profile" on public.profiles
for insert to authenticated with check (auth.uid() = id);
create policy "Users can update own profile" on public.profiles
for update to authenticated using (auth.uid() = id);

create policy "Members can view conversations" on public.conversations
for select to authenticated using (
  exists (select 1 from public.conversation_members cm
          where cm.conversation_id = id and cm.user_id = auth.uid())
);
create policy "Members can view membership" on public.conversation_members
for select to authenticated using (user_id = auth.uid());
create policy "Members can read messages" on public.messages
for select to authenticated using (
  exists (select 1 from public.conversation_members cm
          where cm.conversation_id = conversation_id and cm.user_id = auth.uid())
);
create policy "Members can send messages" on public.messages
for insert to authenticated with check (
  sender_id = auth.uid() and exists (
    select 1 from public.conversation_members cm
    where cm.conversation_id = conversation_id and cm.user_id = auth.uid()
  )
);

create or replace function public.get_or_create_conversation(other_user uuid)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  me uuid := auth.uid();
  found_id uuid;
begin
  if me is null or other_user = me then
    raise exception 'Invalid user';
  end if;

  select c.id into found_id
  from conversations c
  join conversation_members a on a.conversation_id = c.id and a.user_id = me
  join conversation_members b on b.conversation_id = c.id and b.user_id = other_user
  where (select count(*) from conversation_members x where x.conversation_id = c.id) = 2
  limit 1;

  if found_id is not null then return found_id; end if;

  insert into conversations default values returning id into found_id;
  insert into conversation_members(conversation_id, user_id)
    values (found_id, me), (found_id, other_user);
  return found_id;
end;
$$;

grant execute on function public.get_or_create_conversation(uuid) to authenticated;

-- New accounts need a profile row. A username is generated from the email prefix;
-- users can later edit it from a profile screen.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  base_name text;
begin
  base_name := lower(regexp_replace(split_part(coalesce(new.email, 'user'), '@', 1), '[^a-zA-Z0-9_]', '', 'g'));
  if base_name = '' then base_name := 'user'; end if;
  insert into public.profiles(id, username, display_name)
  values (new.id, base_name || '_' || substr(new.id::text, 1, 6), base_name);
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();

-- Enable Realtime for live message updates in Supabase Dashboard if not already enabled.
