-- Apply this after Prisma has created the public tables. Supabase Auth remains the source of identity.
alter table public.users enable row level security;
alter table public.members enable row level security;
alter table public.rent_payments enable row level security;
create policy "members read active roster" on public.members for select using (active = true);
create policy "authenticated read own user" on public.users for select to authenticated using (auth_id = auth.uid()::text);
create policy "admins manage users" on public.users for all to authenticated using (role = 'ADMIN');

-- Keep receipts private and issue signed URLs from the application server.
insert into storage.buckets (id,name,public) values ('receipts','receipts',false) on conflict (id) do nothing;
create policy "authenticated upload receipt" on storage.objects for insert to authenticated with check (bucket_id = 'receipts');
