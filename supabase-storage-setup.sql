-- ============================================================
-- iTa'awun - Supabase Storage + Seed Data Setup
-- Run this in Supabase SQL Editor AFTER SUPABASE_COMPLETE_SETUP.sql
-- ============================================================

-- ============================================================
-- STEP 1: Create Storage Buckets
-- (If this errors, create them manually in Dashboard → Storage)
-- ============================================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public)
VALUES ('service-images', 'service-images', true)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- STEP 2: Storage RLS Policies for avatars bucket
-- ============================================================
DROP POLICY IF EXISTS "Public avatar access" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload avatars" ON storage.objects;
DROP POLICY IF EXISTS "Users can update avatars" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete avatars" ON storage.objects;

CREATE POLICY "Public avatar access" ON storage.objects
  FOR SELECT USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload avatars" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'avatars');

CREATE POLICY "Users can update avatars" ON storage.objects
  FOR UPDATE TO authenticated
  USING (bucket_id = 'avatars');

CREATE POLICY "Users can delete avatars" ON storage.objects
  FOR DELETE TO authenticated
  USING (bucket_id = 'avatars');

-- ============================================================
-- STEP 3: Storage RLS Policies for service-images bucket
-- ============================================================
DROP POLICY IF EXISTS "Public service image access" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload service images" ON storage.objects;

CREATE POLICY "Public service image access" ON storage.objects
  FOR SELECT USING (bucket_id = 'service-images');

CREATE POLICY "Users can upload service images" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'service-images');

CREATE POLICY "Users can update service images" ON storage.objects
  FOR UPDATE TO authenticated
  USING (bucket_id = 'service-images');

-- ============================================================
-- STEP 4: Seed sample services data
-- Replace 'YOUR_ADMIN_USER_ID' with your actual admin user UUID
-- Get it from: SELECT id FROM auth.users WHERE email = 'your@email.com';
-- ============================================================

-- First get your user ID:
-- SELECT id FROM auth.users LIMIT 10;

-- Then run this (replace the UUID):
DO $$
DECLARE
  admin_id UUID;
BEGIN
  -- Use the first admin user found
  SELECT id INTO admin_id FROM profiles WHERE role = 'admin' LIMIT 1;

  IF admin_id IS NULL THEN
    -- Fall back to first user
    SELECT id INTO admin_id FROM profiles LIMIT 1;
  END IF;

  IF admin_id IS NOT NULL THEN
    -- Insert sample offered services
    INSERT INTO services (vendor_id, title, description, price, category, location, time, whatsapp, telegram, contact, type, status) VALUES
      (admin_id, 'Laundry Service - Next Day Ready', 'I will wash, dry and fold your clothes. Drop off at my room anytime before 10pm. Next day ready.', 8.00, 'laundry', 'Mahallah Z, Block B, Room 201', 'Weekdays 08:00-22:00, Weekends 09:00-21:00', '60123456789', 'laundry_bro', 'laundry@student.iium.edu.my', 'offered', 'active'),
      (admin_id, 'Food Delivery from Cafe Medina', 'I do food runs from Cafe Medina to any mahallah. Min order RM5. Delivery within 20 mins.', 2.00, 'food', 'Any Mahallah', 'Weekdays 07:00-22:00', '60123456790', 'food_runner', 'food@student.iium.edu.my', 'offered', 'active'),
      (admin_id, 'Document Printing Service', 'Print your assignments, slides, or forms. A4 black & white RM0.10/page, colour RM0.50/page. Spiral binding available.', 0.10, 'printing', 'Mahallah F, Block C, Room 102', 'Weekdays 09:00-17:00', '60123456791', 'print_service', 'print@student.iium.edu.my', 'offered', 'active'),
      (admin_id, 'Tutoring - Mathematics & Statistics', 'Final year student offering tutoring for Engineering Math, Calculus, Statistics. Group sessions available.', 30.00, 'tutoring', 'Library Discussion Room / Online', 'Weekdays 14:00-18:00, Weekends 10:00-16:00', '60123456792', 'math_tutor', 'math@student.iium.edu.my', 'offered', 'active'),
      (admin_id, 'Graphic Design - Posters & Flyers', 'I design event posters, banners, social media posts. Professional quality, delivered in 24-48 hours.', 25.00, 'design', 'Online Delivery', 'Weekdays 09:00-23:00', '60123456793', 'design_pro', 'design@student.iium.edu.my', 'offered', 'active'),
      (admin_id, 'Room Cleaning Service', 'Deep clean your mahallah room. Includes sweeping, mopping, organizing. Bring your own products or add RM5 for products.', 20.00, 'cleaning', 'Any Mahallah', 'Weekends 09:00-17:00', '60123456794', 'clean_room', 'clean@student.iium.edu.my', 'offered', 'active'),
      (admin_id, 'Event Photography', 'Photography for your events, presentations, graduations. Basic editing included. 2 hours minimum.', 80.00, 'photography', 'CFS IIUM Campus', 'Flexible - contact to arrange', '60123456795', 'photo_cfs', 'photo@student.iium.edu.my', 'offered', 'active'),
      (admin_id, 'Python & Web Coding Help', 'Help with Python assignments, HTML/CSS/JS projects. Code review and debugging sessions available.', 35.00, 'coding', 'Online / Library', 'Weekdays 15:00-21:00', '60123456796', 'code_helper', 'code@student.iium.edu.my', 'offered', 'active')
    ON CONFLICT DO NOTHING;

    -- Insert sample needed services
    INSERT INTO services (vendor_id, title, description, price, category, location, time, whatsapp, type, status) VALUES
      (admin_id, 'Need someone to print 50 pages for me', 'Need black and white printing of my thesis chapter. 50 pages A4. Can pay extra for quick delivery.', 10.00, 'printing', 'Mahallah Z', 'ASAP', '60123456797', 'needed', 'active'),
      (admin_id, 'Looking for a runner to buy groceries', 'Need someone to go to the mini market and buy some basic items. Will pay extra for the trip.', 5.00, 'runner', 'Any Mahallah', 'Today evening', '60123456798', 'needed', 'active'),
      (admin_id, 'Need tutoring for Economics subject', 'Struggling with microeconomics. Need someone patient who can explain concepts clearly. Flexible schedule.', 40.00, 'tutoring', 'Library or Online', 'Weekday evenings', '60123456799', 'needed', 'active')
    ON CONFLICT DO NOTHING;

    RAISE NOTICE 'Seed data inserted successfully for user: %', admin_id;
  ELSE
    RAISE NOTICE 'No users found. Sign up first, then run this script.';
  END IF;
END $$;

-- ============================================================
-- STEP 5: Verify setup
-- ============================================================
SELECT 'Storage buckets:' AS check;
SELECT id, name, public FROM storage.buckets WHERE id IN ('avatars', 'service-images');

SELECT 'Services count:' AS check;
SELECT type, status, COUNT(*) FROM services GROUP BY type, status;

SELECT 'Users count:' AS check;
SELECT COUNT(*) FROM profiles;

-- ============================================================
-- SETUP COMPLETE
-- After running this:
-- 1. Go to Storage in Supabase dashboard - confirm avatars and service-images buckets exist
-- 2. Refresh find.html - sample services should appear
-- 3. Test profile picture upload
-- 4. Test create service image upload
-- ============================================================
