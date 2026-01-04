import 'dart:convert';
import 'package:flutter/services.dart';

/// Service for loading cheatsheet data from JSON files
/// Replaces hardcoded Dart strings with JSON-based architecture
class CheatsheetLoaderService {
  // Cache for loaded data
  static Map<String, dynamic>? _indexCache;
  static final Map<String, Map<String, String>> _snippetsCache = {};

  /// Load the master cheatsheets index
  /// Returns the full index with all categories and cheatsheet metadata
  static Future<Map<String, dynamic>> loadIndex() async {
    // Return cached data if available
    if (_indexCache != null) {
      return _indexCache!;
    }

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/cheatsheets_index.json',
      );
      _indexCache = json.decode(jsonString) as Map<String, dynamic>;
      return _indexCache!;
    } catch (e) {
      print('Error loading cheatsheets index: $e');
      rethrow;
    }
  }

  /// Load snippets for a specific cheatsheet
  /// @param filePath: Relative path from assets/data/cheatsheets/
  /// Returns a map of snippet titles to code content
  static Future<Map<String, String>> loadSnippets(String filePath) async {
    // Return cached data if available
    if (_snippetsCache.containsKey(filePath)) {
      return _snippetsCache[filePath]!;
    }

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/cheatsheets/$filePath',
      );
      final data = json.decode(jsonString) as Map<String, dynamic>;
      
      // Extract snippets map
      final snippets = data['snippets'] as Map<String, dynamic>;
      final result = Map<String, String>.from(
        snippets.map((key, value) => MapEntry(key, value.toString())),
      );
      
      // Cache for future use
      _snippetsCache[filePath] = result;
      
      return result;
    } catch (e) {
      print('Error loading snippets from $filePath: $e');
      rethrow;
    }
  }

  /// Get all cheatsheets from a specific category
  /// @param categoryId: Category identifier (e.g., 'programming', 'frameworks')
  /// Returns list of cheatsheet metadata
  static Future<List<Map<String, dynamic>>> getCheatsheetsByCategory(
    String categoryId,
  ) async {
    final index = await loadIndex();
    final categories = index['categories'] as List<dynamic>;
    
    final category = categories.firstWhere(
      (cat) => cat['id'] == categoryId,
      orElse: () => null,
    );
    
    if (category == null) {
      return [];
    }
    
    return List<Map<String, dynamic>>.from(category['cheatsheets'] as List);
  }

  /// Search cheatsheets by title or category
  /// @param query: Search term
  /// Returns list of matching cheatsheets
  static Future<List<Map<String, dynamic>>> searchCheatsheets(
    String query,
  ) async {
    if (query.isEmpty) {
      return getAllCheatsheets();
    }

    final index = await loadIndex();
    final categories = index['categories'] as List<dynamic>;
    final results = <Map<String, dynamic>>[];
    
    final lowerQuery = query.toLowerCase();
    
    for (final category in categories) {
      final cheatsheets = category['cheatsheets'] as List<dynamic>;
      for (final sheet in cheatsheets) {
        final title = (sheet['title'] as String).toLowerCase();
        final categoryName = (category['name'] as String).toLowerCase();
        
        if (title.contains(lowerQuery) || categoryName.contains(lowerQuery)) {
          results.add(Map<String, dynamic>.from(sheet as Map));
        }
      }
    }
    
    return results;
  }

  /// Get all cheatsheets across all categories
  static Future<List<Map<String, dynamic>>> getAllCheatsheets() async {
    final index = await loadIndex();
    final categories = index['categories'] as List<dynamic>;
    final results = <Map<String, dynamic>>[];
    
    for (final category in categories) {
      final categoryId = category['id'] as String;
      final cheatsheets = category['cheatsheets'] as List<dynamic>;
      results.addAll(
        cheatsheets.map((sheet) {
          final sheetMap = Map<String, dynamic>.from(sheet as Map);
          sheetMap['category'] = categoryId; // Add category field
          return sheetMap;
        }),
      );
    }
    
    return results;
  }

  /// Clear all caches (useful for testing or memory management)
  static void clearCache() {
    _indexCache = null;
    _snippetsCache.clear();
  }

  /// Get total number of cheatsheets
  static Future<int> getTotalCount() async {
    final index = await loadIndex();
    return index['total_cheatsheets'] as int? ?? 0;
  }

  /// Get all categories
  static Future<List<Map<String, dynamic>>> getCategories() async {
    final index = await loadIndex();
    return List<Map<String, dynamic>>.from(index['categories'] as List);
  }
}
