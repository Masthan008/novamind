import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'student_auth_service.dart';

/// Service for Community, Routine, and Diary data operations
/// Uses StudentAuthService for authentication (not Supabase Auth)
class SupabaseDataService {
  final _supabase = Supabase.instance.client;

  /// Helper to get current student's ID (UUID from students table)
  String? get _studentId => StudentAuthService.currentStudent?.id;
  
  /// Helper to get current student's name
  String? get _studentName => StudentAuthService.currentStudent?.name;

  // ================================================================
  // 🗣️ COMMUNITY DOUBTS FEATURES
  // ================================================================
  
  /// Get all doubts stream (Real-time updates)
  Stream<List<Map<String, dynamic>>> getDoubtsStream() {
    return _supabase
        .from('student_doubts')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }

  /// Post a new doubt
  Future<bool> postDoubt(String question, String subject) async {
    final studentId = _studentId;
    final studentName = _studentName;
    
    if (studentId == null || studentName == null) {
      debugPrint('⚠️ Cannot post doubt: Not logged in');
      return false;
    }

    try {
      await _supabase.from('student_doubts').insert({
        'student_id': studentId,
        'student_name': studentName,
        'question': question,
        'subject': subject,
      });
      debugPrint('✅ Doubt posted successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error posting doubt: $e');
      return false;
    }
  }

  /// Post an answer to a doubt
  Future<bool> postAnswer(String doubtId, String answer) async {
    final studentId = _studentId;
    final studentName = _studentName;
    
    if (studentId == null || studentName == null) {
      debugPrint('⚠️ Cannot post answer: Not logged in');
      return false;
    }

    try {
      // Insert the answer
      await _supabase.from('student_answers').insert({
        'doubt_id': doubtId,
        'student_id': studentId,
        'student_name': studentName,
        'answer_text': answer,
      });
      
      // Update answer count on the doubt (fetch current count and increment)
      try {
        final doubt = await _supabase
            .from('student_doubts')
            .select('answer_count')
            .eq('id', doubtId)
            .maybeSingle();
        
        final currentCount = (doubt?['answer_count'] ?? 0) as int;
        await _supabase
            .from('student_doubts')
            .update({'answer_count': currentCount + 1})
            .eq('id', doubtId);
      } catch (e) {
        // Ignore count update error - answer was still posted
        debugPrint('⚠️ Could not update answer count: $e');
      }
      
      debugPrint('✅ Answer posted successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error posting answer: $e');
      return false;
    }
  }

  /// Get answers for a specific doubt (Real-time)
  Stream<List<Map<String, dynamic>>> getAnswersStream(String doubtId) {
    return _supabase
        .from('student_answers')
        .stream(primaryKey: ['id'])
        .eq('doubt_id', doubtId)
        .order('created_at', ascending: true);
  }

  /// Mark a doubt as solved
  Future<bool> markDoubtSolved(String doubtId, String? acceptedAnswerId) async {
    try {
      await _supabase
          .from('student_doubts')
          .update({'is_solved': true})
          .eq('id', doubtId);
      
      if (acceptedAnswerId != null) {
        await _supabase
            .from('student_answers')
            .update({'is_accepted': true})
            .eq('id', acceptedAnswerId);
      }
      return true;
    } catch (e) {
      debugPrint('❌ Error marking doubt solved: $e');
      return false;
    }
  }

  // ================================================================
  // 📅 PERSONAL ROUTINE FEATURES (Private)
  // ================================================================
  
  /// Get MY routine items
  Future<List<Map<String, dynamic>>> getMyRoutine() async {
    final studentId = _studentId;
    if (studentId == null) {
      debugPrint('⚠️ Cannot get routine: Not logged in');
      return [];
    }

    try {
      final response = await _supabase
          .from('student_routines')
          .select()
          .eq('student_id', studentId)
          .order('start_time', ascending: true);
          
      debugPrint('✅ Fetched ${response.length} routine items');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ Error fetching routine: $e');
      return [];
    }
  }

  /// Add a new routine item
  Future<bool> addRoutineItem(String activity, String startTime, String endTime, {String dayOfWeek = 'Everyday'}) async {
    final studentId = _studentId;
    if (studentId == null) {
      debugPrint('⚠️ Cannot add routine: Not logged in');
      return false;
    }

    try {
      await _supabase.from('student_routines').insert({
        'student_id': studentId,
        'activity_name': activity,
        'start_time': startTime,
        'end_time': endTime,
        'day_of_week': dayOfWeek,
      });
      debugPrint('✅ Routine item added: $activity');
      return true;
    } catch (e) {
      debugPrint('❌ Error adding routine: $e');
      return false;
    }
  }

  /// Update a routine item
  Future<bool> updateRoutineItem(String id, {String? activity, String? startTime, String? endTime, String? dayOfWeek, bool? isActive}) async {
    try {
      final updates = <String, dynamic>{};
      if (activity != null) updates['activity_name'] = activity;
      if (startTime != null) updates['start_time'] = startTime;
      if (endTime != null) updates['end_time'] = endTime;
      if (dayOfWeek != null) updates['day_of_week'] = dayOfWeek;
      if (isActive != null) updates['is_active'] = isActive;
      
      if (updates.isEmpty) return true;
      
      await _supabase.from('student_routines').update(updates).eq('id', id);
      debugPrint('✅ Routine item updated');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating routine: $e');
      return false;
    }
  }
  
