import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../data/timetable_data.dart';

class ClassNotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  // 🚀 1. Initialize
  static Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata')); // Set to Indian timezone
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    
    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        print('Notification tapped: ${response.payload}');
      },
    );
  }

  // 🚀 2. The "Brain": Schedule Alerts for a Specific User
  static Future<void> scheduleDailyClasses(String branch, String section) async {
    try {
      // A. Cancel old alerts (so we don't double notify)
      await _notifications.cancelAll();
      print('Scheduling notifications for $branch - Section $section');

      // B. Get the Schedule for THIS student
      Map<String, List<String>> weekSchedule = TimetableData.getSchedule(branch, section);
      
      // C. Define Period Times (Based on official RGMCET timetable)
      // Period 1: 9:00-10:40, Period 2: 11:00-11:50, Period 3: 1:00-1:50, Period 4: 1:50-2:40, Period 5: 3:00-5:00
      final List<int> startHours =   [9,  11, 13, 13, 15];
      final List<int> startMinutes = [0,  0,  0,  50, 0];

      // D. Loop through Days (Mon-Sat)
      List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
      
      int notificationCount = 0;
      
      for (int i = 0; i < days.length; i++) {
        String dayName = days[i];
        List<String> subjects = weekSchedule[dayName] ?? [];

        // Loop through classes for that day
        for (int slot = 0; slot < subjects.length && slot < startHours.length; slot++) {
          String subject = subjects[slot];
          
          // Skip if no class or invalid data
          if (subject.isEmpty || 
              subject == "No Data" || 
              subject == "Contact Admin" || 
              subject == "Free") {
            continue;
          }

          // E. Schedule for 10 Minutes Before
          await _scheduleNotification(
            id: (i * 10) + slot, // Unique ID for every class
            title: "Upcoming Class: $subject",
            body: "Starts in 10 minutes! (${_formatTime(startHours[slot], startMinutes[slot])})",
            dayIndex: i + 1, // Mon=1, Tue=2...
            hour: startHours[slot],
            minute: startMinutes[slot],
            subject: subject,
          );
          
          notificationCount++;
        }
      }
      
      print('Successfully scheduled $notificationCount class notifications');
    } catch (e, stackTrace) {
      print('Error scheduling notifications: $e');
      print('Stack trace: $stackTrace');
    }
  }

  // 🚀 3. The Low-Level Scheduler
  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required int dayIndex, // 1 = Monday, 7 = Sunday
    required int hour,
    required int minute,
    required String subject,
  }) async {
    try {
      // Calculate "Next Instance" of this class time
      tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      
      // Create the Class Time
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, 
        now.year, 
        now.month, 
        now.day, 
        hour, 
        minute,
      );

      // Subtract 10 Minutes for alert
      scheduledDate = scheduledDate.subtract(const Duration(minutes: 10));

      // Logic to find the correct "Next Day" (e.g. if today is Tue, schedule for next Mon)
      while (scheduledDate.weekday != dayIndex || scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Get full subject name
      final fullName = TimetableData.subjectNames[subject] ?? subject;

      // Schedule It
      await _notifications.zonedSchedule(
        id,
        title,
        '$fullName\n$body',
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'class_channel',
            'Class Alerts',
            channelDescription: 'Notifications for upcoming classes',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: const Color(0xFF00BCD4), // Cyan accent
            playSound: true,
            enableVibration: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime, // 🔄 Repeats Weekly
      );
      
      print('Scheduled notification $id for $subject on ${_getDayName(dayIndex)} at ${_formatTime(hour, minute)}');
    } catch (e) {
      print('Error scheduling notification $id: $e');
    }
  }

  // Helper: Format time
  static String _formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  // Helper: Get day name
  static String _getDayName(int dayIndex) {
    const days = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[dayIndex];
  }

  // 🚀 4. Request notification permissions (Android 13+)
  static Future<bool> requestPermissions() async {
    final androidImplementation = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      final granted = await androidImplementation.requestNotificationsPermission();
      return granted ?? false;
    }
    
    return true;
  }

  // 🚀 5. Cancel all notifications
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
    print('All notifications cancelled');
  }

  // 🚀 6. Get pending notifications (for debugging)
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
