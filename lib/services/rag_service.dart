import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'ai_service.dart';
import 'env_config.dart';
import 'student_auth_service.dart';

/// RAG (Retrieval-Augmented Generation) Service for Nova AI
/// Uses OpenAI embeddings for semantic search + keyword fallback
///
/// --- Supabase SQL (run in SQL Editor) ---
/// -- Enable pgvector extension
/// CREATE EXTENSION IF NOT EXISTS vector;
///
/// CREATE TABLE IF NOT EXISTS sentinel_knowledge (
///   id bigserial PRIMARY KEY,
///   content text NOT NULL,
///   category text,
///   subject text,
///   metadata jsonb,
///   source text,
///   embedding vector(1536),
///   created_at timestamp DEFAULT now()
/// );
///
/// CREATE INDEX IF NOT EXISTS idx_knowledge_category ON sentinel_knowledge(category);
/// CREATE INDEX IF NOT EXISTS idx_knowledge_subject ON sentinel_knowledge(subject);
/// CREATE INDEX IF NOT EXISTS idx_knowledge_embedding ON sentinel_knowledge USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
///
/// ALTER TABLE sentinel_knowledge ENABLE ROW LEVEL SECURITY;
/// CREATE POLICY "Public read" ON sentinel_knowledge FOR SELECT USING (true);
/// CREATE POLICY "Anon insert" ON sentinel_knowledge FOR INSERT WITH CHECK (true);
///
/// -- Semantic search function (uses cosine similarity)
/// CREATE OR REPLACE FUNCTION match_knowledge(query_embedding vector(1536), match_count int DEFAULT 5)
/// RETURNS TABLE (id bigint, content text, category text, subject text, source text, similarity float)
/// LANGUAGE plpgsql AS $$
/// BEGIN
///   RETURN QUERY
///   SELECT sk.id, sk.content, sk.category, sk.subject, sk.source,
///          1 - (sk.embedding <=> query_embedding) AS similarity
///   FROM sentinel_knowledge sk
///   WHERE sk.embedding IS NOT NULL
///   ORDER BY sk.embedding <=> query_embedding
///   LIMIT match_count;
/// END;
/// $$;
///
/// CREATE TABLE IF NOT EXISTS ai_feedback (
///   id bigserial PRIMARY KEY,
///   question text NOT NULL,
///   answer text NOT NULL,
///   rating int,
///   correct_answer text,
///   student_id text,
///   created_at timestamp DEFAULT now()
/// );
///
/// ALTER TABLE ai_feedback ENABLE ROW LEVEL SECURITY;
/// CREATE POLICY "Public all" ON ai_feedback FOR ALL USING (true) WITH CHECK (true);
/// ---
class RAGService {
  static final _supabase = Supabase.instance.client;
  static const String _openaiEmbeddingModel = 'text-embedding-3-small';
  static const String _openaiEmbeddingUrl = 'https://api.openai.com/v1/embeddings';

