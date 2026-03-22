import 'package:flutter/foundation.dart';

/// Skill Gap Analyzer Service — Analyzes skill gaps for target roles
///
/// Supabase Table SQL:
/// CREATE TABLE IF NOT EXISTS skill_gap_results (
///   id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
///   user_id TEXT NOT NULL,
///   target_role TEXT NOT NULL,
///   current_skills TEXT[] NOT NULL,
///   missing_skills TEXT[] NOT NULL,
///   readiness_percent FLOAT NOT NULL,
///   analysis_date TIMESTAMPTZ DEFAULT NOW(),
///   recommended_path JSONB
/// );

class SkillGapService {
  // Predefined roles and their required skills
  static const Map<String, List<String>> roleSkills = {
    'Frontend Developer': ['HTML/CSS', 'JavaScript', 'React', 'TypeScript', 'Git', 'Responsive Design', 'REST APIs', 'CSS Frameworks'],
    'Backend Developer': ['Python', 'Node.js', 'SQL', 'REST APIs', 'Git', 'Docker', 'System Design', 'Linux'],
    'Full-Stack Developer': ['HTML/CSS', 'JavaScript', 'React', 'Node.js', 'SQL', 'Git', 'Docker', 'REST APIs', 'TypeScript', 'System Design'],
    'Mobile Developer': ['Flutter', 'Dart', 'REST APIs', 'Git', 'Firebase', 'UI/UX', 'State Management', 'App Publishing'],
    'Data Scientist': ['Python', 'SQL', 'Machine Learning', 'Statistics', 'Data Visualization', 'Pandas', 'NumPy', 'Deep Learning'],
    'ML Engineer': ['Python', 'Machine Learning', 'Deep Learning', 'TensorFlow/PyTorch', 'Docker', 'Git', 'Math/Linear Algebra', 'MLOps'],
    'DevOps Engineer': ['Linux', 'Docker', 'Kubernetes', 'CI/CD', 'Cloud (AWS/GCP/Azure)', 'Git', 'Terraform', 'Monitoring'],
    'Cybersecurity Analyst': ['Networking', 'Linux', 'Python', 'OWASP', 'Ethical Hacking', 'Cryptography', 'SIEM Tools', 'Incident Response'],
    'UI/UX Designer': ['Figma', 'User Research', 'Wireframing', 'Prototyping', 'Design Systems', 'Accessibility', 'Typography', 'Color Theory'],
    'Cloud Architect': ['Cloud (AWS/GCP/Azure)', 'Docker', 'Kubernetes', 'Networking', 'System Design', 'Security', 'IaC', 'Cost Optimization'],
  };

  static const List<String> allSkills = [
    'HTML/CSS', 'JavaScript', 'TypeScript', 'React', 'Angular', 'Vue.js',
    'Node.js', 'Python', 'Java', 'C++', 'C', 'Dart', 'Flutter', 'Swift',
    'Kotlin', 'Go', 'Rust', 'SQL', 'NoSQL', 'MongoDB', 'PostgreSQL',
    'Git', 'Docker', 'Kubernetes', 'Linux', 'REST APIs', 'GraphQL',
    'Firebase', 'Supabase', 'AWS', 'GCP', 'Azure', 'CI/CD',
    'Machine Learning', 'Deep Learning', 'TensorFlow/PyTorch', 'Data Visualization',
    'Pandas', 'NumPy', 'Statistics', 'Math/Linear Algebra',
    'System Design', 'Microservices', 'Design Patterns',
    'Networking', 'Cryptography', 'OWASP', 'Ethical Hacking',
    'Figma', 'UI/UX', 'Responsive Design', 'CSS Frameworks',
    'State Management', 'Testing', 'Agile/Scrum', 'Technical Writing',
    'Prompt Engineering', 'LLM/GenAI',
  ];

  static Map<String, dynamic> analyzeGap({
    required String targetRole,
    required List<String> currentSkills,
  }) {
    final required = roleSkills[targetRole] ?? [];
    final missing = required.where((s) => !currentSkills.contains(s)).toList();
    final matched = required.where((s) => currentSkills.contains(s)).toList();
    final readiness = required.isEmpty ? 0.0 : matched.length / required.length * 100;

    return {
      'targetRole': targetRole,
      'currentSkills': currentSkills,
      'requiredSkills': required,
      'matchedSkills': matched,
      'missingSkills': missing,
      'readinessPercent': readiness,
      'analysisDate': DateTime.now().toIso8601String(),
    };
  }
}
