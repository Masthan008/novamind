import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/class_session.dart';
import '../data/timetable_data.dart';

class TimetableManager {
  static const String _boxName = 'class_sessions';
  
  /// Update timetable with new branch and section data
  static Future<void> updateTimetable(String branch, String section) async {
    try {
      debugPrint("🔄 TimetableManager: Updating timetable to $branch - $section");
      
      // 🟢 FIX: Normalize branch name to match TimetableData keys
      String normalizedBranch = _normalizeBranchName(branch);
      debugPrint("Normalized branch: $normalizedBranch");
      
      // 1. Get the schedule data
      final scheduleData = TimetableData.getSchedule(normalizedBranch, section);
      debugPrint("Looking for Schedule Key: $normalizedBranch - $section");
      debugPrint("Found schedule data: ${scheduleData.isNotEmpty ? 'YES' : 'NO'}");
      
      if (scheduleData.isEmpty || scheduleData.values.first.contains('No Data')) {
        debugPrint("❌ No schedule data found for $normalizedBranch - $section");
        return;
      }
      
      // 2. Open Hive box
      final box = Hive.isBoxOpen(_boxName)
          ? Hive.box<ClassSession>(_boxName)
          : await Hive.openBox<ClassSession>(_boxName);
      
      // 3. Clear existing data
      await box.clear();
      debugPrint("🗑️ Cleared existing timetable data");
      
      // 4. Create new sessions from schedule data
      final sessions = _createSessionsFromSchedule(scheduleData);
      debugPrint("📚 Created ${sessions.length} new sessions");
      
      // 5. Save to Hive
      for (final session in sessions) {
        await box.put(session.id, session);
      }
      
      debugPrint("✅ Successfully updated timetable with ${sessions.length} sessions");
      
    } catch (e) {
      debugPrint("❌ Error updating timetable: $e");
      rethrow;
    }
  }
  
  /// Normalize branch names to match TimetableData keys
  static String _normalizeBranchName(String branch) {
    switch (branch.toUpperCase()) {
      case 'CSE-AIML':
      case 'CSE-AI&ML':
        return 'CSE-AIML';
      case 'CSE-CS':
        return 'CSE-CS';
      case 'CSE-DS':
        return 'CSE-DS';
      case 'CSE':
        return 'CSE';
      case 'ECE':
        return 'ECE';
      case 'EEE':
        return 'EEE';
      case 'ME':
      case 'MECH':
        return 'ME';
      default:
        return branch.toUpperCase();
    }
  }
  
  /// Create ClassSession objects from schedule data
  static List<ClassSession> _createSessionsFromSchedule(Map<String, List<String>> scheduleData) {
    final sessions = <ClassSession>[];
    final now = DateTime.now();
    
    // Period timings mapping
    final periodTimes = [
      {'start': 9, 'startMin': 0, 'end': 10, 'endMin': 40},   // Period 1: 9:00-10:40
      {'start': 11, 'startMin': 0, 'end': 11, 'endMin': 50}, // Period 2: 11:00-11:50
      {'start': 13, 'startMin': 0, 'end': 13, 'endMin': 50}, // Period 3: 1:00-1:50
      {'start': 13, 'startMin': 50, 'end': 14, 'endMin': 40}, // Period 4: 1:50-2:40
      {'start': 15, 'startMin': 0, 'end': 17, 'endMin': 0},  // Period 5: 3:00-5:00
    ];
    
    // Day mapping
    final dayMap = {
      'Monday': 1,
      'Tuesday': 2,
      'Wednesday': 3,
      'Thursday': 4,
      'Friday': 5,
      'Saturday': 6,
    };
    
    scheduleData.forEach((dayName, subjects) {
      final dayOfWeek = dayMap[dayName];
      if (dayOfWeek == null) return;
      
      for (int i = 0; i < subjects.length && i < periodTimes.length; i++) {
        final subject = subjects[i];
        if (subject == 'No Data' || subject.isEmpty) continue;
        
        final period = periodTimes[i];
        final startTime = DateTime(now.year, now.month, now.day, period['start']!, period['startMin']!);
        final endTime = DateTime(now.year, now.month, now.day, period['end']!, period['endMin']!);
        
        final session = ClassSession(
          id: '${dayOfWeek}_${subject}_${period['start']}${period['startMin'].toString().padLeft(2, '0')}',
          subjectName: subject,
          dayOfWeek: dayOfWeek,
          startTime: startTime,
          endTime: endTime,
        );
        
        sessions.add(session);
      }
    });
    
    return sessions;
  }
}