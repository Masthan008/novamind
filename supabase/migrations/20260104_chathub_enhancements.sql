-- ============================================
-- FluxFlow ChatHub Enhancement Schema
-- ============================================

-- ============================================
-- Study Rooms Feature
-- ============================================

CREATE TABLE IF NOT EXISTS study_rooms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  code TEXT UNIQUE NOT NULL,
  description TEXT,
  created_by UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_active BOOLEAN DEFAULT TRUE,
  max_members INTEGER DEFAULT 10
);

CREATE TABLE IF NOT EXISTS room_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id UUID REFERENCES study_rooms(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_online BOOLEAN DEFAULT FALSE,
  last_seen TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  role TEXT DEFAULT 'member', -- 'admin', 'member'
  UNIQUE(room_id, user_id)
);

-- ============================================
-- Enhanced Chat Messages Table
-- ============================================

-- Add room_id column to support study room chats (nullable for global chat)
ALTER TABLE chat_messages 
  ADD COLUMN IF NOT EXISTS room_id UUID REFERENCES study_rooms(id) ON DELETE CASCADE;

-- Add new columns to existing chat_messages table
ALTER TABLE chat_messages 
  ADD COLUMN IF NOT EXISTS reply_to UUID REFERENCES chat_messages(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS is_pinned BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS reactions JSONB DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS message_type TEXT DEFAULT 'text', -- 'text', 'voice', 'file', 'code'
  ADD COLUMN IF NOT EXISTS file_url TEXT,
  ADD COLUMN IF NOT EXISTS file_name TEXT,
  ADD COLUMN IF NOT EXISTS file_size INTEGER,
  ADD COLUMN IF NOT EXISTS voice_duration INTEGER, -- in seconds
  ADD COLUMN IF NOT EXISTS is_read BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS read_at TIMESTAMP WITH TIME ZONE;

-- ============================================
-- Typing Indicators
-- ============================================

CREATE TABLE IF NOT EXISTS typing_indicators (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id UUID REFERENCES study_rooms(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(room_id, user_id)
);

-- Auto-delete typing indicators after 5 seconds
CREATE OR REPLACE FUNCTION delete_old_typing_indicators()
RETURNS TRIGGER AS $$
BEGIN
  DELETE FROM typing_indicators 
  WHERE started_at < NOW() - INTERVAL '5 seconds';
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER cleanup_typing_indicators
  AFTER INSERT ON typing_indicators
  EXECUTE FUNCTION delete_old_typing_indicators();

-- ============================================
-- Video Call Sessions
-- ============================================

CREATE TABLE IF NOT EXISTS video_calls (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id UUID REFERENCES study_rooms(id) ON DELETE CASCADE,
  call_id TEXT UNIQUE NOT NULL, -- ZegoCloud call ID
  started_by UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  ended_at TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN DEFAULT TRUE,
  participants JSONB DEFAULT '[]'::jsonb
);

-- ============================================
-- SQL Query History (for SQL Editor)
-- ============================================

CREATE TABLE IF NOT EXISTS query_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  query_text TEXT NOT NULL,
  executed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  execution_time_ms INTEGER,
  rows_affected INTEGER,
  was_successful BOOLEAN DEFAULT TRUE,
  error_message TEXT
);

-- ============================================
-- Indexes for Performance
-- ============================================

CREATE INDEX IF NOT EXISTS idx_room_members_room ON room_members(room_id);
CREATE INDEX IF NOT EXISTS idx_room_members_user ON room_members(user_id);
CREATE INDEX IF NOT EXISTS idx_room_members_online ON room_members(is_online) WHERE is_online = TRUE;
CREATE INDEX IF NOT EXISTS idx_chat_messages_room ON chat_messages(room_id) WHERE room_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_chat_messages_reply ON chat_messages(reply_to) WHERE reply_to IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_typing_room ON typing_indicators(room_id);
CREATE INDEX IF NOT EXISTS idx_video_calls_active ON video_calls(is_active) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_query_history_user ON query_history(user_id);

-- ============================================
-- Row Level Security (RLS) Policies
-- ============================================

-- Study Rooms
ALTER TABLE study_rooms ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view study rooms they're members of"
  ON study_rooms FOR SELECT
  USING (
    id IN (
      SELECT room_id FROM room_members WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can create study rooms"
  ON study_rooms FOR INSERT
  WITH CHECK (auth.uid() = created_by);

-- Room Members
ALTER TABLE room_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view room members"
  ON room_members FOR SELECT
  USING (
    room_id IN (
      SELECT room_id FROM room_members WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can join rooms"
  ON room_members FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own presence"
  ON room_members FOR UPDATE
  USING (auth.uid() = user_id);

-- Typing Indicators
ALTER TABLE typing_indicators ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view typing indicators in their rooms"
  ON typing_indicators FOR SELECT
  USING (
    room_id IN (
      SELECT room_id FROM room_members WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert their own typing indicator"
  ON typing_indicators FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Video Calls
ALTER TABLE video_calls ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view calls in their rooms"
  ON video_calls FOR SELECT
  USING (
    room_id IN (
      SELECT room_id FROM room_members WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can start calls in their rooms"
  ON video_calls FOR INSERT
  WITH CHECK (
    auth.uid() = started_by AND
    room_id IN (
      SELECT room_id FROM room_members WHERE user_id = auth.uid()
    )
  );

-- Query History
ALTER TABLE query_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own query history"
  ON query_history FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own queries"
  ON query_history FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ============================================
-- Realtime Subscriptions
-- ============================================

-- Enable realtime for new tables
ALTER PUBLICATION supabase_realtime ADD TABLE study_rooms;
ALTER PUBLICATION supabase_realtime ADD TABLE room_members;
ALTER PUBLICATION supabase_realtime ADD TABLE typing_indicators;
ALTER PUBLICATION supabase_realtime ADD TABLE video_calls;

-- ============================================
-- Helper Functions
-- ============================================

-- Generate unique room code
CREATE OR REPLACE FUNCTION generate_room_code()
RETURNS TEXT AS $$
DECLARE
  chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  result TEXT := '';
  i INTEGER;
BEGIN
  FOR i IN 1..6 LOOP
    result := result || substr(chars, floor(random() * length(chars) + 1)::int, 1);
  END LOOP;
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Update last_seen on presence change
CREATE OR REPLACE FUNCTION update_last_seen()
RETURNS TRIGGER AS $$
BEGIN
  NEW.last_seen := NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_room_member_last_seen
  BEFORE UPDATE ON room_members
  FOR EACH ROW
  WHEN (OLD.is_online IS DISTINCT FROM NEW.is_online)
  EXECUTE FUNCTION update_last_seen();
