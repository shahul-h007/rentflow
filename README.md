# RentFlow

RentFlow is a shared-house rent, utilities, expenses, and settlement PWA built with Next.js 16, Supabase, and Prisma.

## Start locally

1. Install Node.js 20.9+ and run `npm install`.
2. Copy `.env.example` to `.env.local`, then add Supabase and PostgreSQL credentials. Use the transaction-mode pooler for `DATABASE_URL` and the session-mode pooler for `DIRECT_URL`.
3. Run `npm run db:generate`, `npm run db:push`, and `npm run db:seed` after provisioning the database.
4. Run `npm run dev` and open `http://localhost:3000`.

## Architecture

- `app/` is the Next.js App Router surface; the dashboard is responsive and has working quick-payment state. `/login` provides Supabase magic-link sign-in.
- `components/` houses the reusable interface.
- `lib/rent-engine.ts` holds deterministic rent splitting, carry-forward, and coverage-debt calculations.
- `prisma/schema.prisma` is the normalized domain schema, while `supabase/migrations/` contains Supabase-specific RLS/storage setup.

## Deployment

Create a Supabase project, run the Prisma schema and SQL migration, configure the four environment values in Vercel, and deploy. Use the service-role key only in server-side route handlers; never expose it to the browser.

After creating the first Supabase user, create the matching `users` row with the user UUID in `auth_id` and role `ADMIN`; this grants Shahul administrative access.
