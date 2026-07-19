-- The application accesses business data through authenticated Next.js routes.
-- Prevent browser clients using the public Supabase key from reading or changing
-- any public business table directly.
alter table public.users enable row level security;
alter table public.members enable row level security;
alter table public.months enable row level security;
alter table public.rent_payments enable row level security;
alter table public.rent_payment_transactions enable row level security;
alter table public.utilities enable row level security;
alter table public.utility_payments enable row level security;
alter table public.expenses enable row level security;
alter table public.expense_splits enable row level security;
alter table public.debts enable row level security;
alter table public.settings enable row level security;
alter table public.activity_logs enable row level security;
alter table public.houses enable row level security;

revoke all on all tables in schema public from anon, authenticated;

alter table public.months drop constraint if exists months_starts_on_key;
alter table public.months add constraint months_house_id_starts_on_key unique (house_id, starts_on);

drop policy if exists "authenticated upload receipt" on storage.objects;
