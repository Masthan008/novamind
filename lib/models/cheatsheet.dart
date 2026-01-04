import 'package:hive/hive.dart';

part 'cheatsheet.g.dart';

@HiveType(typeId: 10)
class CheatSheet extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final String icon;

  @HiveField(4)
  final String url;

  @HiveField(5)
  final String difficulty;

  @HiveField(6)
  final List<String> tags;

  @HiveField(7)
  final String description;

  @HiveField(8)
  bool isFavorite;

  @HiveField(9)
  int viewCount;

  @HiveField(10)
  DateTime? lastViewed;

  CheatSheet({
    required this.id,
    required this.title,
    required this.category,
    required this.icon,
    required this.url,
    required this.difficulty,
    required this.tags,
    required this.description,
    this.isFavorite = false,
    this.viewCount = 0,
    this.lastViewed,
  });

  // Helper method to increment view count
  void incrementViewCount() {
    viewCount++;
    lastViewed = DateTime.now();
    save(); // Save to Hive
  }

  // Toggle favorite status
  void toggleFavorite() {
    isFavorite = !isFavorite;
    save(); // Save to Hive
  }
}

// Category enum for better organization
enum CheatSheetCategory {
  programming,
  tools,
  database,
  linux,
  shortcuts,
  webDev,
  devOps,
  other,
}

// Extension for category display
extension CheatSheetCategoryExtension on CheatSheetCategory {
  String get displayName {
    switch (this) {
      case CheatSheetCategory.programming:
        return 'Programming';
      case CheatSheetCategory.tools:
        return 'Dev Tools';
      case CheatSheetCategory.database:
        return 'Databases';
      case CheatSheetCategory.linux:
        return 'Linux Commands';
      case CheatSheetCategory.shortcuts:
        return 'Keyboard Shortcuts';
      case CheatSheetCategory.webDev:
        return 'Web Development';
      case CheatSheetCategory.devOps:
        return 'DevOps';
      case CheatSheetCategory.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case CheatSheetCategory.programming:
        return '🐍';
      case CheatSheetCategory.tools:
        return '🛠️';
      case CheatSheetCategory.database:
        return '💾';
      case CheatSheetCategory.linux:
        return '🐧';
      case CheatSheetCategory.shortcuts:
        return '⌨️';
      case CheatSheetCategory.webDev:
        return '🌐';
      case CheatSheetCategory.devOps:
        return '🚀';
      case CheatSheetCategory.other:
        return '📚';
    }
  }
}
