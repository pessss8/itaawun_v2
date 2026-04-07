-- ============================================================
-- iTa'awun - Schema Updates for Full Vision Implementation
-- Based on System Documentation v1.0
-- ============================================================
-- Run this script in Supabase SQL Editor AFTER the base schema
-- ============================================================

-- ============================================================
-- STEP 1: Add missing columns to profiles table
-- ============================================================
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS trust_score INTEGER DEFAULT 0;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_asnaf BOOLEAN DEFAULT false;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS matric_card_url TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS income_doc_url TEXT;

CREATE INDEX IF NOT EXISTS idx_profiles_trust_score ON profiles(trust_score);
CREATE INDEX IF NOT EXISTS idx_profiles_is_asnaf ON profiles(is_asnaf);

-- ============================================================
-- STEP 2: Add missing columns to services table for gigs
-- ============================================================
ALTER TABLE services ADD COLUMN IF NOT EXISTS flag_count INTEGER DEFAULT 0;
ALTER TABLE services ADD COLUMN IF NOT EXISTS auto_post BOOLEAN DEFAULT false;
ALTER TABLE services ADD COLUMN IF NOT EXISTS expires_at TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS idx_services_flag_count ON services(flag_count);

-- ============================================================
-- STEP 3: Create gigs table (Live Gigs - Service Needed with workflow)
-- ============================================================
CREATE TABLE IF NOT EXISTS gigs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  requester_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title VARCHAR(150) NOT NULL,
  description TEXT NOT NULL,
  reward_amount NUMERIC(8,2) NOT NULL CHECK (reward_amount > 0),
  location VARCHAR(200) NOT NULL,
  status VARCHAR(20) DEFAULT 'pending_review' CHECK (status IN ('pending_review', 'live', 'grabbed', 'completed', 'rejected', 'flagged')),
  auto_post BOOLEAN DEFAULT false,
  flag_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  expires_at TIMESTAMPTZ
);

CREATE INDEX idx_gigs_requester ON gigs(requester_id);
CREATE INDEX idx_gigs_status ON gigs(status);
CREATE INDEX idx_gigs_flag_count ON gigs(flag_count);

-- ============================================================
-- STEP 4: Create gig_claims table (Tasker claims on gigs)
-- ============================================================
CREATE TABLE IF NOT EXISTS gig_claims (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  gig_id UUID NOT NULL REFERENCES gigs(id) ON DELETE CASCADE,
  tasker_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  claimed_at TIMESTAMPTZ DEFAULT now(),
  status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'completed', 'abandoned')),
  UNIQUE(gig_id),  -- One active claim per gig
  UNIQUE(tasker_id, status) -- Constraint handled in application logic
);

CREATE INDEX idx_gig_claims_gig ON gig_claims(gig_id);
CREATE INDEX idx_gig_claims_tasker ON gig_claims(tasker_id);
CREATE INDEX idx_gig_claims_status ON gig_claims(status);

-- ============================================================
-- STEP 5: Create gig_completions table (Proof photo + confirmation)
-- ============================================================
CREATE TABLE IF NOT EXISTS gig_completions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  claim_id UUID NOT NULL REFERENCES gig_claims(id) ON DELETE CASCADE,
  proof_photo_url TEXT NOT NULL,
  submitted_at TIMESTAMPTZ DEFAULT now(),
  confirmed_by_requester BOOLEAN DEFAULT false,
  confirmed_at TIMESTAMPTZ,
  dispute_raised BOOLEAN DEFAULT false,
  UNIQUE(claim_id)
);

CREATE INDEX idx_gig_completions_claim ON gig_completions(claim_id);
CREATE INDEX idx_gig_completions_dispute ON gig_completions(dispute_raised);

-- ============================================================
-- STEP 6: Create gig_flags table (Community reports)
-- ============================================================
CREATE TABLE IF NOT EXISTS gig_flags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  gig_id UUID NOT NULL REFERENCES gigs(id) ON DELETE CASCADE,
  reporter_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  reason TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(gig_id, reporter_id)  -- One report per user per gig
);

