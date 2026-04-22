import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'env_config.dart';

/// Imagekit Service for optimized image hosting
/// Used for: profile photos, mentor photos, skill badges, course thumbnails, company logos
///
/// Supabase SQL: No tables needed — pure utility service
class ImagekitService {
  // Read from .env via EnvConfig
  static String get _imagekitId => EnvConfig.imagekitId;
  static String get baseUrl => 'https://ik.imagekit.io/$_imagekitId';
  static String get _uploadUrl => 'https://upload.imagekit.io/api/v1/files/upload';
  static String get _privateKey => EnvConfig.imagekitPrivateKey;

  /// Upload an image file to Imagekit
  /// Returns the public URL or null on error
  static Future<String?> uploadImage({
    required File imageFile,
    required String fileName,
    String folder = '/zerno',
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse(_uploadUrl),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$_privateKey:'))}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'file': base64Image,
          'fileName': fileName,
          'folder': folder,
          'useUniqueFileName': true,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final url = data['url'] as String?;
        debugPrint('✅ Imagekit upload success: $url');
        return url;
      } else {
        debugPrint('⚠️ Imagekit upload failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('⚠️ Imagekit upload error: $e');
      return null;
    }
  }

  /// Get optimized URL with width/height transforms
  static String getOptimizedUrl(String path, {int? width, int? height, int quality = 80}) {
    final transforms = <String>[];
    if (width != null) transforms.add('w-$width');
    if (height != null) transforms.add('h-$height');
    transforms.add('q-$quality');
    transforms.add('f-webp'); // auto webp for smaller size

    final transformStr = transforms.join(',');
    return '$baseUrl/tr:$transformStr$path';
  }

  /// Profile photo URL (200x200)
  static String profilePhoto(String path) {
    return getOptimizedUrl(path, width: 200, height: 200, quality: 85);
  }

  /// Course thumbnail (400x225)
  static String courseThumbnail(String path) {
    return getOptimizedUrl(path, width: 400, height: 225, quality: 80);
  }

  /// Skill badge (100x100)
  static String skillBadge(String path) {
    return getOptimizedUrl(path, width: 100, height: 100, quality: 90);
  }

  /// Mentor photo (300x300)
  static String mentorPhoto(String path) {
    return getOptimizedUrl(path, width: 300, height: 300, quality: 85);
  }

  /// Company logo (200x200)
  static String companyLogo(String path) {
    return getOptimizedUrl(path, width: 200, height: 200, quality: 90);
  }
}
