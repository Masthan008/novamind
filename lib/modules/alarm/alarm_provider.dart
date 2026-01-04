import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:alarm/alarm.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'alarm_service.dart';
import '../../main.dart'; // For navigatorKey

class AlarmProvider extends ChangeNotifier {
  List<AlarmSettings> _alarms = [];
  List<AlarmSettings> get alarms => _alarms;
  
  // Alarm history
  List<Map<String, dynamic>> _alarmHistory = [];
  List<Map<String, dynamic>> get alarmHistory => _alarmHistory;

  AlarmProvider() {
    _loadAlarms();
    _loadHistory();
    loadSounds();
    
    // CRITICAL: Periodically check and reschedule alarms every hour
    // This ensures repeating alarms are always up-to-date
    Timer.periodic(const Duration(hours: 1), (_) {
      _loadAlarms();
      debugPrint('🔄 Periodic alarm check completed');
    });
  }
  
  Future<void> _loadHistory() async {
    try {
      final box = await Hive.openBox('alarm_history');
      final history = box.get('history', defaultValue: <dynamic>[]);
      _alarmHistory = List<Map<String, dynamic>>.from(
        history.map((item) => Map<String, dynamic>.from(item))
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading alarm history: $e');
    }
  }
  
  Future<void> _saveHistory() async {
    try {
      final box = await Hive.openBox('alarm_history');
      await box.put('history', _alarmHistory);
    } catch (e) {
      debugPrint('Error saving alarm history: $e');
    }
  }
  
  Future<void> addToHistory(String title, String time, String action) async {
    _alarmHistory.insert(0, {
      'title': title,
      'time': time,
      'action': action,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    // Keep only last 50 entries
    if (_alarmHistory.length > 50) {
      _alarmHistory = _alarmHistory.sublist(0, 50);
    }
    
    await _saveHistory();
    notifyListeners();
  }
  
  Future<void> clearHistory() async {
    _alarmHistory.clear();
    await _saveHistory();
    notifyListeners();
  }

  Future<void> _loadAlarms() async {
    // Load all alarms from the alarm package
    final allAlarms = await Alarm.getAlarms();
    
    // Filter out expired alarms and reschedule repeating ones
    final now = DateTime.now();
    final validAlarms = <AlarmSettings>[];
    
    for (final alarm in allAlarms) {
      // Check if alarm time has passed
      final alarmPassed = alarm.dateTime.isBefore(now);
      
      if (alarm.loopAudio && alarmPassed) {
        // CRITICAL FIX: Reschedule repeating alarm to next occurrence
        try {
          // Stop the old alarm
          await Alarm.stop(alarm.id);
          
          // Calculate next occurrence (tomorrow at the same time)
          final nextAlarmTime = DateTime(
            now.year,
            now.month,
            now.day,
            alarm.dateTime.hour,
            alarm.dateTime.minute,
          ).add(const Duration(days: 1));
          
          // Reschedule with the same settings but new time
          final newSettings = AlarmSettings(
            id: alarm.id,
            dateTime: nextAlarmTime,
            assetAudioPath: alarm.assetAudioPath,
            loopAudio: alarm.loopAudio,
            vibrate: alarm.vibrate,
            androidFullScreenIntent: alarm.androidFullScreenIntent,
            volumeSettings: alarm.volumeSettings,
            notificationSettings: alarm.notificationSettings,
          );
          
          await Alarm.set(alarmSettings: newSettings);
          validAlarms.add(newSettings);
          
          debugPrint('✅ Rescheduled repeating alarm ${alarm.id} to $nextAlarmTime');
        } catch (e) {
          debugPrint('❌ Error rescheduling alarm ${alarm.id}: $e');
        }
      } else if (!alarmPassed) {
        // Alarm is in the future, keep it
        validAlarms.add(alarm);
      } else {
        // Expired one-time alarm, remove it
        try {
          await Alarm.stop(alarm.id);
          debugPrint('🗑️ Cleaned up expired one-time alarm: ${alarm.id}');
        } catch (e) {
          debugPrint('Error stopping alarm ${alarm.id}: $e');
        }
      }
    }
    
    _alarms = validAlarms;
    notifyListeners();
  }

  Future<void> scheduleAlarm(DateTime dateTime, String audioPath, {bool loopAudio = true}) async {
    final id = DateTime.now().millisecondsSinceEpoch % 10000;
    await AlarmService.scheduleAlarm(
      id: id,
      dateTime: dateTime,
      assetAudioPath: audioPath,
      loopAudio: loopAudio,
      notificationTitle: 'FluxFlow Alarm',
      notificationBody: 'Time to wake up!',
    );
    await _loadAlarms();
  }

  // v5.0: Schedule alarm with note support
  Future<void> scheduleAlarmWithNote(
    DateTime dateTime, 
    String audioPath, 
    String? reminderNote,
    {bool loopAudio = true, int? alarmId}
  ) async {
    final id = alarmId ?? (DateTime.now().millisecondsSinceEpoch % 10000);
    await AlarmService.scheduleAlarm(
      id: id,
      dateTime: dateTime,
      assetAudioPath: audioPath,
      loopAudio: loopAudio,
      notificationTitle: 'FluxFlow Alarm',
      notificationBody: 'Time to wake up!',
      reminderNote: reminderNote,
    );
    await _loadAlarms();
  }

  Future<void> stopAlarm(int id) async {
    try {
      // Find alarm before stopping to log it
      final alarm = _alarms.firstWhere((a) => a.id == id, orElse: () => _alarms.first);
      final timeStr = '${alarm.dateTime.hour}:${alarm.dateTime.minute.toString().padLeft(2, '0')}';
      
      await AlarmService.stopAlarm(id);
      
      // Add to history
      await addToHistory('Alarm Deleted', timeStr, 'Deleted');
      
      // Force remove from local list immediately
      _alarms.removeWhere((alarm) => alarm.id == id);
      notifyListeners();
      // Then reload to ensure sync
      await _loadAlarms();
    } catch (e) {
      debugPrint('Error stopping alarm $id: $e');
      // Still try to reload
      await _loadAlarms();
    }
  }
  
  Future<void> snoozeAlarm(AlarmSettings settings, int minutes) async {
    try {
      final timeStr = '${settings.dateTime.hour}:${settings.dateTime.minute.toString().padLeft(2, '0')}';
      
      await AlarmService.snoozeAlarm(settings, duration: Duration(minutes: minutes));
      
      // Add to history
      await addToHistory('Alarm Snoozed', timeStr, 'Snoozed for $minutes min');
      
      await _loadAlarms();
    } catch (e) {
      debugPrint('Error snoozing alarm: $e');
    }
  }

  List<String> _availableSounds = [
    'assets/sounds/alarm_1.mp3',
    'assets/sounds/alarm_2.mp3',
    'assets/sounds/alarm_3.mp3',
    'assets/sounds/alarm_4.mp3',
    'assets/sounds/alarm_5.mp3',
    'assets/sounds/alarm_6.mp3',
    'assets/sounds/alarm_7.mp3',
    'assets/sounds/alarm_8.mp3',
    'assets/sounds/alarm_9.mp3',
    'assets/sounds/alarm_10.mp3',
    'assets/sounds/alarm_11.mp3',
    'assets/sounds/alarm_12.mp3',
    'assets/sounds/alarm_13.mp3',
    'assets/sounds/alarm_14.mp3',
    'assets/sounds/alarm_15.mp3',
    'assets/sounds/alarm_16.mp3',
    'assets/sounds/alarm_17.mp3',
    'assets/sounds/alarm_18.mp3',
    'assets/sounds/alarm_19.mp3',
    'assets/sounds/alarm_20.mp3',
  ];

  List<String> get availableSounds => _availableSounds;

  Future<void> loadSounds() async {
    try {
      // Use rootBundle to avoid context requirement
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      
      _availableSounds = manifestMap.keys
          .where((key) => key.startsWith('assets/sounds/') && key.endsWith('.mp3'))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading sounds: $e");
    }
  }
}
