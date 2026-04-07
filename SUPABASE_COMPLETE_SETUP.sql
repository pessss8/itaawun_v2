-- ============================================================
-- iTa'awun - Complete Supabase Database Setup
-- ============================================================
-- Run this ENTIRE script in Supabase SQL Editor
-- This creates all tables, RLS policies, and triggers
-- ============================================================

-- ============================================================
-- STEP 1: Drop existing tables (if you want fresh start)
-- ============================================================
-- WARNING: This deletes ALL data! Comment out if keeping existing data.
DROP POLICY IF EXISTS "Enable read access for all users" ON services;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON services;
DROP POLICY IF EXISTS "Enable update for own services" ON services;
DROP POLICY IF EXISTS "Enable delete for own services" ON services;
DROP TABLE IF EXISTS ratings CASCADE;
DROP TABLE IF EXISTS reports CASCADE;
DROP TABLE IF EXISTS bookings CASCADE;
DROP TABLE IF EXISTS services CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;

-- ============================================================
-- STEP 2: Create profiles table
-- ============================================================
CREATE TABLE profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text,
  full_name text,
  student_id text,
  phone text,
  role text DEFAULT 'student',  -- 'student', 'vendor', 'admin'
  is_b40 boolean DEFAULT false,
  is_approved boolean DEFAULT false,  -- For vendor approval
  cgpa numeric,
  avatar_url text,
  room_address text,
  gender text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX idx_profiles_role ON profiles(role);
CREATE INDEX idx_profiles_is_approved ON profiles(is_approved);

-- ============================================================
-- STEP 3: Create services table
-- ============================================================
CREATE TABLE services (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  vendor_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title text NOT NULL,
  description text,
  price numeric DEFAULT 0,
  category text,
  location text,
  time text,
  contact text,
  whatsapp text,
  telegram text,
  image text,
  type text DEFAULT 'offered',  -- 'offered' or 'needed'
  status text DEFAULT 'active', -- 'active', 'inactive', 'pending'
  created_at timestamptz DEFAULT now()
);

CREATE INDEX idx_services_type ON services(type);
CREATE INDEX idx_services_status ON services(status);
CREATE INDEX idx_services_vendor ON services(vendor_id);

-- ============================================================
-- STEP 4: Create bookings table
-- ============================================================
CREATE TABLE bookings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  service_id uuid REFERENCES services(id) ON DELETE SET NULL,
  student_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  vendor_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  note text,
  status text DEFAULT 'pending',  -- 'pending', 'accepted', 'done', 'cancelled'
  created_at timestamptz DEFAULT now()
);

CREATE INDEX idx_bookings_student ON bookings(student_id);
CREATE INDEX idx_bookings_vendor ON bookings(vendor_id);
CREATE INDEX idx_bookings_status ON bookings(status);

-- ============================================================
-- STEP 5: Create ratings table
-- ============================================================
CREATE TABLE ratings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id uuid REFERENCES bookings(id) ON DELETE CASCADE,
  reviewer_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  target_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  score integer NOT NULL CHECK (score >= 1 AND score <= 5),
  comment text,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX idx_ratings_target ON ratings(target_id);
CREATE INDEX idx_ratings_booking ON ratings(booking_id);

-- ============================================================
-- STEP 6: Create reports table
-- ============================================================
CREATE TABLE reports (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  service_id uuid REFERENCES services(id) ON DELETE SET NULL,
  reason text,
  status text DEFAULT 'pending',  -- 'pending', 'reviewed', 'dismissed'
  created_at timestamptz DEFAULT now()
);

CREATE INDEX idx_reports_status ON reports(status);

-- ============================================================
-- STEP 7: Enable RLS on all tables
-- ============================================================
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE services ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE ratings ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- STEP 8: RLS Policies for profiles table
-- ============================================================
-- Everyone can read basic profile info
CREATE POLICY "Public profiles are viewable by everyone" ON profiles
  FOR SELECT
  USING (true);

-- Users can insert their own profile (triggered on signup)
CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = id);

-- Admins can update any profile (for CGPA, approvals)
CREATE POLICY "Admins can update any profile" ON profiles
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles p
      WHERE p.id = auth.uid() AND p.role = 'admin'
    )
  );

-- ============================================================
-- STEP 9: RLS Policies for services table
-- ============================================================
-- Everyone can read active services
CREATE POLICY "Anyone can read active services" ON services
  FOR SELECT
  USING (status = 'active' OR type = 'needed');

-- Authenticated users can insert their own services
CREATE POLICY "Users can insert own services" ON services
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = vendor_id);

-- Users can update their own services
CREATE POLICY "Users can update own services" ON services
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = vendor_id);

-- Users can delete their own services
CREATE POLICY "Users can delete own services" ON services
  FOR DELETE
  TO authenticated
  USING (auth.uid() = vendor_id);

-- Admins can do everything with services
CREATE POLICY "Admins can manage all services" ON services
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles p
      WHERE p.id = auth.uid() AND p.role = 'admin'
    )
  );

-- ============================================================
-- STEP 10: RLS Policies for bookings table
-- ============================================================
-- Students can see their own bookings
CREATE POLICY "Students can view own bookings" ON bookings
  FOR SELECT
  TO authenticated
  USING (
    auth.uid() = student_id OR
    auth.uid() = vendor_id OR
    EXISTS (
      SELECT 1 FROM profiles p
      WHERE p.id = auth.uid() AND p.role = 'admin'
    )
  );

-- Students can create bookings
CREATE POLICY "Students can create bookings" ON bookings
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = student_id);

-- Both parties can update bookings
CREATE POLICY "Users can update own bookings" ON bookings
  FOR UPDATE
  TO authenticated
  USING (
    auth.uid() = student_id OR
    auth.uid() = vendor_id
  );

-- ============================================================
-- STEP 11: RLS Policies for ratings table
-- ============================================================
-- Everyone can read ratings
CREATE POLICY "Anyone can read ratings" ON ratings
  FOR SELECT
  USING (true);

-- Users can insert their own ratings
CREATE POLICY "Users can insert own ratings" ON ratings
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = reviewer_id);

-- ============================================================
-- STEP 12: RLS Policies for reports table
-- ============================================================
-- Admins can see all reports
CREATE POLICY "Admins can view all reports" ON reports
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles p
      WHERE p.id = auth.uid() AND p.role = 'admin'
    )
  );

-- Users can insert their own reports
CREATE POLICY "Users can insert reports" ON reports
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = reporter_id);

-- ============================================================
-- STEP 13: Create function to handle new user signup
-- ============================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (
    id,
    email,
    full_name,
    student_id,
    role,
    is_b40,
    is_approved,
    avatar_url
  )
  VALUES (
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'student_id',
    'student',  -- Default role
    false,
    false,
    NEW.raw_user_meta_data->>'avatar_url'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- STEP 14: Create trigger for new user signup
-- ============================================================
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ============================================================
-- STEP 15: Insert default admin (OPTIONAL)
-- ============================================================
-- After you sign up, manually change your role to admin:
-- UPDATE profiles SET role = 'admin' WHERE email = 'your-email@example.com';

-- ============================================================
-- SETUP COMPLETE!
-- ============================================================
-- Next steps:
-- 1. Go to Supabase Authentication > Users and sign up
-- 2. After signup, go to Table Editor > profiles
-- 3. Find your row and change role to 'admin'
-- 4. Now you can access admin.html
-- ============================================================
