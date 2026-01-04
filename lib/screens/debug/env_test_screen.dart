import 'package:flutter/material.dart';
import '../../services/env_config.dart';
import '../../services/ai_service.dart';

class EnvTestScreen extends StatefulWidget {
  const EnvTestScreen({super.key});

  @override
  State<EnvTestScreen> createState() => _EnvTestScreenState();
}

class _EnvTestScreenState extends State<EnvTestScreen> {
  String _testResult = 'Testing environment configuration...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _testEnvironment();
  }

  Future<void> _testEnvironment() async {
    try {
      final results = <String>[];
      
      // Test environment configuration
      results.add('🔧 Environment Configuration Test:');
      results.add('Groq API Key: ${EnvConfig.hasGroqKey ? "✅ Configured" : "❌ Missing"}');
      results.add('OpenRouter API Key: ${EnvConfig.hasOpenRouterKey ? "✅ Configured" : "❌ Missing"}');
      results.add('Bytez API Key: ${EnvConfig.hasBytezKey ? "✅ Configured" : "❌ Missing"}');
      results.add('Whois API Key: ${EnvConfig.hasWhoisKey ? "✅ Configured" : "❌ Missing"}');
      results.add('');
      
      if (EnvConfig.hasGroqKey) {
        results.add('Groq Key Preview: ${EnvConfig.groqApiKey.substring(0, 10)}...');
      }
      
      results.add('');
      results.add('🤖 AI Service Test:');
      
      // Test AI service
      try {
        final response = await AIService.getResponse(
          'Hello, this is a test message. Please respond with "AI is working!"',
          userTier: 'pro'
        );
        results.add('✅ AI Response: $response');
      } catch (e) {
        results.add('❌ AI Error: $e');
      }
      
      setState(() {
        _testResult = results.join('\n');
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResult = '❌ Test failed: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Environment Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading)
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Testing environment configuration...'),
                  ],
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      _testResult,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testEnvironment,
                    child: const Text('Retest'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}