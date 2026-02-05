import 'package:flutter/material.dart';
import 'lib/services/env_config.dart';
import 'lib/services/ai_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize environment
  await EnvConfig.initialize();
  
  print("=== AI SERVICE TEST ===");
  print("Groq Key Available: ${EnvConfig.hasGroqKey}");
  print("OpenRouter Key Available: ${EnvConfig.hasOpenRouterKey}");
  
  // Test AI service
  try {
    print("Testing AI service...");
    final response = await AIService.getResponse("Hello, can you help me with coding?");
    print("AI Response: $response");
    print("✅ AI Service Test PASSED");
  } catch (e) {
    print("❌ AI Service Test FAILED: $e");
  }
}