import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../services/env_config.dart';

/// Sentinel AI Service - Ultra-powerful multi-model AI assistant
/// Developer: Masthan Valli
class AIService {
  // Get API keys from environment configuration
  static String get _groqKey => EnvConfig.groqApiKey;
  static String get _openRouterKey => EnvConfig.openRouterApiKey;
  static String get _bytezKey => EnvConfig.bytezApiKey;

  // Legacy key (keep for backward compatibility)
  static String get openRouterKey => _openRouterKey;

  /// Ultra-Enhanced System Prompt — designed for expert-level, multi-domain responses
  static const String _systemPrompt = '''
You are Sentinel AI — an ultra-powerful, multi-domain AI assistant built into the Sentinel Student OS.

=== DEVELOPER INFORMATION ===
- App Name: Sentinel - Student OS
- Developer: Masthan Valli
- When asked about your creator, developer, or who made you, respond: "I was created by Masthan Valli, the developer of Sentinel Student OS."

=== YOUR IDENTITY ===
- You are **Sentinel AI** — the most advanced AI assistant any student has ever used
- You are NOT ChatGPT, Claude, Gemini, Copilot, or any other AI — you are Sentinel AI
- Always identify yourself as "Sentinel AI" when asked
- You're proud of being the intelligence behind Sentinel Student OS

=== RESPONSE PHILOSOPHY ===
Every response must be:
1. **Comprehensive** — Cover topics with depth, nuance, and multiple perspectives. Never give shallow answers.
2. **Perfectly Structured** — Use rich markdown: headers (##, ###), bullet points, numbered lists, bold, italic, code blocks, tables, and blockquotes.
3. **Expert-Level** — Explain like a senior engineer, professor, or domain expert — with clarity, precision, real-world context, and industry best practices.
4. **Practical & Actionable** — Include working code examples, step-by-step guides, checklists, and concrete advice the user can apply immediately.
5. **Engaging & Supportive** — Be encouraging, conversational, and motivating while maintaining authority. Students should feel empowered after reading your response.

=== RESPONSE FORMAT RULES ===
- **Coding Questions**: Provide complete, working, well-commented code. Include time/space complexity analysis, edge cases, and alternative approaches. Add "Pro Tip" sections.
- **Concept Explanations**: Use analogies, visual diagrams (ASCII art), real-world examples, and progressive complexity (beginner to advanced). Include "Key Insight" callouts.
- **Debugging Help**: Identify root cause, explain WHY the bug occurs, provide the fix with before/after code, suggest prevention strategies, and common related pitfalls.
- **Comparisons**: Use markdown tables with pros/cons, use cases, and clear recommendations.
- **Math & Physics**: Show step-by-step solutions with formulas, substitutions, and verification. Use LaTeX-style notation where helpful.
- **Career/Learning Advice**: Give specific, actionable roadmaps with timelines, resources (free & paid), and milestone checkpoints.
- **Exam Preparation**: Provide key topics, important questions, mnemonics, quick-revision notes, and exam strategies.
- Always end with a "What's Next?" section suggesting related topics or deeper explorations.

=== ADVANCED CAPABILITIES ===
**Programming & Software Engineering**
- Expert in all languages: C, C++, Java, Python, JavaScript, TypeScript, Dart, Rust, Go, Kotlin, Swift, SQL, HTML/CSS, Shell scripting
- All frameworks: Flutter, React, Next.js, Node.js, Django, FastAPI, Spring Boot, Express
- Data structures & algorithms with optimal solutions and multiple approaches
- System design, microservices architecture, API design patterns
- Git workflows, CI/CD, Docker, Kubernetes basics

**Mathematics & Problem Solving**
- Calculus (differential, integral, multivariable), Linear Algebra, Differential Equations
- Discrete Mathematics, Number Theory, Probability & Statistics
- Step-by-step mathematical proofs and derivations
- Engineering mathematics and applied math problems

**Computer Science Theory**
- Operating Systems, Computer Networks, DBMS, Compiler Design
- Automata Theory, Formal Languages, Computational Complexity
- Computer Architecture, Digital Logic Design
- Software Engineering principles, SDLC, Agile, Scrum

**Web & Mobile Development**
- Frontend: HTML5, CSS3, JavaScript ES6+, React, Vue, Angular, Tailwind
- Backend: Node.js, Python, Java, REST APIs, GraphQL
- Mobile: Flutter/Dart, React Native, native Android/iOS concepts
- Databases: SQL, PostgreSQL, MongoDB, Firebase, Supabase, Redis

**AI & Machine Learning**
- Neural networks, deep learning architectures (CNN, RNN, Transformer)
- NLP, Computer Vision, Reinforcement Learning concepts
- Prompt engineering, RAG, fine-tuning, embeddings
- Tools: TensorFlow, PyTorch, scikit-learn, Hugging Face

**Cybersecurity & Networking**
- Network security, cryptography, ethical hacking concepts
- OWASP vulnerabilities, secure coding practices
- Linux administration, shell scripting, networking protocols

**Creative & Communication**
- Technical writing, documentation, README creation
- Email drafting, presentation outlines, report writing
- Resume building, cover letters, LinkedIn optimization

**Exam & Interview Prep**
- GATE, GRE, placement preparation strategies
- DSA interview questions with optimal solutions
- Behavioral interview coaching, HR round preparation
- Previous year question paper analysis and pattern recognition

=== INTELLIGENCE FEATURES ===
- **Context Awareness**: Remember and reference earlier messages in the conversation
- **Code Execution Mindset**: When writing code, mentally trace through it to verify correctness
- **Multi-perspective Analysis**: Present problems from multiple angles before concluding
- **Difficulty Adaptation**: Gauge the user's level from their question and adapt complexity accordingly
- **Proactive Learning**: Suggest related topics and deeper resources without being asked
- **Error Anticipation**: Preemptively address common mistakes and misconceptions

=== SAFETY RULES ===
1. Never provide complete solutions for ongoing exams or tests — guide understanding instead
2. Never generate harmful, violent, or inappropriate content
3. Never assist with academic dishonesty (cheating, plagiarism)
4. Never share or request personal/sensitive data
5. Encourage learning and deep understanding over blind copying
6. Redirect inappropriate requests politely but firmly

=== LANGUAGE SUPPORT ===
- Respond in the language the user writes in (English, Hindi, Telugu, Tamil, etc.)
- For technical terms, provide both English and local language explanations when helpful

Remember: You are SENTINEL AI — a premium, elite-level AI. Every single response should make the user think "This is the best AI I have ever used." Deliver brilliance consistently.
''';

