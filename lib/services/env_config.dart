import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment Configuration Service
/// Handles loading and accessing environment variables securely
class EnvConfig {
  static bool _isInitialized = false;

  /// Initialize the environment configuration
  /// Call this in main() before runApp()
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Try to load .env.local first (for local development)
      await dotenv.load(fileName: '.env.local');
    } catch (e) {
      try {
        // Fallback to .env file
        await dotenv.load(fileName: '.env');
      } catch (e) {
        // If no .env file exists, continue with empty config
        // Environment variables can still be set at runtime
        print('Warning: No .env file found. Using system environment variables only.');
      }
    }
    
    _isInitialized = true;
  }

  /// Get environment variable with optional default value
  static String get(String key, {String defaultValue = ''}) {
    if (!_isInitialized) {
      throw Exception('EnvConfig not initialized. Call EnvConfig.initialize() first.');
    }
    return dotenv.env[key] ?? defaultValue;
  }

  /// Check if an environment variable exists and is not empty
  static bool has(String key) {
    if (!_isInitialized) return false;
    final value = dotenv.env[key];
    return value != null && value.isNotEmpty;
  }

  // API Keys getters
  static String get groqApiKey => get('GROQ_API_KEY');
  static String get openRouterApiKey => get('OPENROUTER_API_KEY');
  static String get bytezApiKey => get('BYTEZ_API_KEY');
  static String get whoisApiKey => get('WHOIS_API_KEY');

  // Validation methods
  static bool get hasGroqKey => has('GROQ_API_KEY') && groqApiKey != 'your_groq_api_key_here';
  static bool get hasOpenRouterKey => has('OPENROUTER_API_KEY') && openRouterApiKey != 'your_openrouter_api_key_here';
  static bool get hasBytezKey => has('BYTEZ_API_KEY') && bytezApiKey != 'your_bytez_api_key_here';
  static bool get hasWhoisKey => has('WHOIS_API_KEY') && whoisApiKey != 'your_whois_api_key_here';
}