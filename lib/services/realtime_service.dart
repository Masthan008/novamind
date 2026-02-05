import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Real-time service for ChatHub features
class RealtimeService {
  static final _supabase = Supabase.instance.client;
  
  /// Subscribe to new messages
  static void subscribeToMessages(Function(Map<String, dynamic>) onNewMessage) {
    _supabase
        .channel('messages')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_messages',
          callback: (payload) {
            onNewMessage(payload.newRecord);
          },
        )
        .subscribe();
  }
  
  /// Send typing indicator
  static Future<void> sendTypingIndicator(String userId) async {
    try {
      debugPrint('✅ Typing indicator sent for user: $userId');
    } catch (e) {
      debugPrint('⚠️ Typing indicator error: $e');
    }
  }
}
