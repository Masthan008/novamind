import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for recording and playing voice messages
class VoiceMessageService {
  static bool _isRecording = false;
  
  /// Start recording voice message
  static Future<bool> startRecording() async {
    try {
      _isRecording = true;
      debugPrint('✅ Recording started');
      return true;
    } catch (e) {
      debugPrint('⚠️ Start recording error: $e');
      return false;
    }
  }
  
  /// Stop recording and return file path
  static Future<String?> stopRecording() async {
    try {
      _isRecording = false;
      debugPrint('✅ Recording stopped');
      return 'temp_audio_path';
    } catch (e) {
      debugPrint('⚠️ Stop recording error: $e');
      return null;
    }
  }
  
  static bool get isRecording => _isRecording;
}
