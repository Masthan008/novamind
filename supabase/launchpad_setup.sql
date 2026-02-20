-- LaunchPad: Job Listings & Saved Jobs Tables
-- Run this in your Supabase SQL Editor

-- Featured / Company-direct job postings (manually curated)
CREATE TABLE IF NOT EXISTS job_listings (
  id BIGSERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  company TEXT NOT NULL,
  location TEXT DEFAULT 'India',
  description TEXT,
  redirect_url TEXT,
  apply_url TEXT,
  salary_min NUMERIC,
  salary_max NUMERIC,
  category TEXT DEFAULT '',
  contract_type TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- User-saved jobs
CREATE TABLE IF NOT EXISTS saved_jobs (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  job_id TEXT NOT NULL,
  title TEXT,
  company TEXT,
  location TEXT,
  description TEXT,
  redirect_url TEXT,
  salary_min NUMERIC,
  salary_max NUMERIC,
  category TEXT,
  contract_type TEXT,
  is_featured BOOLEAN DEFAULT false,
  saved_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, job_id)
);

-- Enable RLS
ALTER TABLE job_listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_jobs ENABLE ROW LEVEL SECURITY;

-- job_listings: anyone can read active listings
CREATE POLICY "Public read job_listings"
  ON job_listings FOR SELECT
  USING (is_active = true);

-- saved_jobs: users can only manage their own saved jobs
CREATE POLICY "Users manage own saved_jobs"
  ON saved_jobs FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_saved_jobs_user ON saved_jobs(user_id);
CREATE INDEX IF NOT EXISTS idx_saved_jobs_user_job ON saved_jobs(user_id, job_id);
CREATE INDEX IF NOT EXISTS idx_job_listings_active ON job_listings(is_active);