  /// Delete a routine item
  Future<bool> deleteRoutineItem(String id) async {
    try {
      await _supabase.from('student_routines').delete().eq('id', id);
      debugPrint('✅ Routine item deleted');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting routine: $e');
      return false;
    }
  }

  // ================================================================
  // 📔 DAILY DIARY FEATURES (Private)
  // ================================================================

  /// Save a diary entry
  Future<bool> saveDiaryEntry(String title, String content, String mood) async {
    final studentId = _studentId;
    if (studentId == null) {
      debugPrint('⚠️ Cannot save diary: Not logged in');
      return false;
    }

    try {
      await _supabase.from('student_diaries').insert({
        'student_id': studentId,
        'title': title,
        'content': content,
        'mood': mood,
        'entry_date': DateTime.now().toIso8601String().split('T')[0],
      });
      debugPrint('✅ Diary entry saved');
      return true;
    } catch (e) {
      debugPrint('❌ Error saving diary: $e');
      return false;
    }
  }

  /// Update a diary entry
  Future<bool> updateDiaryEntry(String id, {String? title, String? content, String? mood}) async {
    try {
      final updates = <String, dynamic>{};
      if (title != null) updates['title'] = title;
      if (content != null) updates['content'] = content;
      if (mood != null) updates['mood'] = mood;
      
      if (updates.isEmpty) return true;
      
      await _supabase.from('student_diaries').update(updates).eq('id', id);
      debugPrint('✅ Diary entry updated');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating diary: $e');
      return false;
    }
  }

  /// Delete a diary entry
  Future<bool> deleteDiaryEntry(String id) async {
    try {
      await _supabase.from('student_diaries').delete().eq('id', id);
      debugPrint('✅ Diary entry deleted');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting diary: $e');
      return false;
    }
  }
  
  /// Get my past diary entries
  Future<List<Map<String, dynamic>>> getMyDiaries() async {
    final studentId = _studentId;
    if (studentId == null) {
      debugPrint('⚠️ Cannot get diaries: Not logged in');
      return [];
    }

    try {
      final response = await _supabase
          .from('student_diaries')
          .select()
          .eq('student_id', studentId)
          .order('created_at', ascending: false);
          
      debugPrint('✅ Fetched ${response.length} diary entries');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ Error fetching diaries: $e');
      return [];
    }
  }

  /// Get diary entry for a specific date
  Future<Map<String, dynamic>?> getDiaryForDate(DateTime date) async {
    final studentId = _studentId;
    if (studentId == null) return null;

    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await _supabase
          .from('student_diaries')
          .select()
          .eq('student_id', studentId)
          .eq('entry_date', dateStr)
          .maybeSingle();
          
      return response;
    } catch (e) {
      debugPrint('❌ Error fetching diary for date: $e');
      return null;
    }
  }

  // ================================================================
  // 🔔 NOTIFICATION FEATURES (Campus Buzz)
  // ================================================================

  /// Get my notifications stream (Real-time)
  Stream<List<Map<String, dynamic>>> getMyNotificationsStream() {
    final studentId = _studentId;
    if (studentId == null) {
      return Stream.value([]);
    }
    
    return _supabase
        .from('student_notifications')
        .stream(primaryKey: ['id'])
        .eq('recipient_id', studentId)
        .order('created_at', ascending: false);
  }

  /// Get unread notification count
  Future<int> getUnreadNotificationCount() async {
    final studentId = _studentId;
    if (studentId == null) return 0;

    try {
      final response = await _supabase
          .from('student_notifications')
          .select('id')
          .eq('recipient_id', studentId)
          .eq('is_read', false);
      return response.length;
    } catch (e) {
      return 0;
    }
  }

  /// Send notification when someone answers a doubt
  Future<void> sendAnswerNotification({
    required String recipientId,
    required String questionSnippet,
  }) async {
    final senderName = _studentName;
    if (senderName == null || _studentId == recipientId) return; // Don't notify self

    try {
      await _supabase.from('student_notifications').insert({
        'recipient_id': recipientId,
        'sender_id': _studentId,
        'sender_name': senderName,
        'message': 'replied to your doubt: "${questionSnippet.length > 40 ? '${questionSnippet.substring(0, 40)}...' : questionSnippet}"',
        'notification_type': 'answer',
        'is_read': false,
      });
      debugPrint('✅ Notification sent to $recipientId');
    } catch (e) {
      debugPrint('⚠️ Could not send notification: $e');
    }
  }

  /// Mark notification as read
  Future<void> markNotificationRead(String notificationId) async {
    try {
      await _supabase
          .from('student_notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      debugPrint('⚠️ Error marking notification read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsRead() async {
    final studentId = _studentId;
    if (studentId == null) return;

    try {
      await _supabase
          .from('student_notifications')
          .update({'is_read': true})
          .eq('recipient_id', studentId);
    } catch (e) {
      debugPrint('⚠️ Error marking all notifications read: $e');
    }
  }

  /// Get recent doubts for Campus Buzz (limited feed)
  Future<List<Map<String, dynamic>>> getRecentDoubts({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('student_doubts')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ Error fetching recent doubts: $e');
      return [];
    }
  }
}
