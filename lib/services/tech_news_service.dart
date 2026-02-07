import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service for fetching Tech News from NewsAPI.org
/// Used for Morning/Evening Tech Briefings and Tech News Tab
class TechNewsService {
  // API Key from .env file (with fallback)
  static String get _apiKey => 
      dotenv.env['NEWS_API_KEY'] ?? 'ddad3d25e59d4452b9934c2982581bc7';

  /// Fetch latest Tech Headlines from India
  /// Used for the home screen briefing card
  Future<List<Map<String, dynamic>>> getDailyTechNews({int limit = 5}) async {
    final url = Uri.parse(
      "https://newsapi.org/v2/top-headlines?country=in&category=technology&pageSize=$limit&apiKey=$_apiKey"
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = (data['articles'] as List?) ?? [];
        return articles.map((a) => Map<String, dynamic>.from(a)).toList();
      } else {
        debugPrint('⚠️ Tech News API Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('⚠️ Tech News Error: $e');
      return [];
    }
  }

  /// Fetch comprehensive Tech News for the dedicated tab
  /// Fetches more articles with broader tech topics
  Future<List<Map<String, dynamic>>> getComprehensiveTechNews({int limit = 20}) async {
    final url = Uri.parse(
      "https://newsapi.org/v2/everything?q=technology OR AI OR blockchain OR cybersecurity&language=en&sortBy=publishedAt&pageSize=$limit&apiKey=$_apiKey"
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = (data['articles'] as List?) ?? [];
        return articles.map((a) => Map<String, dynamic>.from(a)).toList();
      } else {
        // Fallback to headlines if 'everything' endpoint fails
        return getDailyTechNews(limit: limit);
      }
    } catch (e) {
      debugPrint('⚠️ Tech News Error: $e');
      return getDailyTechNews(limit: limit);
    }
  }

  /// Check if it's briefing time (Morning or Evening)
  static BriefingTimeInfo getBriefingTimeInfo() {
    final hour = DateTime.now().hour;
    
    // Morning: 6 AM - 11:59 AM
    if (hour >= 6 && hour < 12) {
      return BriefingTimeInfo(
        isBriefingTime: true,
        greeting: '🌅 Morning Tech Brief',
        description: 'Start your day with the latest in tech',
      );
    }
    // Evening: 5 PM - 10 PM
    else if (hour >= 17 && hour < 22) {
      return BriefingTimeInfo(
        isBriefingTime: true,
        greeting: '🌇 Evening Tech Roundup',
        description: 'Catch up on today\'s tech highlights',
      );
    }
    // Rest of the day
    else {
      return BriefingTimeInfo(
        isBriefingTime: false,
        greeting: 'Tech News',
        description: 'Latest technology updates',
      );
    }
  }
}

/// Model for briefing time information
class BriefingTimeInfo {
  final bool isBriefingTime;
  final String greeting;
  final String description;

  BriefingTimeInfo({
    required this.isBriefingTime,
    required this.greeting,
    required this.description,
  });
}