CREATE INDEX idx_gig_flags_gig ON gig_flags(gig_id);
CREATE INDEX idx_gig_flags_reporter ON gig_flags(reporter_id);

-- ============================================================
-- STEP 7: Create verifications table (Asnaf income doc verification)
-- ============================================================
CREATE TABLE IF NOT EXISTS verifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  doc_url TEXT NOT NULL,
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  reviewed_by UUID REFERENCES auth.users(id),
  reviewed_at TIMESTAMPTZ,
  rejection_reason TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_verifications_user ON verifications(user_id);
CREATE INDEX idx_verifications_status ON verifications(status);
CREATE INDEX idx_verifications_reviewer ON verifications(reviewed_by);

-- ============================================================
-- STEP 8: Create audit_logs table (Immutable trust trail)
-- ============================================================
CREATE TABLE IF NOT EXISTS audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_id UUID REFERENCES auth.users(id),
  target_id UUID,  -- Who/what was affected
  action VARCHAR(100) NOT NULL,
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_audit_logs_actor ON audit_logs(actor_id);
CREATE INDEX idx_audit_logs_target ON audit_logs(target_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_created ON audit_logs(created_at);

-- ============================================================
-- STEP 9: Create keyword_filters table (Academic integrity)
-- ============================================================
CREATE TABLE IF NOT EXISTS keyword_filters (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  keyword VARCHAR(50) NOT NULL UNIQUE,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Insert default banned keywords for academic integrity
INSERT INTO keyword_filters (keyword) VALUES
  ('assignment'), ('homework'), ('exam'), ('quiz'),
  ('thesis'), ('essay'), ('dissertation'), ('paper'),
  ('coursework'), ('term paper'), ('final project')
ON CONFLICT (keyword) DO NOTHING;

-- ============================================================
-- STEP 10: Enable RLS on new tables
-- ============================================================
ALTER TABLE gigs ENABLE ROW LEVEL SECURITY;
ALTER TABLE gig_claims ENABLE ROW LEVEL SECURITY;
ALTER TABLE gig_completions ENABLE ROW LEVEL SECURITY;
ALTER TABLE gig_flags ENABLE ROW LEVEL SECURITY;
ALTER TABLE verifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE keyword_filters ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- STEP 11: RLS Policies for gigs
-- ============================================================
-- Everyone can read live/grabbed gigs
CREATE POLICY "Anyone can read live gigs" ON gigs
  FOR SELECT
  USING (status IN ('live', 'grabbed', 'completed') OR requester_id = auth.uid());

-- Authenticated users can create gigs
CREATE POLICY "Users can create gigs" ON gigs
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = requester_id);

-- Requester can update their own gigs
CREATE POLICY "Requester can update own gigs" ON gigs
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = requester_id);

-- Admins can do everything with gigs
CREATE POLICY "Admins can manage all gigs" ON gigs
  FOR ALL
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

-- ============================================================
-- STEP 12: RLS Policies for gig_claims
-- ============================================================
CREATE POLICY "Taskers can read claims" ON gig_claims
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Taskers can create claims" ON gig_claims
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = tasker_id);

CREATE POLICY "Taskers can update own claims" ON gig_claims
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = tasker_id);

-- ============================================================
-- STEP 13: RLS Policies for gig_completions
-- ============================================================
CREATE POLICY "Anyone can read completions" ON gig_completions
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Taskers can create completions" ON gig_completions
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (SELECT 1 FROM gig_claims gc WHERE gc.id = claim_id AND gc.tasker_id = auth.uid())
  );

CREATE POLICY "Requesters can update completions" ON gig_completions
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM gig_claims gc
      JOIN gigs g ON g.id = gc.gig_id
      WHERE gc.id = claim_id AND g.requester_id = auth.uid()
    )
  );

-- ============================================================
-- STEP 14: RLS Policies for gig_flags
-- ============================================================
CREATE POLICY "Anyone can read flags" ON gig_flags
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can create flags" ON gig_flags
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = reporter_id);

-- Admins can delete flags
CREATE POLICY "Admins can delete flags" ON gig_flags
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

