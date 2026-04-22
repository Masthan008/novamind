import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'student_auth_service.dart';

/// Mentor Service — mentors, bookings, sessions, availability
///
/// --- Supabase SQL (run in SQL Editor) ---
/// CREATE TABLE IF NOT EXISTS mentors (
///   id bigserial PRIMARY KEY,
///   student_id text NOT NULL,
///   name text NOT NULL,
///   title text,
///   bio text,
///   expertise text[],
///   rate_per_session int DEFAULT 0,
///   avatar_url text,
///   rating decimal DEFAULT 5.0,
///   total_sessions int DEFAULT 0,
///   is_active boolean DEFAULT true,
///   created_at timestamp DEFAULT now()
/// );
///
/// CREATE TABLE IF NOT EXISTS mentor_availability (
///   id bigserial PRIMARY KEY,
///   mentor_id bigint REFERENCES mentors(id),
///   day_of_week text,
///   start_time time,
///   end_time time
/// );
///
/// CREATE TABLE IF NOT EXISTS mentor_sessions (
///   id bigserial PRIMARY KEY,
///   mentor_id bigint REFERENCES mentors(id),
///   student_id text NOT NULL,
///   student_name text,
///   topic text,
///   status text DEFAULT 'pending',
///   scheduled_at timestamp,
///   duration_minutes int DEFAULT 30,
///   notes text,
///   rating int,
///   created_at timestamp DEFAULT now()
/// );
///
/// ALTER TABLE mentors ENABLE ROW LEVEL SECURITY;
/// ALTER TABLE mentor_availability ENABLE ROW LEVEL SECURITY;
/// ALTER TABLE mentor_sessions ENABLE ROW LEVEL SECURITY;
/// CREATE POLICY "Public read" ON mentors FOR SELECT USING (true);
/// CREATE POLICY "Public all" ON mentors FOR ALL USING (true) WITH CHECK (true);
/// CREATE POLICY "Public all" ON mentor_availability FOR ALL USING (true) WITH CHECK (true);
/// CREATE POLICY "Public all" ON mentor_sessions FOR ALL USING (true) WITH CHECK (true);
/// ---
class MentorService {
  static final _supabase = Supabase.instance.client;

  /// Get all active mentors
  static Future<List<Map<String, dynamic>>> getAllMentors() async {
    try {
      final data = await _supabase
          .from('mentors')
          .select()
          .eq('is_active', true)
          .order('rating', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('⚠️ Get mentors error: $e');
      return _getHardcodedMentors();
    }
  }

  /// Get mentor by ID
  static Future<Map<String, dynamic>?> getMentor(int mentorId) async {
    try {
      final data = await _supabase
          .from('mentors')
          .select()
          .eq('id', mentorId)
          .maybeSingle();
      return data;
    } catch (e) {
      debugPrint('⚠️ Get mentor error: $e');
      return null;
    }
  }

  /// Get mentor availability
  static Future<List<Map<String, dynamic>>> getAvailability(int mentorId) async {
    try {
      final data = await _supabase
          .from('mentor_availability')
          .select()
          .eq('mentor_id', mentorId);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('⚠️ Get availability error: $e');
      return [];
    }
  }

  /// Book a session with a mentor
  static Future<bool> bookSession({
    required int mentorId,
    required String topic,
    required DateTime scheduledAt,
    int durationMinutes = 30,
  }) async {
    try {
      final student = StudentAuthService.currentStudent;
      if (student == null) return false;

      await _supabase.from('mentor_sessions').insert({
        'mentor_id': mentorId,
        'student_id': student.id.toString(),
        'student_name': student.name,
        'topic': topic,
        'scheduled_at': scheduledAt.toIso8601String(),
        'duration_minutes': durationMinutes,
        'status': 'pending',
      });
      debugPrint('✅ Session booked with mentor $mentorId');
      return true;
    } catch (e) {
      debugPrint('⚠️ Book session error: $e');
      return false;
    }
  }

  /// Get my sessions (as student)
  static Future<List<Map<String, dynamic>>> getMySessions() async {
    try {
      final student = StudentAuthService.currentStudent;
      if (student == null) return [];

      final data = await _supabase
          .from('mentor_sessions')
          .select('*, mentors(*)')
          .eq('student_id', student.id.toString())
          .order('scheduled_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('⚠️ Get my sessions error: $e');
      return [];
    }
  }

  /// Register as a mentor
  static Future<bool> registerAsMentor({
    required String title,
    required String bio,
    required List<String> expertise,
    int ratePerSession = 0,
  }) async {
    try {
      final student = StudentAuthService.currentStudent;
      if (student == null) return false;

      await _supabase.from('mentors').insert({
        'student_id': student.id.toString(),
        'name': student.name,
        'title': title,
        'bio': bio,
        'expertise': expertise,
        'rate_per_session': ratePerSession,
        'avatar_url': student.imageUrl,
      });
      debugPrint('✅ Registered as mentor');
      return true;
    } catch (e) {
      debugPrint('⚠️ Register mentor error: $e');
      return false;
    }
  }

  /// Rate a session
  static Future<bool> rateSession(int sessionId, int rating) async {
    try {
      await _supabase
          .from('mentor_sessions')
          .update({'rating': rating})
          .eq('id', sessionId);
      return true;
    } catch (e) {
      debugPrint('⚠️ Rate session error: $e');
      return false;
    }
  }

  static List<Map<String, dynamic>> _getHardcodedMentors() {
    return [
      {'id': 1, 'name': 'Arjun Reddy', 'title': 'Full Stack Developer', 'bio': '3+ years in web dev, intern at Flipkart', 'expertise': ['React', 'Node.js', 'MongoDB', 'AWS'], 'rate_per_session': 0, 'rating': 4.9, 'total_sessions': 25, 'is_active': true},
      {'id': 2, 'name': 'Priya Sharma', 'title': 'Data Science Lead', 'bio': 'ML researcher, published 2 papers on NLP', 'expertise': ['Python', 'TensorFlow', 'NLP', 'Statistics'], 'rate_per_session': 50, 'rating': 4.8, 'total_sessions': 18, 'is_active': true},
      {'id': 3, 'name': 'Vikram Singh', 'title': 'Mobile App Dev', 'bio': 'Flutter expert, built 12+ apps on Play Store', 'expertise': ['Flutter', 'Dart', 'Firebase', 'Supabase'], 'rate_per_session': 0, 'rating': 4.7, 'total_sessions': 30, 'is_active': true},
      {'id': 4, 'name': 'Sneha Patel', 'title': 'UI/UX Designer', 'bio': 'Figma wizard, ex-design intern at Swiggy', 'expertise': ['Figma', 'UI Design', 'User Research', 'Prototyping'], 'rate_per_session': 0, 'rating': 4.9, 'total_sessions': 15, 'is_active': true},
      {'id': 5, 'name': 'Rahul Kumar', 'title': 'DSA Champion', 'bio': '4-star on CodeChef, 1800+ on Leetcode', 'expertise': ['DSA', 'Competitive Programming', 'C++', 'Java'], 'rate_per_session': 0, 'rating': 5.0, 'total_sessions': 42, 'is_active': true},
    ];
  }
}