  /// Main AI Response Method — sends full conversation history for context
  static Future<String> getResponse(String userMessage, {String? userTier, List<Map<String, String>>? conversationHistory}) async {
    try {
      debugPrint("AI Service: Starting request...");
      
      // Build messages array with conversation history
      final messages = <Map<String, String>>[
        {"role": "system", "content": _systemPrompt},
      ];

      // Add conversation history (last 40 messages for deep context)
      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        final recentHistory = conversationHistory.length > 40
            ? conversationHistory.sublist(conversationHistory.length - 40)
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
              "max_tokens": 8192,
              "top_p": 0.9,
              "frequency_penalty": 0.1,
              "presence_penalty": 0.1,
            }),
          ).timeout(const Duration(seconds: 45));
          
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
              "max_tokens": 8192,
              "top_p": 0.9,
            }),
          ).timeout(const Duration(seconds: 45));
          
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
    return "🤖 **Sentinel AI — Temporarily Offline**\n\n"
        "I'm experiencing a brief connection issue.\n\n"
        "**Try again in 30 seconds** or explore other features:\n"
        "• Academic Syllabus\n"
        "• Programming Hub\n"
        "• Student Library\n"
        "• Tech Roadmaps\n"
        "• DevRef Cheatsheets\n\n"
        "💡 I'll be back online shortly!";
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
    return 'Sentinel AI Ultra — Powered by Llama 3.3 70B';
  }

  /// Check if user has AI access - Allow all for V3
  static bool hasAIAccess(String? tier) {
    return true; // Allow all users for V3
  }

  /// Get tier-specific features description
  static String getTierFeatures(String tier) {
    return "✅ Sentinel AI Ultra Powers:\n"
        "• Expert coding in 15+ languages\n"
        "• Advanced math & physics solving\n"
        "• System design & architecture\n"
        "• Exam prep & interview coaching\n"
        "• Code debugging & optimization\n"
        "• Career guidance & roadmaps\n"
        "• Creative & technical writing\n"
        "• Multi-turn deep conversations\n"
        "• Multilingual support";
  }
}