-- iTa'awun Services Table Setup
-- Run this in Supabase SQL Editor to create/fix the services table

-- Step 1: Drop existing table and policies (WARNING: deletes all data in services table)
DROP POLICY IF EXISTS "Anyone can read active services" ON services;
DROP POLICY IF EXISTS "Users can insert own services" ON services;
DROP POLICY IF EXISTS "Users can update own services" ON services;
DROP POLICY IF EXISTS "Users can delete own services" ON services;
DROP POLICY IF EXISTS "Admins can do everything" ON services;
DROP TABLE IF EXISTS services CASCADE;

-- Step 2: Create services table with correct column names
CREATE TABLE services (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  vendor_id uuid NOT NULL,  -- References auth.users(id)
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

-- Step 3: Create indexes for faster queries
CREATE INDEX idx_services_type ON services(type);
CREATE INDEX idx_services_status ON services(status);
CREATE INDEX idx_services_vendor ON services(vendor_id);

-- Step 4: Enable Row Level Security (RLS)
ALTER TABLE services ENABLE ROW LEVEL SECURITY;

-- Step 5: RLS Policies - Simplified for MVP
-- 1. Anyone can read active services (public read for active ones)
CREATE POLICY "Enable read access for all users" ON services
  FOR SELECT
  USING (true);  -- Allow reading all services (can filter by status in app)

-- 2. Authenticated users can insert (as long as vendor_id matches their uid)
CREATE POLICY "Enable insert for authenticated users" ON services
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = vendor_id);

-- 3. Users can update their own services
CREATE POLICY "Enable update for own services" ON services
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = vendor_id);

-- 4. Users can delete their own services
CREATE POLICY "Enable delete for own services" ON services
  FOR DELETE
  TO authenticated
  USING (auth.uid() = vendor_id);

-- Step 6: Add foreign key after RLS (to avoid circular dependency)
ALTER TABLE services
  ADD CONSTRAINT fk_vendor
  FOREIGN KEY (vendor_id)
  REFERENCES auth.users(id)
  ON DELETE CASCADE;
