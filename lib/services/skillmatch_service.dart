import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'student_auth_service.dart';

/// SkillMatch Service — job matching, company listings, applications
///
/// --- Supabase SQL (run in SQL Editor) ---
/// CREATE TABLE IF NOT EXISTS companies (
///   id bigserial PRIMARY KEY,
///   name text NOT NULL,
///   description text,
///   logo_url text,
///   website text,
///   industry text,
///   size text,
///   is_active boolean DEFAULT true,
///   created_at timestamp DEFAULT now()
/// );
///
/// CREATE TABLE IF NOT EXISTS job_postings (
///   id bigserial PRIMARY KEY,
///   company_id bigint REFERENCES companies(id),
///   title text NOT NULL,
///   description text,
///   type text DEFAULT 'internship',
///   required_skills text[],
///   location text,
///   salary_range text,
///   is_active boolean DEFAULT true,
///   deadline timestamp,
///   created_at timestamp DEFAULT now()
/// );
///
/// CREATE TABLE IF NOT EXISTS job_applications (
///   id bigserial PRIMARY KEY,
///   job_id bigint REFERENCES job_postings(id),
///   student_id text,
///   student_name text,
///   status text DEFAULT 'applied',
///   resume_url text,
///   cover_message text,
///   match_score int,
///   created_at timestamp DEFAULT now()
/// );
///
/// ALTER TABLE companies ENABLE ROW LEVEL SECURITY;
/// ALTER TABLE job_postings ENABLE ROW LEVEL SECURITY;
/// ALTER TABLE job_applications ENABLE ROW LEVEL SECURITY;
/// CREATE POLICY "Public read" ON companies FOR SELECT USING (true);
/// CREATE POLICY "Public read" ON job_postings FOR SELECT USING (true);
/// CREATE POLICY "Public all" ON job_applications FOR ALL USING (true) WITH CHECK (true);
/// ---
class SkillmatchService {
  static final _supabase = Supabase.instance.client;

  /// Get all active job postings
  static Future<List<Map<String, dynamic>>> getJobPostings() async {
    try {
      final data = await _supabase
          .from('job_postings')
          .select('*, companies(*)')
          .eq('is_active', true)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('⚠️ Get jobs error: $e');
      return _getHardcodedJobs();
    }
  }

  /// Apply to a job
  static Future<bool> applyToJob({
    required int jobId,
    required String coverMessage,
    int matchScore = 0,
  }) async {
    try {
      final student = StudentAuthService.currentStudent;
      if (student == null) return false;

      await _supabase.from('job_applications').insert({
        'job_id': jobId,
        'student_id': student.id.toString(),
        'student_name': student.name,
        'cover_message': coverMessage,
        'match_score': matchScore,
        'status': 'applied',
      });
      debugPrint('✅ Applied to job $jobId');
      return true;
    } catch (e) {
      debugPrint('⚠️ Apply error: $e');
      return false;
    }
  }

  /// Get my applications
  static Future<List<Map<String, dynamic>>> getMyApplications() async {
    try {
      final student = StudentAuthService.currentStudent;
      if (student == null) return [];

      final data = await _supabase
          .from('job_applications')
          .select('*, job_postings(*, companies(*))')
          .eq('student_id', student.id.toString())
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('⚠️ Get applications error: $e');
      return [];
    }
  }

  static List<Map<String, dynamic>> _getHardcodedJobs() {
    return [
      {'id': 1, 'title': 'Flutter Intern', 'type': 'internship', 'required_skills': ['Flutter', 'Dart', 'Firebase'], 'location': 'Remote', 'salary_range': '₹10K-15K/mo', 'is_active': true, 'companies': {'name': 'TechStartup Inc', 'industry': 'EdTech'}},
      {'id': 2, 'title': 'Frontend Developer', 'type': 'full-time', 'required_skills': ['React', 'TypeScript', 'Tailwind'], 'location': 'Hyderabad', 'salary_range': '₹6-12 LPA', 'is_active': true, 'companies': {'name': 'Digital Agency', 'industry': 'IT Services'}},
      {'id': 3, 'title': 'ML Research Intern', 'type': 'internship', 'required_skills': ['Python', 'TensorFlow', 'NLP'], 'location': 'Bangalore', 'salary_range': '₹20K/mo', 'is_active': true, 'companies': {'name': 'AI Labs Corp', 'industry': 'AI/ML'}},
      {'id': 4, 'title': 'Backend Developer', 'type': 'full-time', 'required_skills': ['Node.js', 'PostgreSQL', 'Docker'], 'location': 'Remote', 'salary_range': '₹8-15 LPA', 'is_active': true, 'companies': {'name': 'Cloud Solutions', 'industry': 'Cloud'}},
      {'id': 5, 'title': 'DevOps Intern', 'type': 'internship', 'required_skills': ['Linux', 'Docker', 'CI/CD', 'AWS'], 'location': 'Chennai', 'salary_range': '₹15K/mo', 'is_active': true, 'companies': {'name': 'InfraStack', 'industry': 'DevOps'}},
    ];
  }
}
