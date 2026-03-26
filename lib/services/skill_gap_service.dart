import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  static Future<Map<String, dynamic>> analyzeGap({
    required String targetRole,
    required List<String> currentSkills,
  }) async {
    final required = roleSkills[targetRole] ?? [];
    final missing = required.where((s) => !currentSkills.contains(s)).toList();
    final matched = required.where((s) => currentSkills.contains(s)).toList();
    final readiness = required.isEmpty ? 0.0 : matched.length / required.length * 100;

    final result = {
      'targetRole': targetRole,
      'currentSkills': currentSkills,
      'requiredSkills': required,
      'matchedSkills': matched,
      'missingSkills': missing,
      'readinessPercent': readiness,
      'analysisDate': DateTime.now().toIso8601String(),
    };

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      
      if (userId != null) {
        await supabase.from('skill_gap_results').insert({
          'user_id': userId,
          'target_role': targetRole,
          'current_skills': currentSkills,
          'missing_skills': missing,
          'readiness_percent': readiness,
          'analysis_date': DateTime.now().toIso8601String(),
          // Ensure we don't try storing complex objects if the schema doesn't match perfectly,
          // but SQL schema provided by user says: Gap_Percentage, current_skills text[], missing_skills text[], etc.
          // Wait, user SQL says:
          // CREATE TABLE skill_gap_results (
          //   id bigserial PRIMARY KEY,
          //   student_id uuid,
          //   target_role text,
          //   current_skills text[],
          //   gap_percentage int,
          //   recommended_skills text[],
          //   created_at timestamp DEFAULT now()
          // );
          'student_id': userId,
          'gap_percentage': 100 - readiness.toInt(),
          'recommended_skills': missing,
        });
      }
    } catch (e) {
      print('⚠️ Error saving skill gap results to Supabase: $e');
    }

    return result;
  }
}
