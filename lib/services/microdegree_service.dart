import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'student_auth_service.dart';

/// MicroDegree Service — handles CRUD for degrees, lessons, progress, certificates
///
/// --- Supabase SQL (run in SQL Editor) ---
/// CREATE TABLE IF NOT EXISTS microdegrees (
///   id bigserial PRIMARY KEY,
///   title text NOT NULL,
///   description text,
///   duration_weeks int,
///   difficulty text,
///   skills_earned text[],
///   thumbnail_url text,
///   is_active boolean DEFAULT true,
///   created_at timestamp DEFAULT now()
/// );
///
/// CREATE TABLE IF NOT EXISTS microdegree_lessons (
///   id bigserial PRIMARY KEY,
///   microdegree_id bigint REFERENCES microdegrees(id),
///   week_number int,
///   lesson_number int,
///   title text,
///   video_url text,
///   notes text,
///   resources jsonb,
///   duration_minutes int
/// );
///
/// CREATE TABLE IF NOT EXISTS microdegree_progress (
///   id bigserial PRIMARY KEY,
///   student_id text,
///   microdegree_id bigint,
///   completed_lessons int[] DEFAULT '{}',
///   completion_percentage int DEFAULT 0,
///   enrolled_at timestamp DEFAULT now(),
///   completed_at timestamp
/// );
///
/// CREATE TABLE IF NOT EXISTS microdegree_certificates (
///   id bigserial PRIMARY KEY,
///   student_id text,
///   student_name text,
///   microdegree_id bigint,
///   microdegree_title text,
///   certificate_id text UNIQUE DEFAULT substring(md5(random()::text), 1, 16),
///   issued_at timestamp DEFAULT now(),
///   is_valid boolean DEFAULT true
/// );
///
/// -- Enable RLS for all tables
/// ALTER TABLE microdegrees ENABLE ROW LEVEL SECURITY;
/// ALTER TABLE microdegree_lessons ENABLE ROW LEVEL SECURITY;
/// ALTER TABLE microdegree_progress ENABLE ROW LEVEL SECURITY;
/// ALTER TABLE microdegree_certificates ENABLE ROW LEVEL SECURITY;
/// CREATE POLICY "Public read" ON microdegrees FOR SELECT USING (true);
/// CREATE POLICY "Public read" ON microdegree_lessons FOR SELECT USING (true);
/// CREATE POLICY "Public all" ON microdegree_progress FOR ALL USING (true) WITH CHECK (true);
/// CREATE POLICY "Public all" ON microdegree_certificates FOR ALL USING (true) WITH CHECK (true);
/// ---
class MicrodegreeService {
  static final _supabase = Supabase.instance.client;

  /// Get all active microdegrees
  static Future<List<Map<String, dynamic>>> getAllDegrees() async {
    try {
      final data = await _supabase
          .from('microdegrees')
          .select()
          .eq('is_active', true)
          .order('created_at');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('⚠️ Get degrees error: $e');
      return _getHardcodedDegrees();
    }
  }

  /// Get lessons for a specific microdegree
  static Future<List<Map<String, dynamic>>> getLessons(int microdegreeId) async {
    try {
      final data = await _supabase
          .from('microdegree_lessons')
          .select()
          .eq('microdegree_id', microdegreeId)
          .order('week_number')
          .order('lesson_number');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('⚠️ Get lessons error: $e');
      return [];
    }
  }

  /// Enroll in a microdegree
  static Future<bool> enroll(int microdegreeId) async {
    try {
      final student = StudentAuthService.currentStudent;
      if (student == null) return false;

      // Check if already enrolled
      final existing = await _supabase
          .from('microdegree_progress')
          .select()
          .eq('student_id', student.id.toString())
          .eq('microdegree_id', microdegreeId)
          .maybeSingle();

      if (existing != null) return true; // Already enrolled

      await _supabase.from('microdegree_progress').insert({
        'student_id': student.id.toString(),
        'microdegree_id': microdegreeId,
        'completed_lessons': [],
        'completion_percentage': 0,
      });
      debugPrint('✅ Enrolled in microdegree: $microdegreeId');
      return true;
    } catch (e) {
      debugPrint('⚠️ Enroll error: $e');
      return false;
    }
  }

  /// Mark a lesson as complete
  static Future<bool> completeLesson(int microdegreeId, int lessonId, int totalLessons) async {
    try {
      final student = StudentAuthService.currentStudent;
      if (student == null) return false;

      final progress = await _supabase
          .from('microdegree_progress')
          .select()
          .eq('student_id', student.id.toString())
          .eq('microdegree_id', microdegreeId)
          .maybeSingle();

      if (progress == null) return false;

      List<int> completed = List<int>.from(progress['completed_lessons'] ?? []);
      if (!completed.contains(lessonId)) {
        completed.add(lessonId);
      }

      final percentage = ((completed.length / totalLessons) * 100).round();
      final isComplete = percentage >= 100;

      final updates = {
        'completed_lessons': completed,
        'completion_percentage': percentage.clamp(0, 100),
      };

      if (isComplete) {
        updates['completed_at'] = DateTime.now().toIso8601String();
      }

      await _supabase
          .from('microdegree_progress')
          .update(updates)
          .eq('student_id', student.id.toString())
          .eq('microdegree_id', microdegreeId);

      debugPrint('✅ Lesson $lessonId completed. Progress: $percentage%');
      return true;
    } catch (e) {
      debugPrint('⚠️ Complete lesson error: $e');
      return false;
    }
  }

