import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'env_config.dart';

/// Cloudinary Service for video and image hosting
/// Used for: MicroDegree lesson videos, project demos, mentor intro videos
///
/// Supabase SQL: No tables needed — pure utility service
class CloudinaryService {
  // Read from .env via EnvConfig
  static String get cloudName => EnvConfig.cloudinaryCloudName;
  static String get uploadPreset => EnvConfig.cloudinaryUploadPreset;
  static String get _apiKey => EnvConfig.cloudinaryApiKey;

  static String get _uploadUrl => 'https://api.cloudinary.com/v1_1/$cloudName';

  /// Upload a video file to Cloudinary
  /// Returns a map with {url, publicId, duration} or null on error
  static Future<Map<String, dynamic>?> uploadVideo({
    required File videoFile,
    required String folder,
  }) async {
    try {
      final uri = Uri.parse('$_uploadUrl/video/upload');
      final request = http.MultipartRequest('POST', uri);

      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = folder;
      request.fields['resource_type'] = 'video';

      request.files.add(await http.MultipartFile.fromPath('file', videoFile.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('✅ Cloudinary video upload success: ${data['secure_url']}');
        return {
          'url': data['secure_url'],
          'publicId': data['public_id'],
          'duration': data['duration'],
          'format': data['format'],
          'bytes': data['bytes'],
        };
      } else {
        debugPrint('⚠️ Cloudinary video upload failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('⚠️ Cloudinary video upload error: $e');
      return null;
    }
  }

  /// Upload an image file to Cloudinary
  /// Returns the secure URL or null on error
  static Future<String?> uploadImage({
    required File imageFile,
    String folder = 'general',
  }) async {
    try {
      final uri = Uri.parse('$_uploadUrl/image/upload');
      final request = http.MultipartRequest('POST', uri);

      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = folder;

      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('✅ Cloudinary image upload success: ${data['secure_url']}');
        return data['secure_url'] as String?;
      } else {
        debugPrint('⚠️ Cloudinary image upload failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('⚠️ Cloudinary image upload error: $e');
      return null;
    }
  }

  /// Get video thumbnail from Cloudinary
  static String getVideoThumbnail(String publicId, {int width = 400, int height = 225}) {
    return 'https://res.cloudinary.com/$cloudName/video/upload/w_$width,h_$height,c_fill,so_1/$publicId.jpg';
  }

  /// Get adaptive streaming URL (HLS)
  static String getStreamingUrl(String publicId) {
    return 'https://res.cloudinary.com/$cloudName/video/upload/sp_auto/$publicId.m3u8';
  }

  /// Get direct video URL
  static String getVideoUrl(String publicId, {String format = 'mp4'}) {
    return 'https://res.cloudinary.com/$cloudName/video/upload/$publicId.$format';
  }

  /// Get optimized video URL with quality settings
  static String getOptimizedVideoUrl(String publicId, {int quality = 70}) {
    return 'https://res.cloudinary.com/$cloudName/video/upload/q_$quality/$publicId.mp4';
  }
}