  /// Generate embeddings via OpenAI API
  /// Returns a list of 1536-dimensional floats
  static Future<List<double>?> _getEmbedding(String text) async {
    try {
      final apiKey = EnvConfig.openaiApiKey;
      if (apiKey.isEmpty || apiKey == 'YOUR_OPENAI_API_KEY') {
        debugPrint('⚠️ OpenAI API key not configured, falling back to keyword search');
        return null;
      }

      final response = await http.post(
        Uri.parse(_openaiEmbeddingUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'input': text,
          'model': _openaiEmbeddingModel,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final embedding = List<double>.from(
          (data['data'][0]['embedding'] as List).map((e) => (e as num).toDouble()),
        );
        debugPrint('🧠 OpenAI embedding generated: ${embedding.length} dimensions');
        return embedding;
      } else {
        debugPrint('⚠️ OpenAI embedding error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('⚠️ Embedding generation error: $e');
      return null;
    }
  }

  /// Semantic search using vector embeddings (OpenAI + pgvector)
  /// Falls back to keyword search if embeddings aren't available
  static Future<List<Map<String, dynamic>>> searchKnowledge(String query) async {
    try {
      // Try semantic search first
      final embedding = await _getEmbedding(query);
      if (embedding != null) {
        try {
          final results = await _supabase.rpc('match_knowledge', params: {
            'query_embedding': embedding.toString(),
            'match_count': 5,
          });

          if (results != null && (results as List).isNotEmpty) {
            debugPrint('🧠 RAG Semantic: Found ${results.length} entries for: $query');
            return List<Map<String, dynamic>>.from(results);
          }
        } catch (e) {
          debugPrint('⚠️ Semantic search failed, falling back to keywords: $e');
        }
      }

      // Fallback: keyword-based search
      return _keywordSearch(query);
    } catch (e) {
      debugPrint('⚠️ RAG search error: $e');
      return [];
    }
  }

  /// Keyword-based fallback search
  static Future<List<Map<String, dynamic>>> _keywordSearch(String query) async {
    try {
      final terms = _extractKeyTerms(query);
      if (terms.isEmpty) return [];

      var queryBuilder = _supabase.from('sentinel_knowledge').select();

      final orFilter = terms.map((t) {
        return 'content.ilike.%$t%,category.ilike.%$t%,subject.ilike.%$t%';
      }).join(',');

      final results = await queryBuilder
          .or(orFilter)
          .limit(5)
          .order('created_at', ascending: false);

      debugPrint('🧠 RAG Keywords: Found ${results.length} entries for: $query');
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      debugPrint('⚠️ Keyword search error: $e');
      return [];
    }
  }

  /// Extract meaningful search terms from a query
  static List<String> _extractKeyTerms(String query) {
    final stopWords = {
      'what', 'is', 'the', 'a', 'an', 'how', 'to', 'do', 'does', 'can',
      'you', 'i', 'me', 'my', 'we', 'our', 'it', 'this', 'that', 'with',
      'in', 'on', 'at', 'for', 'of', 'and', 'or', 'but', 'not', 'are',
      'was', 'were', 'will', 'would', 'could', 'should', 'be', 'been',
      'have', 'has', 'had', 'about', 'tell', 'explain', 'describe',
    };

    final words = query.toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 2 && !stopWords.contains(w))
        .toSet()
        .toList();

    return words.take(5).toList();
  }

  /// Ask a question with RAG context enhancement
  /// First searches knowledge base, then injects relevant context into the AI prompt
  static Future<({String answer, List<String> sources})> askWithContext(
    String question, {
    List<Map<String, String>>? conversationHistory,
  }) async {
    try {
      // 1. Search knowledge base (semantic or keyword)
      final knowledge = await searchKnowledge(question);
      final sources = <String>[];

      // 2. Build context from knowledge
      String ragContext = '';
      if (knowledge.isNotEmpty) {
        final contextParts = <String>[];
        for (final entry in knowledge) {
          final content = entry['content'] ?? '';
          final category = entry['category'] ?? '';
          final subject = entry['subject'] ?? '';
          final source = entry['source'] ?? category;

          contextParts.add('[$category/$subject]: $content');
          if (source.isNotEmpty && !sources.contains(source)) {
            sources.add(source);
          }
        }
        ragContext = '\n\n=== ZERNO KNOWLEDGE BASE CONTEXT ===\n'
            'Use the following verified information to enhance your answer:\n'
            '${contextParts.join('\n\n')}\n'
            '=== END CONTEXT ===\n\n';
      }

      // 3. Enhance the question with RAG context
      final enhancedQuestion = ragContext.isNotEmpty
          ? '$ragContext\nStudent Question: $question'
          : question;

      // 4. Build history with enhanced last message
      final history = <Map<String, String>>[];
      if (conversationHistory != null) {
        history.addAll(conversationHistory);
        if (history.isNotEmpty && history.last['role'] == 'user') {
          history.last = {'role': 'user', 'content': enhancedQuestion};
        } else {
          history.add({'role': 'user', 'content': enhancedQuestion});
        }
      } else {
        history.add({'role': 'user', 'content': enhancedQuestion});
      }

      // 5. Get AI response
      final answer = await AIService.getResponse(
        enhancedQuestion,
        conversationHistory: history,
      );

      return (answer: answer, sources: sources);
    } catch (e) {
      debugPrint('⚠️ RAG ask error: $e');
      final fallback = await AIService.getResponse(question,
          conversationHistory: conversationHistory);
      return (answer: fallback, sources: <String>[]);
    }
  }

  /// Save feedback for AI response (thumbs up/down)
  static Future<void> saveFeedback({
    required String question,
    required String answer,
    required int rating, // 1 = thumbs up, -1 = thumbs down
    String? correctAnswer,
  }) async {
    try {
      final student = StudentAuthService.currentStudent;
      await _supabase.from('ai_feedback').insert({
        'question': question,
        'answer': answer,
        'rating': rating,
        'correct_answer': correctAnswer,
        'student_id': student?.id?.toString(),
      });
      debugPrint('✅ AI feedback saved: ${rating > 0 ? "👍" : "👎"}');
    } catch (e) {
      debugPrint('⚠️ AI feedback error: $e');
    }
  }

  /// Add knowledge to the database (with optional embedding generation)
  static Future<bool> addKnowledge({
    required String content,
    String? category,
    String? subject,
    String? source,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final insertData = {
        'content': content,
        'category': category,
        'subject': subject,
        'source': source,
        'metadata': metadata,
      };

      // Generate embedding if OpenAI is configured
      final embedding = await _getEmbedding(content);
      if (embedding != null) {
        insertData['embedding'] = embedding.toString();
      }

      await _supabase.from('sentinel_knowledge').insert(insertData);
      debugPrint('✅ Knowledge added: $category/$subject${embedding != null ? " (with embedding)" : ""}');
      return true;
    } catch (e) {
      debugPrint('⚠️ Add knowledge error: $e');
      return false;
    }
  }
}
