import '../models/promptcraft_models.dart';

/// All PromptCraft level data — 10 levels of prompt engineering mastery
const List<PromptLevel> promptCraftLevels = [
  // ═══════════════════════════════════════════
  // LEVEL 1: What is Prompt Engineering?
  // ═══════════════════════════════════════════
  PromptLevel(
    levelNumber: 1,
    title: 'What is Prompt Engineering?',
    icon: 'lightbulb',
    description: 'Understand the basics of AI prompts',
    lessons: [
      PromptLesson(
        title: 'AI is Not Google',
        description: 'AI models generate answers, they don\'t search. Your input quality directly determines output quality.',
        assetPath: 'assets/promptcraft/level1/l1_img_ai_not_google.png',
      ),
      PromptLesson(
        title: 'What is a Prompt?',
        description: 'A prompt is the instruction you give an AI. It\'s the bridge between your intent and the AI\'s response.',
        assetPath: 'assets/promptcraft/level1/l1_flowchart_what_is_prompt.png',
      ),
      PromptLesson(
        title: 'Garbage In, Garbage Out',
        description: 'Vague prompts produce vague answers. Specific prompts produce specific, useful responses every time.',
        assetPath: 'assets/promptcraft/level1/l1_img_garbage_in_out.png',
      ),
      PromptLesson(
        title: 'Bad vs Good Prompts',
        description: 'Compare: "Tell me about Python" vs "Explain Python list comprehensions with 3 examples for beginners".',
        assetPath: 'assets/promptcraft/level1/l1_flowchart_bad_vs_good.png',
        tryPrompt: 'Explain Python list comprehensions with 3 examples. Include syntax breakdown and when to use them vs regular loops.',
      ),
    ],
    examQuestions: [
      PromptExamQuestion(
        question: 'What is a prompt in AI context?',
        options: ['A search query', 'An instruction given to an AI model', 'A programming language', 'A database query'],
        correctIndex: 1,
        explanation: 'A prompt is the instruction or input you give to an AI model to generate a response.',
      ),
      PromptExamQuestion(
        question: 'Why does "Tell me about coding" produce poor results?',
        options: ['AI doesn\'t know coding', 'The prompt is too vague', 'AI only works with images', 'The model is broken'],
        correctIndex: 1,
        explanation: 'Vague prompts lack specificity, so the AI has to guess what you actually want.',
      ),
      PromptExamQuestion(
        question: 'What does "Garbage In, Garbage Out" mean for prompts?',
        options: ['AI produces trash', 'Bad input = bad output', 'You need to clean your data', 'AI models are unreliable'],
        correctIndex: 1,
        explanation: 'The quality of your prompt directly determines the quality of the AI response.',
      ),
      PromptExamQuestion(
        question: 'Which is a better prompt?',
        options: ['Tell me about arrays', 'Explain arrays in Java with code examples for sorting', 'Arrays?', 'What are arrays in programming'],
        correctIndex: 1,
        explanation: 'It specifies the language (Java), asks for code examples, and narrows the topic (sorting).',
      ),
      PromptExamQuestion(
        question: 'How is AI different from a search engine?',
        options: ['AI is faster', 'AI generates answers, search engines find existing pages', 'AI uses the internet', 'There is no difference'],
        correctIndex: 1,
        explanation: 'AI generates new text based on patterns, while search engines find existing web pages.',
      ),
    ],
  ),

  // ═══════════════════════════════════════════
  // LEVEL 2: Anatomy of a Perfect Prompt
  // ═══════════════════════════════════════════
  PromptLevel(
    levelNumber: 2,
    title: 'Anatomy of a Perfect Prompt',
    icon: 'architecture',
    description: 'Learn the 5 building blocks of great prompts',
    lessons: [
      PromptLesson(
        title: 'The 5 Prompt Components',
        description: 'Every great prompt has: Role, Context, Task, Format, and Constraints. Master these five parts.',
        assetPath: 'assets/promptcraft/level2/l2_flowchart_prompt_anatomy.png',
      ),
      PromptLesson(
        title: 'Role + Context + Task',
        description: 'Role: Who should AI be? Context: Background info. Task: What to do. These three are essential.',
        assetPath: 'assets/promptcraft/level2/l2_img_role_context_task.png',
        tryPrompt: 'You are a senior Python developer. A junior developer is confused about decorators. Explain decorators with 3 practical examples, starting from the simplest.',
      ),
      PromptLesson(
        title: 'Format + Constraints',
        description: 'Format: How should the answer look? Constraints: Limits on length, tone, or scope. Controls output shape.',
        assetPath: 'assets/promptcraft/level2/l2_img_format_constraint.png',
        tryPrompt: 'You are a tech writer. Explain REST APIs to a beginner. Format: Use numbered steps with code examples. Constraint: Keep under 300 words, no jargon.',
      ),
      PromptLesson(
        title: 'With vs Without Parts',
        description: 'See the dramatic difference when you use all 5 parts vs a bare prompt. Structure transforms results.',
        assetPath: 'assets/promptcraft/level2/l2_flowchart_with_without_parts.png',
      ),
    ],
    examQuestions: [
      PromptExamQuestion(
        question: 'What are the 5 parts of a perfect prompt?',
        options: ['Who, What, When, Where, Why', 'Role, Context, Task, Format, Constraint', 'Input, Process, Output, Review, Refine', 'Subject, Verb, Object, Adjective, Adverb'],
        correctIndex: 1,
        explanation: 'The 5 building blocks are: Role, Context, Task, Format, and Constraint.',
      ),
      PromptExamQuestion(
        question: 'What does the "Role" component do?',
        options: ['Sets the output format', 'Tells AI who to act as', 'Limits the response length', 'Provides background info'],
        correctIndex: 1,
        explanation: 'Role tells the AI what persona or expertise to adopt when responding.',
      ),
      PromptExamQuestion(
        question: 'Which prompt part controls response length?',
        options: ['Role', 'Context', 'Task', 'Constraint'],
        correctIndex: 3,
        explanation: 'Constraints limit the output — length, tone, complexity, or scope.',
      ),
      PromptExamQuestion(
        question: '"Respond as a bullet-point list" is which part?',
        options: ['Role', 'Context', 'Format', 'Constraint'],
        correctIndex: 2,
        explanation: 'Format specifies HOW the answer should be structured.',
      ),
      PromptExamQuestion(
        question: 'What happens without the Context component?',
        options: ['AI crashes', 'AI gives generic answers lacking specificity', 'Nothing changes', 'AI refuses to answer'],
        correctIndex: 1,
        explanation: 'Without context, AI lacks background info and gives generic responses.',
      ),
    ],
  ),

  // ═══════════════════════════════════════════
  // LEVEL 3: Prompt Patterns & Frameworks
  // ═══════════════════════════════════════════
  PromptLevel(
    levelNumber: 3,
    title: 'Prompt Patterns & Frameworks',
    icon: 'pattern',
    description: 'Master reusable prompt templates',
    lessons: [
      PromptLesson(
        title: 'The Expert Pattern',
        description: 'Assign AI a specific expert role. "You are a 20-year cybersecurity expert" gives deeper, authoritative answers.',
        assetPath: 'assets/promptcraft/level3/l3_img_expert_pattern.png',
        tryPrompt: 'You are a cybersecurity expert with 20 years of experience. A startup founder asks: What are the top 5 security mistakes new SaaS companies make? Give actionable fixes for each.',
      ),
      PromptLesson(
        title: 'The Ladder Pattern',
        description: 'Build understanding step by step. Start simple, add complexity gradually. Perfect for learning new topics.',
        assetPath: 'assets/promptcraft/level3/l3_img_ladder_pattern.png',
        tryPrompt: 'Explain machine learning in 5 levels of complexity: 1) Like I\'m 10 years old, 2) High school student, 3) CS undergraduate, 4) Graduate student, 5) PhD researcher.',
      ),
      PromptLesson(
        title: 'Chain of Thought',
        description: 'Ask AI to think step-by-step before answering. Forces logical reasoning and reduces errors dramatically.',
        assetPath: 'assets/promptcraft/level3/l3_flowchart_chain_of_thought.png',
        tryPrompt: 'Think step by step: A farmer has 17 sheep. All but 9 die. How many are left? Show your complete reasoning process before giving the final answer.',
      ),
      PromptLesson(
        title: 'The Comparator Pattern',
        description: 'Ask AI to compare options with pros/cons. Great for decision-making on frameworks, tools, or approaches.',
        assetPath: 'assets/promptcraft/level3/l3_img_comparator_pattern.png',
        tryPrompt: 'Compare React vs Flutter vs SwiftUI for mobile app development. Create a table with: Learning curve, Performance, Community, Job market, Best for. Give a final recommendation for a student.',
      ),
      PromptLesson(
        title: 'Patterns Overview',
        description: 'Six core patterns: Expert, Ladder, Critic, Template, Comparator, Chain of Thought. Mix them for powerful results.',
        assetPath: 'assets/promptcraft/level3/l3_flowchart_patterns_overview.png',
      ),
    ],
    examQuestions: [
      PromptExamQuestion(
        question: 'What is the Expert Pattern?',
        options: ['Asking AI to be brief', 'Assigning AI a specific expert role', 'Using bullet points', 'Giving examples'],
        correctIndex: 1,
        explanation: 'The Expert Pattern gives AI a specific expert persona for deeper, authoritative responses.',
      ),
      PromptExamQuestion(
        question: '"Explain X at 5 difficulty levels" uses which pattern?',
        options: ['Expert', 'Ladder', 'Comparator', 'Chain of Thought'],
        correctIndex: 1,
        explanation: 'The Ladder Pattern builds understanding step by step, from simple to complex.',
      ),
      PromptExamQuestion(
        question: 'What does Chain of Thought prompting do?',
        options: ['Makes AI faster', 'Forces step-by-step reasoning', 'Shortens responses', 'Adds images'],
        correctIndex: 1,
        explanation: 'Chain of Thought forces AI to reason step-by-step, reducing errors in logic and math.',
      ),
      PromptExamQuestion(
        question: 'Which pattern is best for choosing between frameworks?',
        options: ['Expert', 'Ladder', 'Comparator', 'Template'],
        correctIndex: 2,
        explanation: 'The Comparator Pattern is designed for comparing options with structured pros/cons.',
      ),
      PromptExamQuestion(
        question: 'How many core prompt patterns are covered?',
        options: ['3', '4', '5', '6'],
        correctIndex: 3,
        explanation: 'Six patterns: Expert, Ladder, Critic, Template, Comparator, Chain of Thought.',
      ),
    ],
  ),

  // ═══════════════════════════════════════════
  // LEVEL 4: Advanced Techniques
  // ═══════════════════════════════════════════
  PromptLevel(
    levelNumber: 4,
    title: 'Advanced Techniques',
    icon: 'tune',
    description: 'Few-shot, temperature, and prompt chaining',
    lessons: [
      PromptLesson(
        title: 'Zero-Shot vs Few-Shot',
        description: 'Zero-shot: no examples. Few-shot: give 2-3 examples first. Few-shot dramatically improves output consistency.',
        assetPath: 'assets/promptcraft/level4/l4_img_zeroshot_vs_fewshot.png',
        tryPrompt: 'Classify these reviews as Positive, Negative, or Neutral.\n\nExamples:\n"Great product!" → Positive\n"Terrible service" → Negative\n"It was okay" → Neutral\n\nNow classify:\n1. "Absolutely loved the speed"\n2. "Not worth the money"\n3. "Decent but nothing special"',
      ),
      PromptLesson(
        title: 'Temperature Control',
        description: 'Low temp (0.1): precise, factual — for code/math. High temp (0.9): creative, varied — for stories/brainstorming.',
        assetPath: 'assets/promptcraft/level4/l4_img_temperature_slider.png',
      ),
      PromptLesson(
        title: 'Prompt Chaining',
        description: 'Break complex tasks into linked prompts. Output of Prompt 1 feeds into Prompt 2. Like a pipeline for AI.',
        assetPath: 'assets/promptcraft/level4/l4_flowchart_prompt_chaining.png',
        tryPrompt: 'Step 1: List 5 trending topics in AI for 2024.\n\n(After getting results, use this as Step 2):\nFor the topic "[pick one from above]", create a detailed blog outline with: title, 5 sections, key points per section, and a compelling introduction.',
      ),
      PromptLesson(
        title: 'Few-Shot in Action',
        description: 'See how providing examples transforms AI output. Pattern recognition through demonstration is incredibly powerful.',
        assetPath: 'assets/promptcraft/level4/l4_flowchart_fewshot.png',
      ),
    ],
    examQuestions: [
      PromptExamQuestion(
        question: 'What is few-shot prompting?',
        options: ['Giving AI a short prompt', 'Providing examples before the actual task', 'Using multiple AI models', 'Sending fewer requests'],
        correctIndex: 1,
        explanation: 'Few-shot prompting provides 2-3 examples so AI learns the expected pattern.',
      ),
      PromptExamQuestion(
        question: 'For writing code, what temperature should you use?',
        options: ['0.9 (high)', '0.5 (medium)', '0.1 (low)', 'Temperature doesn\'t matter'],
        correctIndex: 2,
        explanation: 'Low temperature (0.1-0.3) produces precise, deterministic output — ideal for code.',
      ),
      PromptExamQuestion(
        question: 'What is prompt chaining?',
        options: ['Sending the same prompt twice', 'Linking multiple prompts where output feeds into the next', 'Using chain of thought', 'Repeating keywords'],
        correctIndex: 1,
        explanation: 'Prompt chaining links sequential prompts — each builds on the previous output.',
      ),
      PromptExamQuestion(
        question: 'Zero-shot means:',
        options: ['No examples given', 'Zero errors expected', 'Using zero temperature', 'Not using AI'],
        correctIndex: 0,
        explanation: 'Zero-shot means giving AI a task with no examples — it relies on its training alone.',
      ),
      PromptExamQuestion(
        question: 'High temperature (0.9) is best for:',
        options: ['Math calculations', 'Code generation', 'Creative writing and brainstorming', 'Factual Q&A'],
        correctIndex: 2,
        explanation: 'High temperature increases randomness/creativity — perfect for brainstorming and stories.',
      ),
    ],
  ),

  // ═══════════════════════════════════════════
  // LEVEL 5: Prompt Chaining Mastery
  // ═══════════════════════════════════════════
  PromptLevel(
    levelNumber: 5,
    title: 'Prompt Chaining Mastery',
    icon: 'link',
    description: 'Build complex multi-step AI workflows',
    lessons: [
      PromptLesson(
        title: 'Why Chain Prompts?',
        description: 'Single prompts hit quality ceilings. Chaining breaks big tasks into focused steps for better results overall.',
        assetPath: 'assets/promptcraft/level5/l5_flowchart_chain_advanced.png',
      ),
      PromptLesson(
        title: 'Study Plan Chain',
        description: 'Chain: Analyze syllabus → Identify weak topics → Create schedule → Generate practice questions. Each step refines.',
        assetPath: 'assets/promptcraft/level5/l5_img_chain_example_study.png',
        tryPrompt: 'I\'m preparing for a Data Structures exam in 2 weeks. Topics: Arrays, Linked Lists, Trees, Graphs, Sorting.\n\nStep 1: Analyze these topics and rank them by difficulty for a beginner.\nStep 2: Create a day-by-day study plan for 14 days.\nStep 3: For the hardest topic, generate 5 practice problems with solutions.',
      ),
      PromptLesson(
        title: 'Code Project Chain',
        description: 'Chain: Define requirements → Design architecture → Write code → Add tests → Review. AI as your dev team.',
        assetPath: 'assets/promptcraft/level5/l5_img_chain_example_code.png',
        tryPrompt: 'I want to build a REST API for a todo app.\n\nStep 1: List all endpoints needed with HTTP methods.\nStep 2: Design the database schema.\nStep 3: Write the main server code in Node.js/Express.\nStep 4: Write 3 unit tests for the most important endpoint.',
      ),
    ],
    examQuestions: [
      PromptExamQuestion(
        question: 'Why is prompt chaining better than one long prompt?',
        options: ['It\'s faster', 'Each step is focused, producing higher quality', 'AI prefers short prompts', 'It uses less tokens'],
        correctIndex: 1,
        explanation: 'Focused steps let AI concentrate on one task at a time, improving quality.',
      ),
      PromptExamQuestion(
        question: 'In a study plan chain, what comes first?',
        options: ['Generate questions', 'Create schedule', 'Analyze syllabus', 'Review progress'],
        correctIndex: 2,
        explanation: 'You must analyze the syllabus first to understand what needs to be studied.',
      ),
      PromptExamQuestion(
        question: 'How many steps should a prompt chain typically have?',
        options: ['Exactly 2', '3-5 focused steps', '10+ steps', 'Only 1'],
        correctIndex: 1,
        explanation: '3-5 steps is the sweet spot — enough to break down complexity without losing coherence.',
      ),
      PromptExamQuestion(
        question: 'What\'s the key rule of prompt chaining?',
        options: ['Use the same prompt repeatedly', 'Output of step N feeds into step N+1', 'Always use the Expert Pattern', 'Keep all steps identical'],
        correctIndex: 1,
        explanation: 'Each step\'s output becomes input/context for the next step in the chain.',
      ),
      PromptExamQuestion(
        question: 'Which task benefits most from chaining?',
        options: ['Simple factual question', 'Building a complete project from scratch', 'Translating one sentence', 'Defining a word'],
        correctIndex: 1,
        explanation: 'Complex, multi-faceted tasks benefit most from being broken into chained steps.',
      ),
    ],
  ),

  // ═══════════════════════════════════════════
  // LEVEL 6: Domain-Specific Prompting
  // ═══════════════════════════════════════════
  PromptLevel(
    levelNumber: 6,
    title: 'Domain-Specific Prompting',
    icon: 'category',
    description: 'Specialized prompts for coding, studying, and careers',
    lessons: [
      PromptLesson(
        title: 'Coding Prompts Mastery',
        description: 'For code: specify language, version, style guide, error handling, and edge cases. Get production-ready output.',
        assetPath: 'assets/promptcraft/level6/l6_flowchart_domain_coding.png',
        tryPrompt: 'You are a senior Python developer. Write a function that validates email addresses using regex. Requirements:\n- Handle edge cases (empty, None, special chars)\n- Return bool\n- Include docstring\n- Add 5 unit tests\n- Follow PEP 8',
      ),
      PromptLesson(
        title: 'Study & Learning Prompts',
        description: 'For studying: specify subject, difficulty, exam format, and time constraints. AI becomes your personal tutor.',
        assetPath: 'assets/promptcraft/level6/l6_flowchart_domain_study.png',
        tryPrompt: 'You are an expert CS tutor. I have a mid-term exam on Operating Systems tomorrow. Topics: Process scheduling, Deadlocks, Memory management. Create a 1-hour crash course plan with key formulas, mnemonics, and 3 likely exam questions with answers.',
      ),
      PromptLesson(
        title: 'Coding Cheatsheet',
        description: 'Prompt templates for debugging, refactoring, code reviews, and API documentation. Save these frameworks.',
        assetPath: 'assets/promptcraft/level6/l6_img_cheatsheet_coding.png',
      ),
      PromptLesson(
        title: 'Career Prompts',
        description: 'Prompts for resume reviews, interview prep, LinkedIn optimization, and career roadmaps. AI as career coach.',
        assetPath: 'assets/promptcraft/level6/l6_img_cheatsheet_career.png',
        tryPrompt: 'You are a tech recruiter at Google. Review this resume summary for a fresh graduate applying for a Software Engineer role:\n\n"I am a hardworking student who knows Java and Python."\n\nRewrite it to be compelling, specific, and ATS-friendly. Include quantifiable achievements even if estimated.',
      ),
      PromptLesson(
        title: 'Master Checklist',
        description: 'Your go-to checklist before sending any prompt: Role? Context? Task? Format? Constraints? Examples? Done.',
        assetPath: 'assets/promptcraft/level6/l6_img_master_checklist.png',
      ),
    ],
    examQuestions: [
      PromptExamQuestion(
        question: 'For code generation, you should always specify:',
        options: ['Just the language name', 'Language, style guide, error handling, and edge cases', 'Only the function name', 'The exact code you want'],
        correctIndex: 1,
        explanation: 'Specifying language, style, error handling, and edge cases produces production-quality code.',
      ),
      PromptExamQuestion(
        question: 'What makes a great study prompt?',
        options: ['Just say "help me study"', 'Specify subject, difficulty, exam format, and time', 'Ask for all answers', 'Copy the textbook'],
        correctIndex: 1,
        explanation: 'Specificity helps AI tailor explanations to your exact exam needs.',
      ),
      PromptExamQuestion(
        question: 'For a resume review prompt, what role should you assign?',
        options: ['A student', 'A recruiter or hiring manager at a specific company', 'A programmer', 'A teacher'],
        correctIndex: 1,
        explanation: 'A recruiter/hiring manager perspective gives the most useful resume feedback.',
      ),
      PromptExamQuestion(
        question: 'The master checklist includes:',
        options: ['Only Role and Task', 'Role, Context, Task, Format, Constraints, Examples', 'Just the question', 'Temperature and model'],
        correctIndex: 1,
        explanation: 'The complete checklist covers all prompt components for optimal results.',
      ),
      PromptExamQuestion(
        question: 'What should you include in a debugging prompt?',
        options: ['Just "fix my code"', 'Error message, code, language, expected vs actual behavior', 'The entire project', 'Only the error message'],
        correctIndex: 1,
        explanation: 'Include: the error, relevant code, language, and expected vs actual behavior.',
      ),
    ],
  ),

  // ═══════════════════════════════════════════
  // LEVEL 7: Image Prompt Lab (Special)
  // ═══════════════════════════════════════════
  PromptLevel(
    levelNumber: 7,
    title: 'Image Prompt Lab',
    icon: 'image',
    description: 'Master the art of image generation prompts',
    isSpecialLevel: true,
    lessons: [
      PromptLesson(
        title: 'Image Prompt Anatomy',
        description: 'Structure: Subject + Style + Colors + Composition + Lighting + Quality modifiers. Order matters for emphasis.',
        assetPath: 'assets/promptcraft/level7/l7_flowchart_image_anatomy.png',
      ),
      PromptLesson(
        title: 'Style Keywords',
        description: 'Digital art, watercolor, isometric, flat design, photorealistic, anime, pixel art — each produces vastly different results.',
        assetPath: 'assets/promptcraft/level7/l7_img_style_grid.png',
      ),
      PromptLesson(
        title: 'Composition Guide',
        description: 'Rule of thirds, symmetrical, bird\'s eye, close-up, wide angle — composition keywords direct the camera angle.',
        assetPath: 'assets/promptcraft/level7/l7_img_composition_guide.png',
      ),
    ],
    examQuestions: [
      PromptExamQuestion(
        question: 'What comes first in an image prompt?',
        options: ['Style', 'Colors', 'Subject (what to draw)', 'Quality modifiers'],
        correctIndex: 2,
        explanation: 'Subject always comes first — tell the AI WHAT before telling it HOW.',
      ),
      PromptExamQuestion(
        question: 'Which keyword produces a flat, clean illustration?',
        options: ['Photorealistic', 'Flat design, minimal illustration', 'Oil painting', 'Grunge texture'],
        correctIndex: 1,
        explanation: 'Flat design and minimal illustration produce clean, icon-like images.',
      ),
      PromptExamQuestion(
        question: '"Bird\'s eye view" controls which aspect?',
        options: ['Color palette', 'Style', 'Composition/camera angle', 'Lighting'],
        correctIndex: 2,
        explanation: 'It\'s a composition keyword that sets the camera angle to overhead view.',
      ),
      PromptExamQuestion(
        question: 'For a futuristic tech image, which colors work best?',
        options: ['Warm earth tones', 'Pastels', 'Cyan, neon blue, purple', 'Black and white only'],
        correctIndex: 2,
        explanation: 'Cyan, neon blue, and purple are classic futuristic/tech color palettes.',
      ),
      PromptExamQuestion(
        question: 'What do "quality modifiers" do in an image prompt?',
        options: ['Change the subject', 'Boost detail/resolution keywords like "4K, detailed, sharp"', 'Change colors', 'Set the background'],
        correctIndex: 1,
        explanation: 'Quality modifiers like "4K", "highly detailed", "sharp focus" enhance output quality.',
      ),
    ],
  ),

  // ═══════════════════════════════════════════
  // LEVEL 8: Prompt Battle Arena (Special)
  // ═══════════════════════════════════════════
  PromptLevel(
    levelNumber: 8,
    title: 'Prompt Battle Arena',
    icon: 'swords',
    description: 'Compete with others in prompt challenges',
    isSpecialLevel: true,
    lessons: [
      PromptLesson(
        title: 'How Battles Work',
        description: 'Write the best prompt for a task. AI scores your output. Compare with other students. Top prompts win.',
        assetPath: 'assets/promptcraft/level8/l8_flowchart_battle_flow.png',
      ),
      PromptLesson(
        title: 'Scoring Criteria',
        description: 'Prompts are scored on: Completeness, Specificity, Structure, Creativity, and Result Quality. Max 100 points.',
        assetPath: 'assets/promptcraft/level8/l8_img_scoring_rubric.png',
      ),
      PromptLesson(
        title: 'Battle Layout',
        description: 'See your prompt vs others side-by-side. AI generates pros/cons for each. Learn from the best submissions.',
        assetPath: 'assets/promptcraft/level8/l8_img_comparison_layout.png',
      ),
    ],
    examQuestions: [
      PromptExamQuestion(
        question: 'What determines your battle score?',
        options: ['Speed only', 'Completeness, specificity, structure, creativity, result quality', 'Prompt length', 'Number of words'],
        correctIndex: 1,
        explanation: 'Five criteria: Completeness, Specificity, Structure, Creativity, and Result Quality.',
      ),
      PromptExamQuestion(
        question: 'In a prompt battle, what can you learn from others?',
        options: ['Nothing useful', 'Different approaches and techniques for the same task', 'How to copy prompts', 'Shortcuts to cheat'],
        correctIndex: 1,
        explanation: 'Comparing prompts shows you alternative approaches and new techniques.',
      ),
      PromptExamQuestion(
        question: 'What\'s the max battle score?',
        options: ['50', '75', '100', '200'],
        correctIndex: 2,
        explanation: 'Maximum score is 100 across all five scoring criteria.',
      ),
      PromptExamQuestion(
        question: 'Why compare prompts side-by-side?',
        options: ['To find a winner', 'To understand why some prompts produce better results', 'For entertainment', 'To embarrass others'],
        correctIndex: 1,
        explanation: 'Side-by-side comparison reveals what makes certain prompt techniques more effective.',
      ),
      PromptExamQuestion(
        question: 'How are battle results evaluated?',
        options: ['Manually by teachers', 'AI evaluates and scores each submission', 'Random scores', 'Student votes'],
        correctIndex: 1,
        explanation: 'AI analyzes each prompt and its output, then provides objective scoring.',
      ),
    ],
  ),

  // ═══════════════════════════════════════════
  // LEVEL 9: Real-World Projects
  // ═══════════════════════════════════════════
  PromptLevel(
    levelNumber: 9,
    title: 'Real-World Projects',
    icon: 'work',
    description: 'Apply skills to 3 complete projects',
    lessons: [
      PromptLesson(
        title: 'Project 1: Study Plan Generator',
        description: 'Build a complete study plan using chained prompts: Syllabus analysis → Weak areas → Schedule → Resources → Practice.',
        assetPath: 'assets/promptcraft/level9/l9_flowchart_project1_studyplan.png',
        tryPrompt: 'I\'m a 3rd year CSE student preparing for end-semester exams. Subjects: DBMS, Computer Networks, Operating Systems. Exam starts in 3 weeks. I\'m weakest in Computer Networks.\n\nCreate a complete study plan:\n1. Priority rank the subjects\n2. Weekly schedule (3 weeks)\n3. Best YouTube channels for each\n4. 5 most likely exam questions per subject',
      ),
      PromptLesson(
        title: 'Project 2: Debug Assistant',
        description: 'Create a multi-step debugging workflow: Error analysis → Root cause → Fix suggestion → Prevention strategy.',
        assetPath: 'assets/promptcraft/level9/l9_flowchart_project2_debug.png',
        tryPrompt: 'You are a senior debugger. I have this Python error:\n\nTypeError: can\'t multiply sequence by non-int of type \'float\'\n\nCode: result = "hello" * 2.5\n\n1. Explain what caused this error\n2. Show 3 ways to fix it\n3. Explain the underlying Python type system rule\n4. Give a pattern to prevent similar errors',
      ),
      PromptLesson(
        title: 'Project 3: Research Helper',
        description: 'Use AI to research topics: Define scope → Gather info → Summarize findings → Create presentation outline.',
        assetPath: 'assets/promptcraft/level9/l9_flowchart_project3_research.png',
        tryPrompt: 'Help me research "Quantum Computing for Beginners" for a 10-minute class presentation.\n\n1. Give me the 5 most important concepts to cover\n2. Explain each in 2-3 sentences (simple language)\n3. Suggest 3 real-world applications\n4. Create a slide-by-slide outline (8 slides)\n5. Suggest a hook question to start the presentation',
      ),
      PromptLesson(
        title: 'Project Portfolio',
        description: 'All three projects form your prompt engineering portfolio. These demonstrate your ability to use AI professionally.',
        assetPath: 'assets/promptcraft/level9/l9_img_project_portfolio.png',
      ),
      PromptLesson(
        title: 'Chain Workflow',
        description: 'Review the full workflow: Plan → Prompt → Review → Refine → Apply. This cycle makes you a prompt engineering pro.',
        assetPath: 'assets/promptcraft/level9/l9_img_chain_workflow.png',
      ),
    ],
    examQuestions: [
      PromptExamQuestion(
        question: 'In the Study Plan project, what comes first?',
        options: ['Creating the schedule', 'Analyzing the syllabus', 'Finding resources', 'Taking practice tests'],
        correctIndex: 1,
        explanation: 'Always analyze the syllabus first to understand scope before planning.',
      ),
      PromptExamQuestion(
        question: 'What should a debug prompt always include?',
        options: ['Just "fix it"', 'Error message, code, language, expected behavior', 'Only the error', 'The entire project'],
        correctIndex: 1,
        explanation: 'Complete context: error, code, language, and what you expected to happen.',
      ),
      PromptExamQuestion(
        question: 'The research workflow ends with:',
        options: ['Gathering data', 'Creating a presentation outline', 'Defining scope', 'Asking more questions'],
        correctIndex: 1,
        explanation: 'The final step is creating an actionable output like a presentation outline.',
      ),
      PromptExamQuestion(
        question: 'Why build a prompt portfolio?',
        options: ['For grades', 'Demonstrates professional AI skills to employers', 'AI requires it', 'No reason'],
        correctIndex: 1,
        explanation: 'A portfolio of prompt engineering projects shows employers practical AI skills.',
      ),
      PromptExamQuestion(
        question: 'The prompt engineering cycle is:',
        options: ['Write → Send → Done', 'Plan → Prompt → Review → Refine → Apply', 'Ask → Wait → Copy', 'Research → Guess → Hope'],
        correctIndex: 1,
        explanation: 'The professional cycle: Plan, Prompt, Review, Refine, Apply.',
      ),
    ],
  ),

  // ═══════════════════════════════════════════
  // LEVEL 10: Final Exam & Certification
  // ═══════════════════════════════════════════
  PromptLevel(
    levelNumber: 10,
    title: 'Final Exam & Certification',
    icon: 'emoji_events',
    description: 'Prove your mastery and earn your badge',
    lessons: [
      PromptLesson(
        title: 'Exam Overview',
        description: 'The final exam tests all 9 levels. 5 challenging questions covering every technique you\'ve learned. Score 70%+ to pass.',
        assetPath: 'assets/promptcraft/level10/l10_flowchart_exam_flow.png',
      ),
      PromptLesson(
        title: 'Your Certificate',
        description: 'Pass the final exam to earn your PromptCraft Master certificate. Share it on LinkedIn and your portfolio.',
        assetPath: 'assets/promptcraft/level10/l10_img_certificate_template.png',
      ),
      PromptLesson(
        title: 'Master Badge',
        description: 'Completing all 10 levels unlocks the PromptCraft Master badge on your Zerno profile. You\'re now prompt-literate!',
        assetPath: 'assets/promptcraft/level10/l10_img_master_badge.png',
      ),
    ],
    examQuestions: [
      PromptExamQuestion(
        question: 'Which pattern is best for solving math/logic problems?',
        options: ['Expert Pattern', 'Comparator', 'Chain of Thought', 'Template'],
        correctIndex: 2,
        explanation: 'Chain of Thought forces step-by-step reasoning, ideal for math and logic.',
      ),
      PromptExamQuestion(
        question: 'Building a full project with AI requires which technique?',
        options: ['Single prompt', 'Prompt chaining with multiple steps', 'Zero-shot only', 'Just asking nicely'],
        correctIndex: 1,
        explanation: 'Complex projects need prompt chaining to break work into manageable steps.',
      ),
      PromptExamQuestion(
        question: 'For consistent AI output format, use:',
        options: ['High temperature', 'Few-shot examples showing desired format', 'Random prompts', 'Longer prompts'],
        correctIndex: 1,
        explanation: 'Few-shot examples show AI exactly what format you expect, ensuring consistency.',
      ),
      PromptExamQuestion(
        question: 'The most critical component of any prompt is:',
        options: ['Using fancy words', 'Being specific about what you want (Task)', 'Making it long', 'Using all caps'],
        correctIndex: 1,
        explanation: 'A clear, specific task is the most critical component — AI must know what you want.',
      ),
      PromptExamQuestion(
        question: 'You are now a PromptCraft Master! What\'s the key takeaway?',
        options: ['AI replaces thinking', 'Better prompts = better AI results, always', 'Prompts don\'t matter', 'Just use default prompts'],
        correctIndex: 1,
        explanation: 'The fundamental truth: your prompt quality directly determines your AI results.',
      ),
    ],
  ),
];
