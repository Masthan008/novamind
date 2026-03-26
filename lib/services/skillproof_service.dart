import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive/hive.dart';

/// SkillProof Service — Handles Supabase connectivity and local cooldowns
///
/// CREATE TABLE skillproof_badges (
///   id bigserial PRIMARY KEY,
///   student_id uuid,
///   student_name text,
///   skill_name text,
///   score int,
///   verification_code text UNIQUE DEFAULT substring(md5(random()::text), 1, 12),
///   issued_at timestamp DEFAULT now(),
///   is_valid boolean DEFAULT true
/// );

class SkillProofService {
  static final _supabase = Supabase.instance.client;
  static Box? _cooldownBox;

  static Future<void> _ensureBoxOpen() async {
    if (!Hive.isBoxOpen('skillproof_cooldowns')) {
      _cooldownBox = await Hive.openBox('skillproof_cooldowns');
    } else {
      _cooldownBox = Hive.box('skillproof_cooldowns');
    }
  }

  // Check if user is in cooldown period (24 hours after failing)
  static Future<bool> isOnCooldown(String skillName) async {
    await _ensureBoxOpen();
    final String? lastAttemptStr = _cooldownBox?.get(skillName);
    if (lastAttemptStr == null) return false;

    final lastAttempt = DateTime.tryParse(lastAttemptStr);
    if (lastAttempt == null) return false;

    final now = DateTime.now();
    return now.difference(lastAttempt).inHours < 24;
  }

  // Record a failed attempt to start the cooldown timer
  static Future<void> recordFailedAttempt(String skillName) async {
    await _ensureBoxOpen();
    await _cooldownBox?.put(skillName, DateTime.now().toIso8601String());
  }

  // Save a new badge to Supabase
  static Future<Map<String, dynamic>?> saveBadge({
    required String studentName,
    required String skillName,
    required int score,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase.from('skillproof_badges').insert({
        'student_id': userId,
        'student_name': studentName,
        'skill_name': skillName,
        'score': score,
      }).select().single();

      return response;
    } catch (e) {
      print('⚠️ Error saving SkillProof badge: $e');
      return null;
    }
  }

  // Fetch all badges for current user
  static Future<List<Map<String, dynamic>>> fetchMyBadges() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      return await _supabase
          .from('skillproof_badges')
          .select()
          .eq('student_id', userId)
          .eq('is_valid', true)
          .order('issued_at', ascending: false);
    } catch (e) {
      print('⚠️ Error fetching SkillProof badges: $e');
      return [];
    }
  }
}
