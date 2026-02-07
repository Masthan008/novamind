-- ================================================================
-- NOTIFICATIONS TABLE FOR CAMPUS BUZZ FEATURE
-- Run this in Supabase SQL Editor
-- ================================================================

-- Create notifications table
CREATE TABLE IF NOT EXISTS public.student_notifications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  recipient_id UUID NOT NULL,        -- Who receives the notification
  sender_id UUID,                     -- Who triggered the notification
  sender_name TEXT NOT NULL,          -- Display name of sender
  message TEXT NOT NULL,              -- Notification message
  notification_type TEXT DEFAULT 'general', -- 'answer', 'mention', 'general'
  is_read BOOLEAN DEFAULT FALSE,      -- Read status
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Add index for faster queries
CREATE INDEX IF NOT EXISTS idx_notifications_recipient 
ON public.student_notifications(recipient_id, is_read);

CREATE INDEX IF NOT EXISTS idx_notifications_created 
ON public.student_notifications(created_at DESC);

-- Disable RLS for simplicity (matches existing tables)
ALTER TABLE public.student_notifications DISABLE ROW LEVEL SECURITY;

-- Grant permissions
GRANT ALL ON public.student_notifications TO anon, authenticated, service_role;

-- ================================================================
-- Optional: Add class/group columns to doubts for Campus Buzz
-- (Only run if columns don't exist)
-- ================================================================

-- ALTER TABLE public.student_doubts ADD COLUMN IF NOT EXISTS student_class TEXT;
-- ALTER TABLE public.student_doubts ADD COLUMN IF NOT EXISTS student_group TEXT;

-- ================================================================
-- DONE! The Campus Buzz feature is now ready.
-- ================================================================

SELECT 'Notifications table created successfully!' AS status;
