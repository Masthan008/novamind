import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import '../models/class_session.dart';
import 'student_auth_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  // Callback to notify listeners of badge count changes
  static Function(int)? _onUnreadCountChanged;
  static RealtimeChannel? _notificationsChannel;

  static Future<void> init() async {
    // Using the transparent notification icon for status bar
    const androidSettings = AndroidInitializationSettings('notification_icon');
    const settings = InitializationSettings(android: androidSettings);
    
    await _notifications.initialize(settings);

    // Request permission for Android 13+
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    
    // Setup notification channels
    await setupNotificationChannels();

    // Start listening for Campus Buzz notifications
    listenForBuzzNotifications();
    
    // Note: FCM push notifications require Firebase setup:
    // 1. Add firebase_core and firebase_messaging to pubspec.yaml
    // 2. Run flutterfire configure to generate google-services.json
    // 3. Uncomment _setupFCM() below after configuration
  }
  
  /// Setup Android notification channels for better user control
  static Future<void> setupNotificationChannels() async {
    final androidPlatform = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlatform == null) return;

    // Channel 1: Class Alerts (High frequency, user can disable)
    const classChannel = AndroidNotificationChannel(
      'class_alerts',
      'Class Reminders',
      description: 'Notifications for daily timetable classes',
      importance: Importance.max, // Max for custom sound
      playSound: true,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('alarm_1'), // Custom sound from res/raw
    );

    // Channel 2: News & Updates (Low frequency, critical)
    const newsChannel = AndroidNotificationChannel(
      'news_channel',
      'College News',
      description: 'Important updates about exams, events, and holidays',
      importance: Importance.max, // Maximum importance for critical updates
      playSound: true,
      enableVibration: true,
    );

    // Create channels in Android system
    await androidPlatform.createNotificationChannel(classChannel);
    await androidPlatform.createNotificationChannel(newsChannel);
    
    print('✅ Notification channels created');
  }

  /// Start listening for Campus Buzz notifications
  static void listenForBuzzNotifications() {
    try {
      final studentId = StudentAuthService.currentStudent?.id;
      if (studentId == null) {
        print('⏳ Waiting for login to listen for buzz notifications...');
        return;
      }

      // Unsubscribe existing if any (to avoid duplicates on re-login)
      _notificationsChannel?.unsubscribe();

      print('👂 Listening for buzz notifications for $studentId');
      _notificationsChannel = Supabase.instance.client
          .channel('public:student_notifications:$studentId')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'student_notifications',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'recipient_id',
              value: studentId,
            ),
            callback: (payload) async {
              // New notification!
              final message = payload.newRecord['message'] as String? ?? 'New notification';
              final senderName = payload.newRecord['sender_name'] as String? ?? 'Someone';
              
              print("🔔 New Buzz Notification received!");

              // Show system notification
              await _showNotification(
                'Zerno Buzz', 
                '$senderName $message'
              );
              
              // Update badge count
              final unreadCount = await getUnreadCount();
              _onUnreadCountChanged?.call(unreadCount);
            },
          )
          .subscribe();
    } catch (e) {
      print('⚠️ Error listening for buzz notifications: $e');
    }
  }
  
  /// Get the last notified news ID from Hive
  static String _getLastNotifiedId() {
    final box = Hive.box('user_prefs');
    return box.get('last_notified_news_id', defaultValue: '');
  }
  
  /// Save the last notified news ID
  static Future<void> _setLastNotifiedId(String id) async {
    final box = Hive.box('user_prefs');
    await box.put('last_notified_news_id', id);
  }
  
  /// Get the last time user opened news screen
  static DateTime _getLastNewsOpenTime() {
    final box = Hive.box('user_prefs');
    final timeStr = box.get('last_news_open_time', defaultValue: '2000-01-01T00:00:00.000Z');
    return DateTime.parse(timeStr);
  }
  
  /// Save current time as last news open time
  static Future<void> markNewsAsRead() async {
    final box = Hive.box('user_prefs');
    await box.put('last_news_open_time', DateTime.now().toIso8601String());
    
    // Update count (will still show buzz notifications if any)
    final count = await getUnreadCount();
    _onUnreadCountChanged?.call(count);
  }
  
  /// Get TOTAL unread count (News + Campus Buzz)
  static Future<int> getUnreadCount() async {
    try {
      // 1. Unread News Count
      final lastSeenTime = _getLastNewsOpenTime();
      final newsResponse = await Supabase.instance.client
          .from('news')
          .select('id')
          .gt('created_at', lastSeenTime.toIso8601String());
      final newsCount = (newsResponse as List).length;
      
      // 2. Unread Campus Buzz Count
      int buzzCount = 0;
      final studentId = StudentAuthService.currentStudent?.id;
      
      if (studentId != null) {
         final buzzResponse = await Supabase.instance.client
          .from('student_notifications')
          .select('id')
          .eq('recipient_id', studentId)
          .eq('is_read', false);
         buzzCount = (buzzResponse as List).length;
      }
      
      // print('🔔 Unread Count: News=$newsCount, Buzz=$buzzCount');
      return newsCount + buzzCount;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }
  
  /// Set listener for unread count changes
  static void setOnUnreadCountChanged(Function(int)? callback) {
    _onUnreadCountChanged = callback;
    // Immediately calculate and send current count
    getUnreadCount().then((count) => callback?.call(count));
  }
  
  /// Clear unread count for NEWS only (called when user opens News screen)
  static Future<void> clearUnreadCount() async {
    // We only clear "News" count by updating the last open time.
    // Buzz notifications are cleared individually when read or "mark all read" in that tab.
    await markNewsAsRead();
  }

  /// Check for new news and show notification if new
  /// Uses ID-based logic: only notify if news ID != last notified ID
  static Future<void> checkAndNotify() async {
    try {
      // 1. Get the latest news from Supabase
      final response = await Supabase.instance.client
          .from('news')
          .select()
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      
      if (response == null) return;
      
      final latestNewsId = response['id']?.toString() ?? '';
      final title = response['title'] ?? 'New Update';
      final description = response['description'] ?? 'Check the app for details';
      
      // 2. Get the ID we last notified about
      final lastNotifiedId = _getLastNotifiedId();
      
      // 3. THE MAGIC CHECK - Only notify if different ID
      if (latestNewsId.isNotEmpty && latestNewsId != lastNotifiedId) {
        // This is NEW news!
        await _showNotification(title, description);
        
        // Save this ID so we don't notify again
        await _setLastNotifiedId(latestNewsId);
        
        // Update badge count
        final unreadCount = await getUnreadCount();
        _onUnreadCountChanged?.call(unreadCount);
      }
    } catch (e) {
      print('Error checking for notifications: $e');
    }
  }
  
  /// Show notification for new news (called by checkAndNotify)
  static Future<void> _showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'news_channel',
      'News Updates',
      channelDescription: 'Notifications for new news updates',
      importance: Importance.max,
      priority: Priority.high,
      color: Color(0xFF00FFFF), // Cyan color
      playSound: true,
      enableVibration: true,
    );
    
    const details = NotificationDetails(android: androidDetails);
    
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unique ID
      "📢 $title",
      body,
      details,
    );
  }

  /// Legacy method - now calls checkAndNotify internally
  static Future<void> showNewsAlert(String id, String title, String body) async {
    final lastNotifiedId = _getLastNotifiedId();
    
    // Only notify if different ID
    if (id.isNotEmpty && id != lastNotifiedId) {
      await _showNotification(title, body);
      await _setLastNotifiedId(id);
      
      // Update badge count
      final unreadCount = await getUnreadCount();
      _onUnreadCountChanged?.call(unreadCount);
    }
  }
  
  /// Reset all notification tracking (for debugging)
  static Future<void> resetNotificationTracking() async {
    final box = Hive.box('user_prefs');
    await box.delete('last_notified_news_id');
    await box.delete('last_news_open_time');
    _onUnreadCountChanged?.call(0);
  }

  // ==================== CLASS NOTIFICATION SYSTEM ====================
  
  /// Calculate next occurrence of specific day/time
  static tz.TZDateTime _nextInstanceOfDayAndTime(int dayOfWeek, int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    
    // Create date for today with target time
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local, 
      now.year, 
      now.month, 
      now.day, 
      hour, 
      minute
    );

    // Adjust to correct day of week (Monday=1, Sunday=7)
    while (scheduledDate.weekday != dayOfWeek) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // If time passed this week, schedule for next week
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    return scheduledDate;
  }

  /// Schedule class alerts (10-min and 5-min warnings)
  static Future<void> scheduleClassAlerts({
    required int id,           // Unique class ID from database
    required String className, 
    required int dayOfWeek,    // 1=Mon, 2=Tue, ..., 7=Sun
    required int classHour,    // 24-hour format (e.g., 10 for 10 AM)
    required int classMinute,  
  }) async {
    
    // 🛑 CHECK: Are class reminders enabled?
    final prefs = await SharedPreferences.getInstance();
    final bool isEnabled = prefs.getBool('class_reminders_enabled') ?? true;

    if (!isEnabled) {
      print('⏭️ Skipping $className: Reminders disabled by user');
      return; // Exit early
    }

    // --- ALERT 1: 10 Minutes Before ---
    final tenMinBefore = _nextInstanceOfDayAndTime(dayOfWeek, classHour, classMinute)
        .subtract(const Duration(minutes: 10));

    await _notifications.zonedSchedule(
      id * 10, // Unique ID (e.g., Class 5 → Notification 50)
      '🔔 Class Starting Soon!',
      '$className starts in 10 minutes',
      tenMinBefore,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'class_alerts',
          'Class Alerts',
          channelDescription: 'Reminders for upcoming classes',
          importance: Importance.max,
          priority: Priority.high,
          color: Color(0xFF00FFFF),
          playSound: true,
          sound: RawResourceAndroidNotificationSound('alarm_1'), // Custom sound
          enableVibration: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // 🔴 Moved here
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime, // 🔄 Repeats weekly
    );

    // --- ALERT 2: 5 Minutes Before ---
    final fiveMinBefore = _nextInstanceOfDayAndTime(dayOfWeek, classHour, classMinute)
        .subtract(const Duration(minutes: 5));

    await _notifications.zonedSchedule(
      id * 10 + 1, // Unique ID (e.g., Class 5 → Notification 51)
      '⚡ Hurry Up!',
      '$className starts in 5 minutes',
      fiveMinBefore,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'class_alerts', 
          'Class Alerts',
          channelDescription: 'Reminders for upcoming classes',
          importance: Importance.max,
          priority: Priority.high,
          color: Color(0xFF00FFFF),
          playSound: true,
          sound: RawResourceAndroidNotificationSound('alarm_1'), // Custom sound
          enableVibration: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // 🔴 Moved here
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime, // 🔄 Repeats weekly
    );
    
    print('✅ Scheduled alerts for $className (Day $dayOfWeek at $classHour:$classMinute)');
  }

  // 🗓️ Calendar Reminder Support
  static Future<void> scheduleCalendarReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);
    if (tzTime.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'calendar_channel', 
          'Calendar Reminders',
          channelDescription: 'Notifications for personal events',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('alarm_1'),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
    print("📅 Calendar Reminder Set: $title");
  }

  /// Cancel a specific notification by ID
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel specific class alerts
  static Future<void> cancelClassAlerts(int classId) async {
    await _notifications.cancel(classId * 10);     // 10-min alert
    await _notifications.cancel(classId * 10 + 1); // 5-min alert
    print('🔕 Cancelled alerts for class ID $classId');
  }

  /// Cancel ALL class alerts
  static Future<void> cancelAllClassAlerts() async {
    // Note: This cancels ALL notifications. If you have other types,
    // you should track class notification IDs and cancel them specifically
    await _notifications.cancelAll();
    print('🔕 Cancelled all class alerts');
  }

  // ==================== TIMETABLE INTEGRATION ====================
  
  /// Schedule all classes from timetable automatically
  static Future<void> scheduleTimetable() async {
    try {
      // Check if Exam Mode is ON
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('exam_mode_enabled') == true) {
        print('📚 Exam Mode is active. Skipping scheduling.');
        return;
      }

      // Check if class reminders are enabled
      final bool isEnabled = prefs.getBool('class_reminders_enabled') ?? true;
      if (!isEnabled) {
        print('⏭️ Class reminders disabled. Skipping scheduling.');
        return;
      }

      // Get all classes from Hive
      final box = Hive.isBoxOpen('class_sessions')
          ? Hive.box<ClassSession>('class_sessions')
          : await Hive.openBox<ClassSession>('class_sessions');
      
      final allClasses = box.values.toList();
      
      if (allClasses.isEmpty) {
        print('⚠️ No classes found in timetable');
        return;
      }

      // Clear old alarms to avoid duplicates
      await cancelAllClassAlerts();

      // Schedule each class
      int scheduled = 0;
      for (var session in allClasses) {
        try {
          await scheduleClassAlerts(
            id: session.id.hashCode.abs(), // Use hash of ID for unique int
            className: session.subjectName,
            dayOfWeek: session.dayOfWeek,
            classHour: session.startTime.hour,
            classMinute: session.startTime.minute,
          );
          scheduled++;
        } catch (e) {
          print('❌ Error scheduling ${session.subjectName}: $e');
        }
      }
      
      print('✅ Scheduled $scheduled classes from timetable');
    } catch (e) {
      print('❌ Error in scheduleTimetable: $e');
    }
  }
}
