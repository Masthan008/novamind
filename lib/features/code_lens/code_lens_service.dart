import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../services/env_config.dart';

/// Code Lens Service
/// Handles OCR text extraction and Groq AI-powered code cleanup
class CodeLensService {
  static final _textRecognizer = TextRecognizer();

  /// Extract text from an image file using ML Kit OCR
  static Future<String> extractText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final recognized = await _textRecognizer.processImage(inputImage);
    return recognized.text;
  }

  /// Clean scanned code using Groq API (llama-3.1-8b-instant)
  /// Falls back to raw text if AI is unavailable
  static Future<CodeLensResult> cleanCode(String rawText, {String language = 'auto'}) async {
    if (!EnvConfig.hasGroqKey) {
      return CodeLensResult(
        cleanedCode: rawText,
        isRaw: true,
        error: 'Groq API key not configured. Showing raw OCR text.',
      );
    }

    try {
      final prompt = '''I have scanned this code from a screen/paper using OCR. It may have OCR errors (like '1' vs 'l', '0' vs 'O', missing indentation, broken lines).

Fix the syntax errors, correct OCR mistakes, format it with proper indentation, and return ONLY the clean code block — no explanations, no markdown fences, no extra text.

Language hint: $language (if "auto", detect the language automatically).

Raw OCR Text:
$rawText''';

      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${EnvConfig.groqApiKey}',
        },
        body: jsonEncode({
          'model': 'llama-3.1-8b-instant',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a code formatting assistant. You receive OCR-scanned code that may contain errors. Fix syntax, correct OCR mistakes, and return ONLY the clean code. No explanations, no markdown fences.'
            },
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.3,
          'max_tokens': 2048,
        }),
      ).timeout(const Duration(seconds: 15));

      debugPrint('Code Lens: Groq response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]?['message']?['content'];
        if (content != null && content.toString().trim().isNotEmpty) {
          String result = content.toString().trim();

          // Strip markdown code fences if AI accidentally adds them
          if (result.startsWith('```')) {
            final lines = result.split('\n');
            if (lines.length > 2) {
              lines.removeAt(0);
              if (lines.last.trim() == '```') {
                lines.removeLast();
              }
              result = lines.join('\n');
            }
          }

          return CodeLensResult(cleanedCode: result, isRaw: false);
        }
      }

      debugPrint('Code Lens: Groq error ${response.statusCode}: ${response.body}');
      return CodeLensResult(
        cleanedCode: rawText,
        isRaw: true,
        error: 'AI returned empty response. Showing raw OCR text.',
      );
    } catch (e) {
      debugPrint('Code Lens: Groq failed: $e');
      return CodeLensResult(
        cleanedCode: rawText,
        isRaw: true,
        error: 'AI cleanup failed (${e.toString().split('\n').first}). Showing raw OCR text.',
      );
    }
  }

  static void dispose() {
    _textRecognizer.close();
  }
}

/// Result from code cleaning
class CodeLensResult {
  final String cleanedCode;
  final bool isRaw;
  final String? error;

  CodeLensResult({
    required this.cleanedCode,
    required this.isRaw,
    this.error,
  });
}
