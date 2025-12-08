-- DANGER: This removes security checks and authentication barriers.
-- Only run this if you want to bypass Supabase Auth entirely.

-- 1. Disable Row Level Security (RLS)
-- This allows ANYONE with the API key to Read/Write data without being logged in.
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.beats DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions DISABLE ROW LEVEL SECURITY;

-- 2. Remove Foreign Key Constraints
-- This allows creating beats/transactions with User IDs that don't exist in Supabase Auth.
ALTER TABLE public.beats DROP CONSTRAINT IF EXISTS beats_producer_id_users_id_fk;
ALTER TABLE public.beats DROP CONSTRAINT IF EXISTS beats_producer_id_fkey; -- Just in case standard name was used

ALTER TABLE public.transactions DROP CONSTRAINT IF EXISTS transactions_buyer_id_users_id_fk;
ALTER TABLE public.transactions DROP CONSTRAINT IF EXISTS transactions_producer_id_users_id_fk;
ALTER TABLE public.transactions DROP CONSTRAINT IF EXISTS transactions_buyer_id_fkey;
ALTER TABLE public.transactions DROP CONSTRAINT IF EXISTS transactions_producer_id_fkey;

ALTER TABLE public.users DROP CONSTRAINT IF EXISTS users_id_fkey;
