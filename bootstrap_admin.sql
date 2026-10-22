-- Run this ONCE after creating the Admin user in Authentication > Users.
-- It links the Auth user to the admin role and creates the shared cloud state.
insert into public.profiles (id, username, full_name, role)
select id, 'admin', 'Administrator', 'admin'
from auth.users
where email = 'smsakibhossain03@gmail.com'
on conflict (id) do update set username='admin', full_name='Administrator', role='admin';

create table if not exists public.app_state (
  id bigint primary key,
  payload jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
alter table public.app_state enable row level security;
drop policy if exists app_state_staff_select on public.app_state;
create policy app_state_staff_select on public.app_state for select to authenticated
using (public.my_role() in ('admin','manager'));
drop policy if exists app_state_staff_insert on public.app_state;
create policy app_state_staff_insert on public.app_state for insert to authenticated
with check (public.my_role() in ('admin','manager'));
drop policy if exists app_state_staff_update on public.app_state;
create policy app_state_staff_update on public.app_state for update to authenticated
using (public.my_role() in ('admin','manager')) with check (public.my_role() in ('admin','manager'));
drop policy if exists app_state_admin_delete on public.app_state;
create policy app_state_admin_delete on public.app_state for delete to authenticated
using (public.my_role()='admin');

insert into public.app_state(id,payload) values (1,'{}'::jsonb) on conflict (id) do nothing;
