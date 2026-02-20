import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/job_listing_model.dart';
import '../../services/env_config.dart';

class LaunchpadService {
  static final _supabase = Supabase.instance.client;

  static String get _appId => EnvConfig.get('ADZUNA_APP_ID');
  static String get _appKey => EnvConfig.get('ADZUNA_APP_KEY');

  static const String _baseUrl = 'https://api.adzuna.com/v1/api/jobs/in/search';

  /// Fetch jobs from Adzuna API
  static Future<List<JobListing>> fetchJobs({
    String query = '',
    String where = '',
    int page = 1,
    int resultsPerPage = 20,
  }) async {
    try {
      final params = <String, String>{
        'app_id': _appId,
        'app_key': _appKey,
        'results_per_page': resultsPerPage.toString(),
        'content-type': 'application/json',
      };

      if (query.isNotEmpty) params['what'] = query;
      if (where.isNotEmpty) params['where'] = where;

      final uri = Uri.parse('$_baseUrl/$page').replace(queryParameters: params);
      debugPrint('🚀 [LaunchPad] Fetching: $uri');

      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List? ?? [];
        return results.map((j) => JobListing.fromAdzuna(j)).toList();
      } else {
        debugPrint('⚠️ [LaunchPad] API error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('❌ [LaunchPad] Fetch error: $e');
      return [];
    }
  }

  /// Fetch featured/manually curated jobs from Supabase
  static Future<List<JobListing>> fetchFeaturedJobs() async {
    try {
      final data = await _supabase
          .from('job_listings')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(10);

      return (data as List).map((j) => JobListing.fromSupabase(j)).toList();
    } catch (e) {
      debugPrint('⚠️ [LaunchPad] Featured jobs error: $e');
      return [];
    }
  }

  /// Get all jobs: featured first, then API results
  static Future<List<JobListing>> getAllJobs({
    String query = '',
    String where = '',
    int page = 1,
  }) async {
    final userId = _supabase.auth.currentUser?.id;

    // Fetch in parallel
    final results = await Future.wait([
      page == 1 ? fetchFeaturedJobs() : Future.value(<JobListing>[]),
      fetchJobs(query: query, where: where, page: page),
      userId != null ? getSavedJobIds(userId) : Future.value(<String>{}),
    ]);

    final featured = results[0] as List<JobListing>;
    final apiJobs = results[1] as List<JobListing>;
    final savedIds = results[2] as Set<String>;

    // Mark saved status
    final allJobs = [...featured, ...apiJobs];
    for (final job in allJobs) {
      job.isSaved = savedIds.contains(job.id);
    }

    return allJobs;
  }

  /// Get IDs of saved jobs for current user
  static Future<Set<String>> getSavedJobIds(String userId) async {
    try {
      final data = await _supabase
          .from('saved_jobs')
          .select('job_id')
          .eq('user_id', userId);

      return (data as List).map((r) => r['job_id'] as String).toSet();
    } catch (e) {
      debugPrint('⚠️ [LaunchPad] Saved IDs error: $e');
      return {};
    }
  }

  /// Save a job to Supabase
  static Future<bool> saveJob(JobListing job) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase.from('saved_jobs').upsert(
        job.toSavedMap(userId),
        onConflict: 'user_id,job_id',
      );
      debugPrint('✅ [LaunchPad] Job saved: ${job.title}');
      return true;
    } catch (e) {
      debugPrint('❌ [LaunchPad] Save error: $e');
      return false;
    }
  }

  /// Remove a saved job
  static Future<bool> unsaveJob(String jobId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase
          .from('saved_jobs')
          .delete()
          .eq('user_id', userId)
          .eq('job_id', jobId);
      debugPrint('✅ [LaunchPad] Job unsaved: $jobId');
      return true;
    } catch (e) {
      debugPrint('❌ [LaunchPad] Unsave error: $e');
      return false;
    }
  }

  /// Get all saved jobs for current user
  static Future<List<JobListing>> getSavedJobs() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final data = await _supabase
          .from('saved_jobs')
          .select()
          .eq('user_id', userId)
          .order('saved_at', ascending: false);

      return (data as List).map((j) => JobListing.fromSaved(j)).toList();
    } catch (e) {
      debugPrint('⚠️ [LaunchPad] Get saved error: $e');
      return [];
    }
  }
}
