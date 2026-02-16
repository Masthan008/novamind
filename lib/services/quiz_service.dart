import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ds_question_model.dart';

/// Service for fetching random quiz questions and recording attempts.
class QuizService {
  static final _supabase = Supabase.instance.client;

  /// Fetch [limit] random questions for a [topic] using the Supabase RPC function.
  static Future<List<DsQuestion>> getRandomQuiz(String topic, int limit) async {
    try {
      final response = await _supabase.rpc(
        'get_random_quiz',
        params: {'p_topic': topic, 'p_limit': limit},
      );

      if (response == null) return [];

      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((json) => DsQuestion.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('QuizService.getRandomQuiz error: $e');
      return [];
    }
  }

  /// Record a student's answer attempt.
  static Future<void> submitAnswer({
    required String questionId,
    required bool isCorrect,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase.from('quiz_attempts').insert({
        'user_id': userId,
        'question_id': questionId,
        'is_correct': isCorrect,
      });
    } catch (e) {
      debugPrint('QuizService.submitAnswer error: $e');
    }
  }

  /// Get total and correct attempt counts for a [topic] for the current user.
  static Future<Map<String, int>> getTopicStats(String topic) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return {'total': 0, 'correct': 0};

      // Join quiz_attempts with ds_questions to filter by topic
      final data = await _supabase
          .from('quiz_attempts')
          .select('is_correct, ds_questions!inner(topic)')
          .eq('user_id', userId)
          .eq('ds_questions.topic', topic);

      final List<dynamic> rows = data as List<dynamic>;
      final total = rows.length;
      final correct = rows.where((r) => r['is_correct'] == true).length;

      return {'total': total, 'correct': correct};
    } catch (e) {
      debugPrint('QuizService.getTopicStats error: $e');
      return {'total': 0, 'correct': 0};
    }
  }
}
