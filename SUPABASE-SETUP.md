# Supabase setup for FinTrack AI

## 1. Database
Open **Supabase → SQL Editor → New query**, paste `supabase-schema.sql` and press **Run**.

This creates:
- `finance_operations` — income/expense records;
- `finance_profiles` — budgets, goals, recurring payments and accounts;
- Row Level Security (RLS), so each user can access only their own data;
- a trigger that creates a profile for new accounts.

## 2. Authentication
Open **Authentication → Providers → Email** and make sure Email provider is enabled.

For easier first-time testing you can turn **Confirm email** off. If you leave confirmation on, the app will tell a new user to confirm their email before logging in.

**Anonymous sign-ins are not required.** The app does not use anonymous authentication.

## 3. Site URL
In **Authentication → URL Configuration** set the Site URL to:

`https://andrey1904-dev.github.io/AI-Finance-Tracker/`

Add the same URL to the Redirect URLs if Supabase asks for it.

## 4. What the app does
- registration with email + password;
- login/logout;
- password reset email;
- all operations are stored in Supabase;
- budgets, goals, recurring payments and accounts are stored in Supabase;
- no `localStorage` is used for application data;
- data is isolated by Supabase `auth.uid()` + RLS.

The publishable Supabase key is embedded in the frontend by design. Never put a `service_role`/secret key into `index.html`.
