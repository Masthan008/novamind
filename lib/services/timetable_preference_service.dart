import 'package:hive_flutter/hive_flutter.dart';

class TimetablePreferenceService {
  static const String _boxName = 'timetable_preferences';
  static const String _branchKey = 'selected_branch';
  static const String _sectionKey = 'selected_section';
  static const String _isSetupCompleteKey = 'timetable_setup_complete';
  static const String _lastUpdatedKey = 'timetable_last_updated';

  static Box? _box;

  /// Initialize the preference service
  static Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  /// Get the preferences box
  static Box get _prefsBox {
    if (_box == null) {
      throw Exception('TimetablePreferenceService not initialized. Call init() first.');
    }
    return _box!;
  }

  /// Save the selected branch and section
  static Future<void> saveSelectedTimetable(String branch, String section) async {
    await _prefsBox.put(_branchKey, branch);
    await _prefsBox.put(_sectionKey, section);
    await _prefsBox.put(_isSetupCompleteKey, true);
    await _prefsBox.put(_lastUpdatedKey, DateTime.now().toIso8601String());
  }

  /// Get the selected branch
  static String? getSelectedBranch() {
    return _prefsBox.get(_branchKey);
  }

  /// Get the selected section
  static String? getSelectedSection() {
    return _prefsBox.get(_sectionKey);
  }

  /// Check if timetable setup is complete
  static bool isSetupComplete() {
    return _prefsBox.get(_isSetupCompleteKey, defaultValue: false);
  }

  /// Get the last updated timestamp
  static DateTime? getLastUpdated() {
    final dateString = _prefsBox.get(_lastUpdatedKey);
    if (dateString != null) {
      return DateTime.tryParse(dateString);
    }
    return null;
  }

  /// Clear all timetable preferences (for reset)
  static Future<void> clearPreferences() async {
    await _prefsBox.delete(_branchKey);
    await _prefsBox.delete(_sectionKey);
    await _prefsBox.delete(_isSetupCompleteKey);
    await _prefsBox.delete(_lastUpdatedKey);
  }

  /// Get all available branches and sections
  static Map<String, List<String>> getAvailableTimetables() {
    return {
      'ECE': ['A', 'B', 'C', 'D'],
      'EEE': ['A', 'B', 'C', 'D'],
      'ME': ['A', 'B'],
      'CSE': ['A', 'B', 'C', 'D', 'E', 'F'],
      'CSE-AIML': ['A', 'B', 'C', 'D'],
      'CSE-DS': ['A', 'B', 'C'],
      'CSE-CS': ['A', 'B'],
    };
  }

  /// Get display names for branches
  static Map<String, String> getBranchDisplayNames() {
    return {
      'ECE': 'Electronics & Communication Engineering',
      'EEE': 'Electrical & Electronics Engineering',
      'ME': 'Mechanical Engineering',
      'CSE': 'Computer Science & Engineering',
      'CSE-AIML': 'CSE - Artificial Intelligence & Machine Learning',
      'CSE-DS': 'CSE - Data Science',
      'CSE-CS': 'CSE - Cyber Security',
    };
  }

  /// Get formatted timetable identifier
  static String getFormattedTimetableId() {
    final branch = getSelectedBranch();
    final section = getSelectedSection();
    
    if (branch != null && section != null) {
      final displayName = getBranchDisplayNames()[branch] ?? branch;
      return '$displayName - Section $section';
    }
    
    return 'No Timetable Selected';
  }

  /// Check if a specific timetable combination exists
  static bool isValidTimetable(String branch, String section) {
    final available = getAvailableTimetables();
    return available.containsKey(branch) && 
           available[branch]!.contains(section);
  }

  /// Get total number of available timetables
  static int getTotalTimetableCount() {
    final available = getAvailableTimetables();
    return available.values.fold(0, (sum, sections) => sum + sections.length);
  }
}