import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'student_auth_service.dart';

/// College Service for B2B College Dashboard
class CollegeService {
  static final _supabase = Supabase.instance.client;

  // ─── COLLEGE REGISTRATION ────────────────
  static Future<bool> registerCollege(Map<String, dynamic> data) async {
    try {
      await _supabase.from('colleges').insert(data);
      debugPrint('✅ College registered: ${data['name']}');
      return true;
    } catch (e) {
      debugPrint('⚠️ College register error: $e');
      return false;
    }
  }

  // ─── STUDENT ↔ COLLEGE ────────────────
  static Future<({bool success, String? error})> joinCollege(String accessCode) async {
    try {
      final student = StudentAuthService.currentStudent;
      if (student == null) return (success: false, error: 'Not logged in');

      final college = await _supabase.from('colleges').select().eq('access_code', accessCode.trim()).eq('is_approved', true).maybeSingle();
      if (college == null) return (success: false, error: 'Invalid access code');

      // Check if already joined
      final existing = await _supabase.from('college_students').select().eq('student_id', student.id.toString()).eq('college_id', college['id']).maybeSingle();
      if (existing != null) return (success: false, error: 'Already joined this college');

      await _supabase.from('college_students').insert({
        'college_id': college['id'],
        'student_id': student.id.toString(),
      });
      return (success: true, error: null);
    } catch (e) {
      return (success: false, error: 'Failed: $e');
    }
  }

  static Future<Map<String, dynamic>?> getStudentCollege() async {
    try {
      final student = StudentAuthService.currentStudent;
      if (student == null) return null;

      final link = await _supabase.from('college_students').select('college_id').eq('student_id', student.id.toString()).maybeSingle();
      if (link == null) return null;

      final college = await _supabase.from('colleges').select().eq('id', link['college_id']).maybeSingle();
      return college;
    } catch (e) {
      return null;
    }
  }

  // ─── TPO ANALYTICS ────────────────
  static Future<Map<String, dynamic>> getCollegeAnalytics(int collegeId) async {
    try {
      final students = await _supabase.from('college_students').select('id').eq('college_id', collegeId).count(CountOption.exact);
      return {
        'total_students': students.count,
        'skillproof_rate': 45,
        'placement_readiness': 62,
        'avg_cgpa': 7.8,
        'microdegree_completions': 12,
        'active_applications': 34,
      };
    } catch (e) {
      return {
        'total_students': 0, 'skillproof_rate': 0, 'placement_readiness': 0,
        'avg_cgpa': 0.0, 'microdegree_completions': 0, 'active_applications': 0,
      };
    }
  }

  static Future<List<Map<String, dynamic>>> getTopStudents(int collegeId, {int limit = 10}) async {
    try {
      final links = await _supabase.from('college_students').select('student_id').eq('college_id', collegeId).limit(limit);
      final studentIds = (links as List).map((l) => l['student_id'].toString()).toList();
      if (studentIds.isEmpty) return [];

      final students = await _supabase.from('students').select('id, name, subscription_tier').inFilter('id', studentIds);
      return List<Map<String, dynamic>>.from(students);
    } catch (e) {
      return [];
    }
  }

  // ─── BATCH SKILLS ────────────────
  static Future<List<Map<String, dynamic>>> getBatchSkills(int collegeId) async {
    try {
      // Return sample skill distribution data
      return [
        {'skill': 'Python', 'proficiency': 0.72, 'students': 45},
        {'skill': 'JavaScript', 'proficiency': 0.68, 'students': 40},
        {'skill': 'Data Structures', 'proficiency': 0.55, 'students': 38},
        {'skill': 'SQL', 'proficiency': 0.62, 'students': 42},
        {'skill': 'Machine Learning', 'proficiency': 0.35, 'students': 20},
        {'skill': 'Flutter', 'proficiency': 0.48, 'students': 28},
        {'skill': 'DevOps', 'proficiency': 0.28, 'students': 15},
        {'skill': 'System Design', 'proficiency': 0.22, 'students': 12},
      ];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getCollegeStudents(int collegeId) async {
    try {
      final links = await _supabase.from('college_students').select('student_id, branch, year, section').eq('college_id', collegeId);
      return List<Map<String, dynamic>>.from(links);
    } catch (e) {
      return [];
    }
  }
}
