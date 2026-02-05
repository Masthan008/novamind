import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../services/env_config.dart';

/// Simple AI Service for V2 Release
/// Temporarily simplified for stability
class AIService {
  // Get API keys from environment configuration
  static String get _groqKey => EnvConfig.groqApiKey;
  static String get _openRouterKey => EnvConfig.openRouterApiKey;
  static String get _bytezKey => EnvConfig.bytezApiKey;

  // Legacy key (keep for backward compatibility)
  static String get openRouterKey => _openRouterKey;

  /// Main AI Response Method - Simplified for V2
  static Future<String> getResponse(String userMessage, {String? userTier}) async {
    try {
      debugPrint("AI Service: Starting request for message: ${userMessage.substring(0, userMessage.length > 50 ? 50 : userMessage.length)}...");
      
      // Check if we have API keys
      if (!EnvConfig.hasGroqKey && !EnvConfig.hasOpenRouterKey) {
        debugPrint("AI Service: No API keys configured");
        return _getOfflineResponse();
      }

      // Try Groq first (fastest)
      if (EnvConfig.hasGroqKey) {
        try {
          debugPrint("AI Service: Trying Groq API...");
          final response = await http.post(
            Uri.parse("https://api.groq.com/openai/v1/chat/completions"),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_groqKey',
            },
            body: jsonEncode({
              "model": "llama-3.1-8b-instant",
              "messages": [
                {"role": "system", "content": "You are Sentinel AI, a helpful study assistant. Be concise and helpful."},
                {"role": "user", "content": userMessage}
              ],
              "temperature": 0.7,
              "max_tokens": 1024,
            }),
          ).timeout(const Duration(seconds: 15));
          
          debugPrint("AI Service: Groq response status: ${response.statusCode}");
          
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final content = data['choices']?[0]?['message']?['content'];
            if (content != null && content.toString().trim().isNotEmpty) {
              debugPrint("AI Service: Groq success!");
              return content.toString().trim();
            }
          } else {
            debugPrint("AI Service: Groq error ${response.statusCode}: ${response.body}");
          }
        } catch (e) {
          debugPrint("AI Service: Groq failed: $e");
        }
      }

      // Try OpenRouter as fallback
      if (EnvConfig.hasOpenRouterKey) {
        try {
          debugPrint("AI Service: Trying OpenRouter API...");
          final response = await http.post(
            Uri.parse("https://openrouter.ai/api/v1/chat/completions"),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_openRouterKey',
              'HTTP-Referer': 'https://sentinel.app',
              'X-Title': 'Sentinel Student OS',
            },
            body: jsonEncode({
              "model": "openai/gpt-3.5-turbo",
              "messages": [
                {"role": "system", "content": "You are Sentinel AI, a helpful study assistant. Be concise and helpful."},
                {"role": "user", "content": userMessage}
              ],
              "temperature": 0.7,
              "max_tokens": 1024,
            }),
          ).timeout(const Duration(seconds: 20));
          
          debugPrint("AI Service: OpenRouter response status: ${response.statusCode}");
          
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final content = data['choices']?[0]?['message']?['content'];
            if (content != null && content.toString().trim().isNotEmpty) {
              debugPrint("AI Service: OpenRouter success!");
              return content.toString().trim();
            }
          } else {
            debugPrint("AI Service: OpenRouter error ${response.statusCode}: ${response.body}");
          }
        } catch (e) {
          debugPrint("AI Service: OpenRouter failed: $e");
        }
      }

    } catch (e) {
      debugPrint("AI Service: General error: $e");
    }

    // All providers failed - return offline response
    debugPrint("AI Service: All providers failed, returning offline response");
    return _getOfflineResponse();
  }

  static String _getOfflineResponse() {
    return "🤖 **AI Temporarily Unavailable**\n\n"
        "The AI service is currently experiencing issues.\n\n"
        "**Try again in 30 seconds** or explore other features:\n"
        "• Academic Syllabus\n"
        "• Programming Hub\n"
        "• Student Library\n"
        "• Tech Roadmaps\n\n"
        "💡 The AI will be back online shortly!";
  }

  // Legacy methods for backward compatibility
  @Deprecated('Use getResponse() instead')
  static Future<String> askGemini(String prompt) async {
    return getResponse(prompt, userTier: 'pro');
  }

  @Deprecated('Use getResponse() instead')
  static Future<String> askLlama(String prompt) async {
    return getResponse(prompt, userTier: 'pro');
  }

  static String getModelInfo() {
    return 'Sentinel AI - Simplified for V2 release';
  }

  /// Check if user has AI access - Allow all for V2
  static bool hasAIAccess(String? tier) {
    return true; // Allow all users for V2
  }

  /// Get tier-specific features description
  static String getTierFeatures(String tier) {
    return "✅ AI Chat Available:\n"
        "• Ask coding questions\n"
        "• Get study help\n"
        "• Debug assistance\n"
        "• Learning guidance";
  }
}