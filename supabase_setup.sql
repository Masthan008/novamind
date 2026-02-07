-- 1. COMMUNITY DOUBTS TABLE (Public Read, Auth Write)
create table public.doubts (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  user_email text not null, -- Store email to show who asked
  question text not null,
  subject text not null,
  is_solved boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. ANSWERS TABLE (Public Read, Auth Write)
create table public.answers (
  id uuid default gen_random_uuid() primary key,
  doubt_id uuid references public.doubts not null,
  user_id uuid references auth.users not null,
  user_email text not null,
  answer_text text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 3. PERSONAL ROUTINE (Private - Only User Sees Their Own)
create table public.personal_routines (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  activity_name text not null,
  start_time time not null,
  end_time time not null,
  day_of_week text, -- 'Monday', 'Tuesday', or 'Everyday'
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 4. DAILY DIARY (Private - Only User Sees Their Own)
create table public.diaries (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  entry_date date default CURRENT_DATE,
  title text,
  content text not null,
  mood text, -- 'Happy', 'Stressed', etc.
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 🔐 ENABLE ROW LEVEL SECURITY (The "Separate User" Logic)
alter table public.doubts enable row level security;
alter table public.answers enable row level security;
alter table public.personal_routines enable row level security;
alter table public.diaries enable row level security;

-- 🛡️ POLICIES (Rules)

-- Doubts: Everyone can see, only logged in can post
create policy "Doubts are public" on public.doubts for select using (true);
create policy "Users post own doubts" on public.doubts for insert with check (auth.uid() = user_id);

-- Answers: Everyone can see, only logged in can answer
create policy "Answers are public" on public.answers for select using (true);
create policy "Users post answers" on public.answers for insert with check (auth.uid() = user_id);

-- Routine: STRICTLY PRIVATE (Only I can see MY routine)
create policy "My Routine Select" on public.personal_routines for select using (auth.uid() = user_id);
create policy "My Routine Insert" on public.personal_routines for insert with check (auth.uid() = user_id);
create policy "My Routine Delete" on public.personal_routines for delete using (auth.uid() = user_id);

-- Diary: STRICTLY PRIVATE (Only I can see MY diary)
create policy "My Diary Select" on public.diaries for select using (auth.uid() = user_id);
create policy "My Diary Insert" on public.diaries for insert with check (auth.uid() = user_id);
