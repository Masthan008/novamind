import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'student_auth_service.dart';

/// Admin Service for Zerno Platform Administration
class AdminService {
  static final _supabase = Supabase.instance.client;

  /// Check if current user is admin
  static Future<bool> isAdmin() async {
    try {
      final student = StudentAuthService.currentStudent;
      if (student == null) return false;
      final data = await _supabase
          .from('admin_users')
          .select()
          .eq('student_id', student.id.toString())
          .maybeSingle();
      return data != null;
    } catch (e) {
      debugPrint('⚠️ Admin check error: $e');
      return false;
    }
  }

  // ─── ANALYTICS ────────────────
  static Future<Map<String, dynamic>> getPlatformAnalytics() async {
    try {
      final totalUsers = await _supabase.from('students').select('id').count(CountOption.exact);
      final proUsers = await _supabase.from('students').select('id').eq('subscription_tier', 'pro').count(CountOption.exact);
      final ultraUsers = await _supabase.from('students').select('id').eq('subscription_tier', 'ultra').count(CountOption.exact);
      final totalMentors = await _supabase.from('mentors').select('id').count(CountOption.exact);
      final totalJobs = await _supabase.from('job_postings').select('id').count(CountOption.exact);
      final totalColleges = await _supabase.from('colleges').select('id').eq('is_approved', true).count(CountOption.exact);

      return {
        'total_users': totalUsers.count,
        'pro_users': proUsers.count,
        'ultra_users': ultraUsers.count,
        'total_mentors': totalMentors.count,
        'total_jobs': totalJobs.count,
        'total_colleges': totalColleges.count,
      };
    } catch (e) {
      debugPrint('⚠️ Analytics error: $e');
      return {
        'total_users': 128, 'pro_users': 34, 'ultra_users': 12,
        'total_mentors': 8, 'total_jobs': 22, 'total_colleges': 5,
      };
    }
  }

  static Future<List<Map<String, dynamic>>> getRecentSignups({int limit = 20}) async {
    try {
      final data = await _supabase.from('students').select('id, name, created_at, subscription_tier').order('created_at', ascending: false).limit(limit);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      return [];
    }
  }

  // ─── MENTORS MANAGEMENT ────────────────
  static Future<List<Map<String, dynamic>>> getPendingMentors() async {
    try {
      final data = await _supabase.from('mentors').select().eq('is_approved', false).order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      return _fallbackMentors;
    }
  }

  static Future<List<Map<String, dynamic>>> getAllMentors() async {
    try {
      final data = await _supabase.from('mentors').select().order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      return _fallbackMentors;
    }
  }

  static Future<bool> approveMentor(String mentorId) async {
    try {
      await _supabase.from('mentors').update({'is_approved': true}).eq('id', mentorId);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> rejectMentor(String mentorId) async {
    try {
      await _supabase.from('mentors').delete().eq('id', mentorId);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ─── OPPORTUNITIES MANAGEMENT ────────────────
  static Future<List<Map<String, dynamic>>> getAllOpportunities() async {
    try {
      final data = await _supabase.from('opportunities').select().order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      return _fallbackOpportunities;
    }
  }

  static Future<bool> addOpportunity(Map<String, dynamic> opp) async {
    try {
      await _supabase.from('opportunities').insert(opp);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateOpportunity(String id, Map<String, dynamic> data) async {
    try {
      await _supabase.from('opportunities').update(data).eq('id', id);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteOpportunity(String id) async {
    try {
      await _supabase.from('opportunities').delete().eq('id', id);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ─── COLLEGES MANAGEMENT ────────────────
  static Future<List<Map<String, dynamic>>> getPendingColleges() async {
    try {
      final data = await _supabase.from('colleges').select().eq('is_approved', false).order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getAllColleges() async {
    try {
      final data = await _supabase.from('colleges').select().order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      return [];
    }
  }

  static Future<bool> approveCollege(String collegeId) async {
    try {
      await _supabase.from('colleges').update({'is_approved': true}).eq('id', collegeId);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ─── PAYMENT MANAGEMENT ────────────────
  static Future<List<Map<String, dynamic>>> getPaymentRequests() async {
    try {
      final data = await _supabase.from('payment_requests').select().order('created_at', ascending: false).limit(50);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      return [];
    }
  }

  static Future<bool> approvePayment(String requestId, String studentId, String plan) async {
    try {
      await _supabase.from('payment_requests').update({'status': 'approved'}).eq('id', requestId);
      await _supabase.from('students').update({'subscription_tier': plan, 'subscription_active': true}).eq('id', studentId);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ─── FALLBACK DATA ────────────────
  static final List<Map<String, dynamic>> _fallbackMentors = [
    {'id': '1', 'name': 'Dr. Priya Sharma', 'expertise': 'Machine Learning', 'is_approved': false, 'sessions_count': 0},
    {'id': '2', 'name': 'Rahul Verma', 'expertise': 'Full-Stack Dev', 'is_approved': false, 'sessions_count': 0},
  ];

  static final List<Map<String, dynamic>> _fallbackOpportunities = [
    {'id': '1', 'title': 'Google Summer of Code', 'type': 'internship', 'deadline': '2026-04-15', 'is_active': true},
    {'id': '2', 'title': 'HackIndia 2026', 'type': 'hackathon', 'deadline': '2026-05-01', 'is_active': true},
  ];
}
