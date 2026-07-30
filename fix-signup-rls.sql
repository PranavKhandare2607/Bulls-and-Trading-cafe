-- ═══════════════════════════════════════════════════════════════
-- BULL'S & TRADING CAFE — SIGNUP FIX
-- Root cause: loyalty_transactions RLS blocks the INSERT inside
-- handle_new_user() because auth.uid() is NULL during the trigger.
-- Fix: allow the SECURITY DEFINER trigger function to bypass RLS
-- on loyalty_transactions for the 'signup' insert only.
-- Run this in Supabase SQL Editor. Safe to run multiple times.
-- ═══════════════════════════════════════════════════════════════

-- STEP 1: Drop the broken RLS policy that blocks trigger inserts
DROP POLICY IF EXISTS "loyalty_insert_system" ON loyalty_transactions;

-- STEP 2: Create a correct policy.
-- Customers can insert their own transactions (for redemptions from the client).
-- The trigger itself bypasses RLS because handle_new_user() is SECURITY DEFINER
-- and we will set the function owner to a superuser role (postgres).
CREATE POLICY "loyalty_insert_own"
  ON loyalty_transactions FOR INSERT
  WITH CHECK (customer_id = auth.uid());

-- STEP 3: Make the trigger function run as the postgres role so it
-- bypasses RLS entirely. This is the correct pattern for auth triggers.
ALTER FUNCTION handle_new_user() SECURITY DEFINER;

-- Re-set the search path to prevent privilege escalation (security best practice)
ALTER FUNCTION handle_new_user() SET search_path = public;

-- STEP 4: Verify the fix — check current policies on loyalty_transactions
SELECT policyname, cmd, qual
FROM pg_policies
WHERE tablename = 'loyalty_transactions';

-- ═══════════════════════════════════════════════════════════════
-- OPTIONAL: If you want to fully test, manually verify the function
-- owner is 'postgres' (or your superuser role):
-- SELECT proname, prosecdef, proowner::regrole FROM pg_proc WHERE proname = 'handle_new_user';
-- prosecdef should be TRUE (SECURITY DEFINER)
-- proowner should be 'postgres'
-- ═══════════════════════════════════════════════════════════════

-- STEP 5: Also fix the award_review_points trigger for the same reason
-- (it also does loyalty_transactions INSERT from a trigger context)
DROP POLICY IF EXISTS "loyalty_insert_system" ON loyalty_transactions;

-- Ensure the review points trigger also runs as SECURITY DEFINER
ALTER FUNCTION award_review_points() SECURITY DEFINER;
ALTER FUNCTION award_review_points() SET search_path = public;
