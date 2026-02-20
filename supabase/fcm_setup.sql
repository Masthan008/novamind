-- =============================================================
-- FCM Token Storage Table
-- Run this in your Supabase SQL Editor
-- =============================================================

-- Table to store FCM tokens for each student
CREATE TABLE IF NOT EXISTS user_fcm_tokens (
  id BIGSERIAL PRIMARY KEY,
  student_id BIGINT NOT NULL UNIQUE,
  student_name TEXT NOT NULL DEFAULT 'Student',
  fcm_token TEXT NOT NULL,
  device_type TEXT DEFAULT 'android',  -- 'android' or 'ios'
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for fast lookups by student_id
CREATE INDEX IF NOT EXISTS idx_fcm_tokens_student_id ON user_fcm_tokens(student_id);

-- Enable RLS
ALTER TABLE user_fcm_tokens ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can insert/update their own token (using student_id from app)
-- Since we don't use Supabase Auth (app uses custom student auth),
-- we allow all authenticated + anon operations but rely on app logic.
CREATE POLICY "Allow all operations on fcm_tokens"
  ON user_fcm_tokens
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- =============================================================
-- Create chat_mentions table (used by ChatHub for @mentions)
-- =============================================================
CREATE TABLE IF NOT EXISTS chat_mentions (
  id BIGSERIAL PRIMARY KEY,
  message_id BIGINT NOT NULL,
  mentioned_user_id TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_chat_mentions_user ON chat_mentions(mentioned_user_id);

ALTER TABLE chat_mentions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow all operations on chat_mentions"
  ON chat_mentions
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- =============================================================
-- Database Webhook Triggers (for Supabase Edge Function)
-- These triggers call the Edge Function when relevant events happen
-- =============================================================

-- NOTE: Supabase Database Webhooks are configured via the Dashboard:
--   1. Go to Database > Webhooks
--   2. Create webhook for each table:
--
--   Webhook 1: "on_news_insert"
--     - Table: news
--     - Events: INSERT
--     - URL: https://<your-project-ref>.supabase.co/functions/v1/push-notification
--     - Headers: Authorization: Bearer <your-service-role-key>
--     - Payload: Include record
--
--   Webhook 2: "on_doubt_insert"
--     - Table: student_doubts
--     - Events: INSERT
--     - URL: https://<your-project-ref>.supabase.co/functions/v1/push-notification
--     - Headers: Authorization: Bearer <your-service-role-key>
--
--   Webhook 3: "on_notification_insert"
--     - Table: student_notifications
--     - Events: INSERT
--     - URL: https://<your-project-ref>.supabase.co/functions/v1/push-notification
--     - Headers: Authorization: Bearer <your-service-role-key>
--
--   Webhook 4: "on_chat_mention_insert"
--     - Table: chat_mentions
--     - Events: INSERT
--     - URL: https://<your-project-ref>.supabase.co/functions/v1/push-notification
--     - Headers: Authorization: Bearer <your-service-role-key>
--
--   Webhook 5: "on_chat_message_insert"
--     - Table: chat_messages
--     - Events: INSERT
--     - URL: https://<your-project-ref>.supabase.co/functions/v1/push-notification
--     - Headers: Authorization: Bearer <your-service-role-key>

-- =============================================================
-- Alternative: pg_net based triggers (if you prefer SQL triggers)
-- These use Supabase's pg_net extension to call the Edge Function
-- =============================================================

-- Enable pg_net extension (if not already enabled)
-- CREATE EXTENSION IF NOT EXISTS pg_net;

-- Trigger function for news
CREATE OR REPLACE FUNCTION notify_on_news_insert()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM net.http_post(
    url := 'https://gnlkgstnulfenqxvrsur.supabase.co/functions/v1/push-notification',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || current_setting('app.settings.service_role_key', true)
    ),
    body := jsonb_build_object(
      'type', 'INSERT',
      'table', 'news',
      'record', row_to_json(NEW)
    )
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger function for student_doubts
CREATE OR REPLACE FUNCTION notify_on_doubt_insert()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM net.http_post(
    url := 'https://gnlkgstnulfenqxvrsur.supabase.co/functions/v1/push-notification',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || current_setting('app.settings.service_role_key', true)
    ),
    body := jsonb_build_object(
      'type', 'INSERT',
      'table', 'student_doubts',
      'record', row_to_json(NEW)
    )
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger function for student_notifications (buzz replies)
CREATE OR REPLACE FUNCTION notify_on_student_notification_insert()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM net.http_post(
    url := 'https://gnlkgstnulfenqxvrsur.supabase.co/functions/v1/push-notification',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || current_setting('app.settings.service_role_key', true)
    ),
    body := jsonb_build_object(
      'type', 'INSERT',
      'table', 'student_notifications',
      'record', row_to_json(NEW)
    )
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger function for chat_messages
CREATE OR REPLACE FUNCTION notify_on_chat_message_insert()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM net.http_post(
    url := 'https://gnlkgstnulfenqxvrsur.supabase.co/functions/v1/push-notification',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || current_setting('app.settings.service_role_key', true)
    ),
    body := jsonb_build_object(
      'type', 'INSERT',
      'table', 'chat_messages',
      'record', row_to_json(NEW)
    )
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger function for chat_mentions
CREATE OR REPLACE FUNCTION notify_on_chat_mention_insert()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM net.http_post(
    url := 'https://gnlkgstnulfenqxvrsur.supabase.co/functions/v1/push-notification',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || current_setting('app.settings.service_role_key', true)
    ),
    body := jsonb_build_object(
      'type', 'INSERT',
      'table', 'chat_mentions',
      'record', row_to_json(NEW)
    )
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================================
-- CREATE TRIGGERS (attach functions to tables)
-- =============================================================

-- Drop existing triggers if any (safe to re-run)
DROP TRIGGER IF EXISTS trg_news_fcm ON news;
DROP TRIGGER IF EXISTS trg_doubt_fcm ON student_doubts;
DROP TRIGGER IF EXISTS trg_student_notification_fcm ON student_notifications;
DROP TRIGGER IF EXISTS trg_chat_message_fcm ON chat_messages;
DROP TRIGGER IF EXISTS trg_chat_mention_fcm ON chat_mentions;

-- Create triggers
CREATE TRIGGER trg_news_fcm
  AFTER INSERT ON news
  FOR EACH ROW EXECUTE FUNCTION notify_on_news_insert();

CREATE TRIGGER trg_doubt_fcm
  AFTER INSERT ON student_doubts
  FOR EACH ROW EXECUTE FUNCTION notify_on_doubt_insert();

CREATE TRIGGER trg_student_notification_fcm
  AFTER INSERT ON student_notifications
  FOR EACH ROW EXECUTE FUNCTION notify_on_student_notification_insert();

CREATE TRIGGER trg_chat_message_fcm
  AFTER INSERT ON chat_messages
  FOR EACH ROW EXECUTE FUNCTION notify_on_chat_message_insert();

CREATE TRIGGER trg_chat_mention_fcm
  AFTER INSERT ON chat_mentions
  FOR EACH ROW EXECUTE FUNCTION notify_on_chat_mention_insert();

-- Done! ✅
SELECT 'FCM setup complete! Run the Edge Function deployment next.' AS status;
