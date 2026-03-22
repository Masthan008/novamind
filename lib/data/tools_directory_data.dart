/// Free Tools Directory — 60+ free tools for students organized by category

class ToolItem {
  final String name;
  final String description;
  final String url;
  final String category;
  final String icon;
  final bool isFree;

  const ToolItem({
    required this.name,
    required this.description,
    required this.url,
    required this.category,
    this.icon = '🔧',
    this.isFree = true,
  });
}

class ToolsDirectoryData {
  static const List<String> categories = [
    'All', 'Development', 'Design', 'AI & ML', 'Productivity',
    'Learning', 'Cloud & DevOps', 'Data Science', 'Cybersecurity',
  ];

  static const List<ToolItem> tools = [
    // --- Development ---
    ToolItem(name: 'VS Code', description: 'Lightweight code editor by Microsoft', url: 'https://code.visualstudio.com', category: 'Development', icon: '💻'),
    ToolItem(name: 'GitHub', description: 'Code hosting & version control', url: 'https://github.com', category: 'Development', icon: '🐙'),
    ToolItem(name: 'Replit', description: 'Online IDE for 50+ languages', url: 'https://replit.com', category: 'Development', icon: '⚡'),
    ToolItem(name: 'CodePen', description: 'Frontend playground (HTML/CSS/JS)', url: 'https://codepen.io', category: 'Development', icon: '🖊️'),
    ToolItem(name: 'StackBlitz', description: 'Online IDE for web apps', url: 'https://stackblitz.com', category: 'Development', icon: '⚡'),
    ToolItem(name: 'GitPod', description: 'Cloud dev environments from Git', url: 'https://gitpod.io', category: 'Development', icon: '☁️'),
    ToolItem(name: 'Postman', description: 'API development & testing', url: 'https://postman.com', category: 'Development', icon: '📬'),
    ToolItem(name: 'Flutter', description: 'Cross-platform app framework', url: 'https://flutter.dev', category: 'Development', icon: '🦋'),
    ToolItem(name: 'Dart Pad', description: 'Online Dart/Flutter editor', url: 'https://dartpad.dev', category: 'Development', icon: '🎯'),

    // --- Design ---
    ToolItem(name: 'Figma', description: 'Collaborative UI/UX design', url: 'https://figma.com', category: 'Design', icon: '🎨'),
    ToolItem(name: 'Canva', description: 'Graphic design made easy', url: 'https://canva.com', category: 'Design', icon: '🖼️'),
    ToolItem(name: 'Penpot', description: 'Open source design tool', url: 'https://penpot.app', category: 'Design', icon: '✏️'),
    ToolItem(name: 'Coolors', description: 'Color palette generator', url: 'https://coolors.co', category: 'Design', icon: '🌈'),
    ToolItem(name: 'Undraw', description: 'Free SVG illustrations', url: 'https://undraw.co', category: 'Design', icon: '🎭'),
    ToolItem(name: 'Font Awesome', description: 'Icon library for web', url: 'https://fontawesome.com', category: 'Design', icon: '⭐'),
    ToolItem(name: 'Google Fonts', description: 'Free web fonts library', url: 'https://fonts.google.com', category: 'Design', icon: '🔤'),
    ToolItem(name: 'Unsplash', description: 'Free high-res photos', url: 'https://unsplash.com', category: 'Design', icon: '📷'),

    // --- AI & ML ---
    ToolItem(name: 'Google Colab', description: 'Free GPU for ML notebooks', url: 'https://colab.research.google.com', category: 'AI & ML', icon: '🧠'),
    ToolItem(name: 'Hugging Face', description: 'ML models & datasets hub', url: 'https://huggingface.co', category: 'AI & ML', icon: '🤗'),
    ToolItem(name: 'TensorFlow', description: 'ML framework by Google', url: 'https://tensorflow.org', category: 'AI & ML', icon: '🔬'),
    ToolItem(name: 'Kaggle', description: 'Data science competitions & datasets', url: 'https://kaggle.com', category: 'AI & ML', icon: '📊'),
    ToolItem(name: 'ChatGPT', description: 'AI conversational assistant', url: 'https://chat.openai.com', category: 'AI & ML', icon: '💬'),
    ToolItem(name: 'Gemini', description: 'Google AI assistant', url: 'https://gemini.google.com', category: 'AI & ML', icon: '✨'),
    ToolItem(name: 'Perplexity AI', description: 'AI-powered research engine', url: 'https://perplexity.ai', category: 'AI & ML', icon: '🔍'),
    ToolItem(name: 'Runway ML', description: 'AI creative tools', url: 'https://runwayml.com', category: 'AI & ML', icon: '🎬'),

    // --- Productivity ---
    ToolItem(name: 'Notion', description: 'All-in-one workspace for notes & tasks', url: 'https://notion.so', category: 'Productivity', icon: '📝'),
    ToolItem(name: 'Obsidian', description: 'Knowledge base & note-taking', url: 'https://obsidian.md', category: 'Productivity', icon: '💎'),
    ToolItem(name: 'Trello', description: 'Kanban board for project management', url: 'https://trello.com', category: 'Productivity', icon: '📋'),
    ToolItem(name: 'Todoist', description: 'Task management app', url: 'https://todoist.com', category: 'Productivity', icon: '✅'),
    ToolItem(name: 'Excalidraw', description: 'Virtual whiteboard for sketching', url: 'https://excalidraw.com', category: 'Productivity', icon: '🖌️'),
    ToolItem(name: 'Miro', description: 'Collaborative whiteboard', url: 'https://miro.com', category: 'Productivity', icon: '📌'),
    ToolItem(name: 'Grammarly', description: 'AI writing assistant', url: 'https://grammarly.com', category: 'Productivity', icon: '📖'),
    ToolItem(name: 'Overleaf', description: 'Online LaTeX editor', url: 'https://overleaf.com', category: 'Productivity', icon: '📄'),

    // --- Learning ---
    ToolItem(name: 'freeCodeCamp', description: 'Free coding curriculum', url: 'https://freecodecamp.org', category: 'Learning', icon: '🏕️'),
    ToolItem(name: 'The Odin Project', description: 'Full-stack web development', url: 'https://theodinproject.com', category: 'Learning', icon: '⚔️'),
    ToolItem(name: 'LeetCode', description: 'Coding interview prep', url: 'https://leetcode.com', category: 'Learning', icon: '💡'),
    ToolItem(name: 'HackerRank', description: 'Coding challenges & certifications', url: 'https://hackerrank.com', category: 'Learning', icon: '🏆'),
    ToolItem(name: 'GeeksForGeeks', description: 'CS tutorials & practice', url: 'https://geeksforgeeks.org', category: 'Learning', icon: '🎓'),
    ToolItem(name: 'W3Schools', description: 'Web development tutorials', url: 'https://w3schools.com', category: 'Learning', icon: '🌐'),
    ToolItem(name: 'Khan Academy', description: 'Free courses on many subjects', url: 'https://khanacademy.org', category: 'Learning', icon: '📚'),
    ToolItem(name: 'Coursera', description: 'University courses (audit free)', url: 'https://coursera.org', category: 'Learning', icon: '🎒'),

    // --- Cloud & DevOps ---
    ToolItem(name: 'Vercel', description: 'Deploy frontend apps free', url: 'https://vercel.com', category: 'Cloud & DevOps', icon: '▲'),
    ToolItem(name: 'Netlify', description: 'Static site hosting', url: 'https://netlify.com', category: 'Cloud & DevOps', icon: '🌐'),
    ToolItem(name: 'Firebase', description: 'Google backend-as-a-service', url: 'https://firebase.google.com', category: 'Cloud & DevOps', icon: '🔥'),
    ToolItem(name: 'Supabase', description: 'Open source Firebase alternative', url: 'https://supabase.com', category: 'Cloud & DevOps', icon: '⚡'),
    ToolItem(name: 'Docker', description: 'Containerization platform', url: 'https://docker.com', category: 'Cloud & DevOps', icon: '🐳'),
    ToolItem(name: 'Railway', description: 'Deploy apps instantly', url: 'https://railway.app', category: 'Cloud & DevOps', icon: '🚂'),
    ToolItem(name: 'Render', description: 'Free tier cloud hosting', url: 'https://render.com', category: 'Cloud & DevOps', icon: '☁️'),
    ToolItem(name: 'PlanetScale', description: 'Serverless MySQL database', url: 'https://planetscale.com', category: 'Cloud & DevOps', icon: '🌍'),

    // --- Data Science ---
    ToolItem(name: 'Jupyter', description: 'Interactive data notebooks', url: 'https://jupyter.org', category: 'Data Science', icon: '📓'),
    ToolItem(name: 'Tableau Public', description: 'Free data visualization', url: 'https://public.tableau.com', category: 'Data Science', icon: '📈'),
    ToolItem(name: 'D3.js', description: 'Data-driven web visualizations', url: 'https://d3js.org', category: 'Data Science', icon: '📊'),
    ToolItem(name: 'Apache Spark', description: 'Big data processing', url: 'https://spark.apache.org', category: 'Data Science', icon: '⚡'),
    ToolItem(name: 'Pandas', description: 'Python data analysis library', url: 'https://pandas.pydata.org', category: 'Data Science', icon: '🐼'),
    ToolItem(name: 'SQLite', description: 'Lightweight embedded database', url: 'https://sqlite.org', category: 'Data Science', icon: '🗃️'),
    ToolItem(name: 'Observable', description: 'Interactive data notebooks', url: 'https://observablehq.com', category: 'Data Science', icon: '👁️'),

    // --- Cybersecurity ---
    ToolItem(name: 'HackTheBox', description: 'Cybersecurity practice labs', url: 'https://hackthebox.com', category: 'Cybersecurity', icon: '🔒'),
    ToolItem(name: 'TryHackMe', description: 'Learn cybersecurity hands-on', url: 'https://tryhackme.com', category: 'Cybersecurity', icon: '🛡️'),
    ToolItem(name: 'PortSwigger', description: 'Web security academy (free)', url: 'https://portswigger.net/web-security', category: 'Cybersecurity', icon: '🕵️'),
    ToolItem(name: 'CyberChef', description: 'Data encoding/decoding tool', url: 'https://gchq.github.io/CyberChef', category: 'Cybersecurity', icon: '👨‍🍳'),
    ToolItem(name: 'Wireshark', description: 'Network protocol analyzer', url: 'https://wireshark.org', category: 'Cybersecurity', icon: '🦈'),
    ToolItem(name: 'OWASP ZAP', description: 'Web app security scanner', url: 'https://zaproxy.org', category: 'Cybersecurity', icon: '⚡'),
  ];
}
