-- PromptCraft Battle Arena table
-- Run this in your Supabase SQL editor

CREATE TABLE IF NOT EXISTS promptcraft_battles (
  id BIGSERIAL PRIMARY KEY,
  student_id BIGINT,
  student_name TEXT,
  task_id INT,
  prompt_text TEXT,
  ai_output TEXT,
  score INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Optional index for faster queries
CREATE INDEX IF NOT EXISTS idx_promptcraft_task_score ON promptcraft_battles (task_id, score DESC);