-- ============================================================
-- STEP 15: RLS Policies for verifications
-- ============================================================
CREATE POLICY "Users can read own verifications" ON verifications
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create verifications" ON verifications
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Admins can read all verifications
CREATE POLICY "Admins can read all verifications" ON verifications
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

-- Admins can update verifications
CREATE POLICY "Admins can update verifications" ON verifications
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

-- ============================================================
-- STEP 16: RLS Policies for audit_logs
-- ============================================================
-- Audit logs are append-only - no updates or deletes
CREATE POLICY "Anyone can read audit logs" ON audit_logs
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "System can insert audit logs" ON audit_logs
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- No update/delete policies = immutable

-- ============================================================
-- STEP 17: RLS Policies for keyword_filters
-- ============================================================
CREATE POLICY "Anyone can read keywords" ON keyword_filters
  FOR SELECT
  TO authenticated
  USING (true);

-- Only admins can manage keywords
CREATE POLICY "Admins can manage keywords" ON keyword_filters
  FOR ALL
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

-- ============================================================
-- STEP 18: Create function to check academic integrity keywords
-- ============================================================
CREATE OR REPLACE FUNCTION public.check_gig_integrity(gig_title TEXT, gig_description TEXT)
RETURNS BOOLEAN AS $$
DECLARE
  keyword_record RECORD;
BEGIN
  FOR keyword_record IN SELECT keyword FROM keyword_filters WHERE is_active = true LOOP
    IF gig_title ~* ('\m' || keyword_record.keyword || '\M')
       OR gig_description ~* ('\m' || keyword_record.keyword || '\M') THEN
      RETURN FALSE;  -- Flagged
    END IF;
  END LOOP;
  RETURN TRUE;  -- Clean
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- STEP 19: Create function to increment trust score on completion
-- ============================================================
CREATE OR REPLACE FUNCTION public.increment_trust_score(user_uuid UUID)
RETURNS void AS $$
BEGIN
  UPDATE profiles SET trust_score = trust_score + 1 WHERE id = user_uuid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- STEP 20: Create function to auto-flag gig at 3 reports
-- ============================================================
CREATE OR REPLACE FUNCTION public.check_gig_flags()
RETURNS TRIGGER AS $$
DECLARE
  flag_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO flag_count FROM gig_flags WHERE gig_id = NEW.gig_id;

  IF flag_count >= 3 THEN
    UPDATE gigs SET status = 'flagged' WHERE id = NEW.gig_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-flag gigs
DROP TRIGGER IF EXISTS trg_check_gig_flags ON gig_flags;
CREATE TRIGGER trg_check_gig_flags
  AFTER INSERT ON gig_flags
  FOR EACH ROW
  EXECUTE FUNCTION public.check_gig_flags();

-- ============================================================
-- STEP 21: Create function to log audit events
-- ============================================================
CREATE OR REPLACE FUNCTION public.log_audit(
  p_actor_id UUID,
  p_target_id UUID,
  p_action VARCHAR(100),
  p_metadata JSONB DEFAULT NULL
)
RETURNS void AS $$
BEGIN
  INSERT INTO audit_logs (actor_id, target_id, action, metadata)
  VALUES (p_actor_id, p_target_id, p_action, p_metadata);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- SCHEMA UPDATE COMPLETE
-- ============================================================
-- Next: Run this script in Supabase SQL Editor
-- Then update frontend pages to use new tables
-- ============================================================
-- Tasker Applications Table (add to schema-updates.sql)

CREATE TABLE IF NOT EXISTS tasker_applications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  reason TEXT,
  matric_card_url TEXT,
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  reviewed_by UUID REFERENCES auth.users(id),
  reviewed_at TIMESTAMPTZ,
  rejection_reason TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_tasker_applications_user ON tasker_applications(user_id);
CREATE INDEX idx_tasker_applications_status ON tasker_applications(status);

ALTER TABLE tasker_applications ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can read own applications" ON tasker_applications
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own applications" ON tasker_applications
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins can read all applications" ON tasker_applications
  FOR SELECT TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

CREATE POLICY "Admins can update applications" ON tasker_applications
  FOR UPDATE TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