  /// Get student's enrolled degrees with progress
  static Future<List<Map<String, dynamic>>> getMyProgress() async {
    try {
      final student = StudentAuthService.currentStudent;
      if (student == null) return [];

      final data = await _supabase
          .from('microdegree_progress')
          .select('*, microdegrees(*)')
          .eq('student_id', student.id.toString())
          .order('enrolled_at', ascending: false);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('⚠️ Get progress error: $e');
      return [];
    }
  }

  /// Issue certificate on completion
  static Future<String?> issueCertificate(int microdegreeId, String degreeTitle) async {
    try {
      final student = StudentAuthService.currentStudent;
      if (student == null) return null;

      // Check if certificate already exists
      final existing = await _supabase
          .from('microdegree_certificates')
          .select()
          .eq('student_id', student.id.toString())
          .eq('microdegree_id', microdegreeId)
          .maybeSingle();

      if (existing != null) return existing['certificate_id'];

      final response = await _supabase.from('microdegree_certificates').insert({
        'student_id': student.id.toString(),
        'student_name': student.name,
        'microdegree_id': microdegreeId,
        'microdegree_title': degreeTitle,
      }).select().single();

      debugPrint('✅ Certificate issued: ${response['certificate_id']}');
      return response['certificate_id'];
    } catch (e) {
      debugPrint('⚠️ Issue certificate error: $e');
      return null;
    }
  }

  /// Hardcoded fallback degrees (for when Supabase table is empty)
  static List<Map<String, dynamic>> _getHardcodedDegrees() {
    return [
      {
        'id': 1, 'title': 'Full Stack Web Developer', 'description': 'Master frontend, backend, and databases',
        'duration_weeks': 6, 'difficulty': 'Intermediate', 'skills_earned': ['HTML', 'CSS', 'JS', 'Node.js', 'MongoDB'],
        'thumbnail_url': null, 'is_active': true,
      },
      {
        'id': 2, 'title': 'Data Science Fundamentals', 'description': 'Learn Python, pandas, ML basics, and data visualization',
        'duration_weeks': 4, 'difficulty': 'Beginner', 'skills_earned': ['Python', 'Pandas', 'Matplotlib', 'Scikit-learn'],
        'thumbnail_url': null, 'is_active': true,
      },
      {
        'id': 3, 'title': 'Flutter Mobile Developer', 'description': 'Build cross-platform apps with Flutter and Dart',
        'duration_weeks': 5, 'difficulty': 'Intermediate', 'skills_earned': ['Dart', 'Flutter', 'Firebase', 'State Management'],
        'thumbnail_url': null, 'is_active': true,
      },
      {
        'id': 4, 'title': 'Prompt Engineer', 'description': 'Master AI prompt engineering for all domains',
        'duration_weeks': 2, 'difficulty': 'Beginner', 'skills_earned': ['Prompt Design', 'Few-Shot', 'Chain Prompting'],
        'thumbnail_url': null, 'is_active': true,
      },
      {
        'id': 5, 'title': 'Cybersecurity Basics', 'description': 'Learn ethical hacking, network security, and crypto',
        'duration_weeks': 3, 'difficulty': 'Intermediate', 'skills_earned': ['Networking', 'Cryptography', 'OWASP', 'Linux'],
        'thumbnail_url': null, 'is_active': true,
      },
      {
        'id': 6, 'title': 'DevOps Fundamentals', 'description': 'CI/CD, Docker, Kubernetes, and cloud basics',
        'duration_weeks': 4, 'difficulty': 'Intermediate', 'skills_earned': ['Docker', 'CI/CD', 'Linux', 'AWS Basics'],
        'thumbnail_url': null, 'is_active': true,
      },
      {
        'id': 7, 'title': 'UI/UX Design Basics', 'description': 'Design thinking, Figma, user research, and prototyping',
        'duration_weeks': 3, 'difficulty': 'Beginner', 'skills_earned': ['Figma', 'Wireframing', 'User Research', 'Prototyping'],
        'thumbnail_url': null, 'is_active': true,
      },
      {
        'id': 8, 'title': 'Python for Beginners', 'description': 'Learn Python from zero to confident',
        'duration_weeks': 3, 'difficulty': 'Beginner', 'skills_earned': ['Python', 'OOP', 'File I/O', 'Libraries'],
        'thumbnail_url': null, 'is_active': true,
      },
    ];
  }
}
