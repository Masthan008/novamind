-- ================================================================
-- Student Features SQL Setup
-- For: Daily Routine, Diary, and Community Doubts
-- Uses students table (custom auth) instead of auth.users
-- ================================================================

-- 1. COMMUNITY DOUBTS (Public Read, Students Write)
CREATE TABLE IF NOT EXISTS public.student_doubts (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  student_id uuid REFERENCES public.students(id) ON DELETE CASCADE NOT NULL,
  student_name text NOT NULL,
  question text NOT NULL,
  subject text NOT NULL,
  is_solved boolean DEFAULT false,
  answer_count int DEFAULT 0,
  created_at timestamptz DEFAULT now() NOT NULL
);

-- 2. COMMUNITY ANSWERS (Public Read, Students Write)
CREATE TABLE IF NOT EXISTS public.student_answers (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  doubt_id uuid REFERENCES public.student_doubts(id) ON DELETE CASCADE NOT NULL,
  student_id uuid REFERENCES public.students(id) ON DELETE CASCADE NOT NULL,
  student_name text NOT NULL,
  answer_text text NOT NULL,
  is_accepted boolean DEFAULT false,
  created_at timestamptz DEFAULT now() NOT NULL
);

-- 3. PERSONAL ROUTINES (Private - Only owner sees their own)
CREATE TABLE IF NOT EXISTS public.student_routines (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  student_id uuid REFERENCES public.students(id) ON DELETE CASCADE NOT NULL,
  activity_name text NOT NULL,
  start_time time NOT NULL,
  end_time time NOT NULL,
  day_of_week text DEFAULT 'Everyday',
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now() NOT NULL
);

-- 4. PERSONAL DIARIES (Private - Only owner sees their own)
CREATE TABLE IF NOT EXISTS public.student_diaries (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  student_id uuid REFERENCES public.students(id) ON DELETE CASCADE NOT NULL,
  title text,
  content text NOT NULL,
  mood text,
  entry_date date DEFAULT CURRENT_DATE,
  created_at timestamptz DEFAULT now() NOT NULL
);

-- ================================================================
-- ROW LEVEL SECURITY (RLS) - Disable for open access with app-level auth
-- ================================================================
-- Since we're using custom auth (not Supabase Auth), we disable RLS
-- and handle security at the application level

ALTER TABLE public.student_doubts DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.student_answers DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.student_routines DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.student_diaries DISABLE ROW LEVEL SECURITY;

-- ================================================================
-- GRANTS - Allow all operations
-- ================================================================
GRANT ALL ON public.student_doubts TO anon;
GRANT ALL ON public.student_doubts TO authenticated;
GRANT ALL ON public.student_doubts TO service_role;

GRANT ALL ON public.student_answers TO anon;
GRANT ALL ON public.student_answers TO authenticated;
GRANT ALL ON public.student_answers TO service_role;

GRANT ALL ON public.student_routines TO anon;
GRANT ALL ON public.student_routines TO authenticated;
GRANT ALL ON public.student_routines TO service_role;

GRANT ALL ON public.student_diaries TO anon;
GRANT ALL ON public.student_diaries TO authenticated;
GRANT ALL ON public.student_diaries TO service_role;

-- ================================================================
-- INDEXES for better performance
-- ================================================================
CREATE INDEX IF NOT EXISTS idx_student_doubts_student_id ON public.student_doubts(student_id);
CREATE INDEX IF NOT EXISTS idx_student_doubts_created_at ON public.student_doubts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_student_answers_doubt_id ON public.student_answers(doubt_id);
CREATE INDEX IF NOT EXISTS idx_student_routines_student_id ON public.student_routines(student_id);
CREATE INDEX IF NOT EXISTS idx_student_diaries_student_id ON public.student_diaries(student_id);
CREATE INDEX IF NOT EXISTS idx_student_diaries_entry_date ON public.student_diaries(entry_date DESC);
