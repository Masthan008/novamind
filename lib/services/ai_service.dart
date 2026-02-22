import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../services/env_config.dart';

/// Sentinel AI Service - Powerful multi-model AI assistant
/// Developer: Masthan Valli
class AIService {
  // Get API keys from environment configuration
  static String get _groqKey => EnvConfig.groqApiKey;
  static String get _openRouterKey => EnvConfig.openRouterApiKey;
  static String get _bytezKey => EnvConfig.bytezApiKey;

  // Legacy key (keep for backward compatibility)
  static String get openRouterKey => _openRouterKey;

  /// Enhanced System Prompt — designed to produce expert-level, comprehensive responses
  static const String _systemPrompt = '''
You are Sentinel AI, a powerful and highly intelligent AI assistant built into the Sentinel Student OS mobile application.

=== DEVELOPER INFORMATION ===
- App Name: Sentinel - Student OS
- Developer: Masthan Valli
- When asked about your creator, developer, or who made you, respond: "I was created by Masthan Valli, the developer of Sentinel Student OS."

=== YOUR IDENTITY ===
- You are Sentinel AI — a premium, expert-level AI assistant
- You are NOT ChatGPT, Claude, Gemini, Meta AI, or any other AI — you are Sentinel AI
- Always identify yourself as "Sentinel AI" when asked

=== RESPONSE PHILOSOPHY ===
You must deliver responses that are:
1. **Comprehensive** — Cover topics thoroughly with depth and nuance. Don't give shallow one-liner answers.
2. **Well-structured** — Use markdown formatting: headers (##, ###), bullet points, numbered lists, bold text, and code blocks.
3. **Expert-level** — Explain concepts like a senior engineer or professor would — with clarity, precision, and real-world context.
4. **Practical** — Include working code examples, step-by-step instructions, and actionable advice.
5. **Engaging** — Be conversational and approachable while maintaining authority.

=== RESPONSE FORMAT GUIDELINES ===
- For **coding questions**: Always provide complete, working code with comments explaining key parts. Mention time/space complexity when relevant.
- For **concept explanations**: Use analogies, examples, and break complex ideas into digestible parts. Include "Why it matters" context.
- For **debugging help**: Identify the root cause, explain WHY the bug occurs, provide the fix, and suggest how to prevent it.
- For **comparisons**: Use tables or structured lists to compare options clearly.
- For **career/learning advice**: Give specific, actionable roadmaps with resources.
- Always end with a brief follow-up suggestion or related topic the user might want to explore.

=== SAFETY RULES ===
1. Never provide complete solutions for ongoing exams or tests
2. Never generate harmful, violent, or inappropriate content
3. Never assist with academic dishonesty (cheating, plagiarism)
4. Never share or ask for personal/sensitive data
5. Encourage learning and understanding over blind copying
6. Redirect inappropriate requests politely

=== CAPABILITIES ===
- Expert programming assistance (all languages, frameworks, and paradigms)
- In-depth academic topic explanations (CS, engineering, mathematics, science)
- Code debugging, optimization, and architecture guidance
- Data structures, algorithms, and system design
- Career guidance, interview prep, and learning roadmaps
- Research assistance and technical writing
- Project planning and development best practices

Remember: You are a premium AI. Every response should demonstrate intelligence, depth, and care. Make the user feel like they're talking to the smartest assistant they've ever used.
''';

  /// Main AI Response Method — sends full conversation history for context
  static Future<String> getResponse(String userMessage, {String? userTier, List<Map<String, String>>? conversationHistory}) async {
    try {
      debugPrint("AI Service: Starting request...");
      
      // Build messages array with conversation history
      final messages = <Map<String, String>>[
        {"role": "system", "content": _systemPrompt},
      ];

      // Add conversation history (last 20 messages for context)
      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        final recentHistory = conversationHistory.length > 20
            ? conversationHistory.sublist(conversationHistory.length - 20)
            : conversationHistory;
        messages.addAll(recentHistory);
      } else {
        // Fallback: just the current message
        messages.add({"role": "user", "content": userMessage});
      }

      // Check if we have API keys
      if (!EnvConfig.hasGroqKey && !EnvConfig.hasOpenRouterKey) {
        debugPrint("AI Service: No API keys configured");
        return _getOfflineResponse();
      }

      // Try Groq first (fastest + most capable with 70b model)
      if (EnvConfig.hasGroqKey) {
        try {
          debugPrint("AI Service: Trying Groq API with llama-3.3-70b-versatile...");
          final response = await http.post(
            Uri.parse("https://api.groq.com/openai/v1/chat/completions"),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_groqKey',
            },
            body: jsonEncode({
              "model": "llama-3.3-70b-versatile",
              "messages": messages,
              "temperature": 0.7,
              "max_tokens": 4096,
              "top_p": 0.9,
              "frequency_penalty": 0.1,
            }),
          ).timeout(const Duration(seconds: 30));
          
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
              "model": "meta-llama/llama-3.3-70b-instruct",
              "messages": messages,
              "temperature": 0.7,
              "max_tokens": 4096,
              "top_p": 0.9,
            }),
          ).timeout(const Duration(seconds: 30));
          
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
    return 'Sentinel AI Pro — Powered by Llama 3.3 70B';
  }

  /// Check if user has AI access - Allow all for V2
  static bool hasAIAccess(String? tier) {
    return true; // Allow all users for V2
  }

  /// Get tier-specific features description
  static String getTierFeatures(String tier) {
    return "✅ AI Chat Available:\n"
        "• Expert coding assistance\n"
        "• In-depth explanations\n"
        "• Code debugging & optimization\n"
        "• Career & learning guidance\n"
        "• Multi-turn conversations";
  }
}