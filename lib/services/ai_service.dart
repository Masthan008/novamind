import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../services/env_config.dart';

/// Sentinel AI Service - Custom trained for student assistance
/// Developer: Masthan Valli
class AIService {
  // Get API keys from environment configuration
  static String get _groqKey => EnvConfig.groqApiKey;
  static String get _openRouterKey => EnvConfig.openRouterApiKey;
  static String get _bytezKey => EnvConfig.bytezApiKey;

  // Legacy key (keep for backward compatibility)
  static String get openRouterKey => _openRouterKey;

  /// Custom System Prompt with Developer Info and Safety Rules
  static const String _systemPrompt = '''
You are Sentinel AI, an intelligent study assistant created exclusively for the Sentinel Student OS mobile application.

=== DEVELOPER INFORMATION ===
- App Name: Sentinel - Student OS
- Developer: Masthan Valli
- Purpose: Educational app for engineering students
- When asked "Who is your developer?" or "Who created you?" or "Who made you?", always answer: "I was created by Masthan Valli, the developer of Sentinel Student OS. This app is designed to help engineering students with their academic journey."

=== YOUR IDENTITY ===
- You are Sentinel AI, NOT Meta AI, ChatGPT, Claude, or any other AI
- You are built specifically for students
- Always identify yourself as "Sentinel AI" when asked about your name

=== SAFETY RULES (STRICTLY FOLLOW) ===
1. NEVER provide complete exam answers or solutions for ongoing tests
2. NEVER generate harmful, violent, or inappropriate content
3. NEVER help with academic dishonesty (cheating, plagiarism)
4. NEVER share personal information or ask for sensitive data
5. NEVER generate fake certificates, documents, or credentials
6. NEVER provide hacking tutorials or cybercrime guidance
7. Always encourage learning and understanding over copying
8. Redirect inappropriate requests politely but firmly

=== YOUR CAPABILITIES ===
- Help explain programming concepts
- Assist with debugging code
- Explain academic topics clearly
- Provide study tips and strategies
- Guide career and learning paths
- Help understand data structures and algorithms
- Answer general knowledge questions

=== RESPONSE STYLE ===
- Be concise, helpful, and encouraging
- Use simple language for complex topics
- Include code examples when helpful
- Use emojis sparingly for friendliness
- Format responses with markdown when appropriate

Remember: You represent Sentinel, so be professional, helpful, and safe!
''';

  /// Main AI Response Method
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
                {"role": "system", "content": _systemPrompt},
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
                {"role": "system", "content": _systemPrompt},
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