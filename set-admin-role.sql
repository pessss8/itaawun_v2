-- ============================================================
-- SET ADMIN ROLE — iTa'awun
-- Run this in Supabase Dashboard > SQL Editor
-- Replace 'YOUR_ADMIN_EMAIL_HERE' with the actual admin email
-- ============================================================

-- Option 1: Update by email (use this first)
UPDATE profiles
SET role = 'admin'
WHERE email = 'YOUR_ADMIN_EMAIL_HERE';

-- Option 2: If profiles.email is null, join against auth.users instead
-- UPDATE profiles
-- SET role = 'admin'
-- WHERE id = (
--   SELECT id FROM auth.users WHERE email = 'YOUR_ADMIN_EMAIL_HERE'
-- );

-- Verify the change was applied:
SELECT id, email, role FROM profiles WHERE role = 'admin';
