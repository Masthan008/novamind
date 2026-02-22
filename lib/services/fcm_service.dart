import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'student_auth_service.dart';

/// Top-level background handler – MUST be a top-level function (not a method).
/// Firebase requires this to be outside any class.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('🔔 [FCM] Background message: ${message.messageId}');

  // Some Android OEMs suppress auto-display of FCM notifications.
  // Explicitly show a local notification to guarantee delivery.
  final notification = message.notification;
  if (notification != null) {
    final plugin = FlutterLocalNotificationsPlugin();

    const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
    await plugin.initialize(const InitializationSettings(android: androidInit));

    final type = message.data['type'] ?? 'general';
    String channelId;
    switch (type) {
      case 'news':
        channelId = 'fcm_news_channel';
        break;
      case 'buzz_question':
      case 'buzz_reply':
        channelId = 'fcm_buzz_channel';
        break;
      case 'chat_message':
      case 'chat_mention':
        channelId = 'fcm_chat_channel';
        break;
      default:
        channelId = 'fcm_news_channel';
    }

    await plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      notification.title ?? 'Sentinel',
      notification.body ?? '',
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      ),
    );
  }
}

/// Firebase Cloud Messaging Service
/// Handles push notifications for News, Campus Buzz, and ChatHub.
class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Notification channels
  static const _newsChannel = AndroidNotificationChannel(
    'fcm_news_channel',
    'News Notifications',
    description: 'Push notifications for college news & announcements',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  static const _buzzChannel = AndroidNotificationChannel(
    'fcm_buzz_channel',
    'Campus Buzz',
    description: 'Notifications for questions & replies in Campus Buzz',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  static const _chatChannel = AndroidNotificationChannel(
    'fcm_chat_channel',
    'ChatHub Messages',
    description: 'Notifications for chat messages & mentions',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  // ─── INITIALIZATION ──────────────────────────────────────────────

  /// Call this once from main.dart AFTER Firebase.initializeApp()
  static Future<void> initialize() async {
    try {
      // 1. Register background handler
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // 2. Request permission (Android 13+ / iOS)
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint(
          '🔔 [FCM] Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('⚠️ [FCM] Notifications permission denied by user');
        return;
      }

      // 3. Initialize local notifications plugin
      const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
      await _localNotifications.initialize(
        const InitializationSettings(android: androidInit),
        onDidReceiveNotificationResponse: (details) {
          debugPrint('🔔 [FCM] Notification tapped: ${details.payload}');
        },
      );

      // 4. Create Android notification channels
      await _createChannels();

      // 4. Get FCM token and save it
      final token = await _messaging.getToken();
      if (token != null) {
        debugPrint('🔔 [FCM] FULL TOKEN ▼▼▼');
        debugPrint(token);
        debugPrint('🔔 [FCM] FULL TOKEN ▲▲▲');
        await _saveTokenToSupabase(token);
      }

      // 5. Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        debugPrint('🔄 [FCM] Token refreshed');
        _saveTokenToSupabase(newToken);
      });

      // 6. Subscribe to broadcast topics
      await subscribeToTopics();

      // 7. Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // 8. Handle notification tap (app was in background)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // 9. Check if app was opened by tapping a notification (terminated state)
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      debugPrint('✅ [FCM] Service initialized successfully');
    } catch (e) {
      debugPrint('❌ [FCM] Initialization error: $e');
    }
  }

  // ─── CHANNELS ────────────────────────────────────────────────────

  static Future<void> _createChannels() async {
    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(_newsChannel);
      await androidPlugin.createNotificationChannel(_buzzChannel);
      await androidPlugin.createNotificationChannel(_chatChannel);
      debugPrint('✅ [FCM] Notification channels created');
    }
  }

  // ─── TOKEN MANAGEMENT ────────────────────────────────────────────

  /// Save FCM token to Supabase so the backend Edge Function can
  /// look up tokens by student ID and send targeted notifications.
  static Future<void> _saveTokenToSupabase(String token) async {
    try {
      final studentId = StudentAuthService.currentStudent?.id;
      final studentName = StudentAuthService.currentStudent?.name ?? 'Student';

      if (studentId == null) {
        debugPrint('⏳ [FCM] No student logged in, token saved locally only');
        // Save token locally so we can push it after login
        final box = Hive.box('user_prefs');
        await box.put('pending_fcm_token', token);
        return;
      }

      await Supabase.instance.client.from('user_fcm_tokens').upsert(
        {
          'student_id': studentId,
          'student_name': studentName,
          'fcm_token': token,
          'device_type': defaultTargetPlatform == TargetPlatform.iOS
              ? 'ios'
              : 'android',
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'student_id',
      );

      // Clear any pending token
      final box = Hive.box('user_prefs');
      await box.delete('pending_fcm_token');

      debugPrint('✅ [FCM] Token saved for student $studentName ($studentId)');
    } catch (e) {
      debugPrint('⚠️ [FCM] Error saving token: $e');
    }
  }

  /// Call this after the user logs in, so we push any pending token
  /// and re-subscribe to topics.
  static Future<void> onUserLogin() async {
    try {
      // Push pending token if any
      final box = Hive.box('user_prefs');
      final pendingToken = box.get('pending_fcm_token');
      if (pendingToken != null) {
        await _saveTokenToSupabase(pendingToken);
      } else {
        // Or get a fresh token
        final token = await _messaging.getToken();
        if (token != null) {
          await _saveTokenToSupabase(token);
        }
      }

      // Re-subscribe to topics
      await subscribeToTopics();

      debugPrint('✅ [FCM] Post-login setup complete');
    } catch (e) {
      debugPrint('⚠️ [FCM] Post-login error: $e');
    }
  }

  /// Call this on logout to unsubscribe and remove token
  static Future<void> onUserLogout() async {
    try {
      await _messaging.unsubscribeFromTopic('news');
      await _messaging.unsubscribeFromTopic('campus_buzz');
      await _messaging.unsubscribeFromTopic('chat_global');

      // Optionally remove token from Supabase
      final studentId = StudentAuthService.currentStudent?.id;
      if (studentId != null) {
        await Supabase.instance.client
            .from('user_fcm_tokens')
            .delete()
            .eq('student_id', studentId);
      }

      debugPrint('✅ [FCM] Logout cleanup done');
    } catch (e) {
      debugPrint('⚠️ [FCM] Logout cleanup error: $e');
    }
  }

  // ─── TOPIC SUBSCRIPTIONS ─────────────────────────────────────────

  static Future<void> subscribeToTopics() async {
    try {
      await _messaging.subscribeToTopic('news');
      await _messaging.subscribeToTopic('campus_buzz');
      await _messaging.subscribeToTopic('chat_global');
      debugPrint('✅ [FCM] Subscribed to topics: news, campus_buzz, chat_global');
    } catch (e) {
      debugPrint('⚠️ [FCM] Topic subscription error: $e');
    }
  }

  // ─── MESSAGE HANDLERS ────────────────────────────────────────────

  /// Handle messages received while the app is in the foreground.
  /// We show a local notification so the user sees it as a banner.
  static void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('🔔 [FCM] Foreground message: ${message.data}');

    final notification = message.notification;
    if (notification == null) return;

    // Determine the notification type from data payload
    final type = message.data['type'] ?? 'general';

    // Skip notifications already handled by Supabase Realtime when app is open.
    // Realtime shows in-app banners for news and buzz — no need for FCM push too.
    if (type == 'news' || type == 'buzz_question' || type == 'buzz_reply') {
      debugPrint('⏭️ [FCM] Skipping "$type" in foreground — Supabase Realtime handles it');
      return;
    }

    // Determine which channel to use
    String channelId;
    switch (type) {
      case 'chat_message':
      case 'chat_mention':
        channelId = _chatChannel.id;
        break;
      default:
        channelId = _newsChannel.id;
    }

    // Don't show chat notifications if the sender is the current user
    if (type == 'chat_message' || type == 'chat_mention') {
      final senderName = message.data['sender_name'] ?? '';
      final currentName = StudentAuthService.currentStudent?.name ?? '';
      if (senderName == currentName) return; // Skip own messages
    }

    _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      notification.title ?? 'Sentinel',
      notification.body ?? '',
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId,
          importance: Importance.high,
          priority: Priority.high,
          color: const Color(0xFF00FFFF),
          playSound: true,
          enableVibration: true,
        ),
      ),
      payload: _buildPayload(message.data),
    );
  }

  /// Handle user tapping a notification (app was in background/terminated).
  static void _handleNotificationTap(RemoteMessage message) {
    debugPrint('👆 [FCM] Notification tapped: ${message.data}');

    final type = message.data['type'] ?? '';
    final targetId = message.data['target_id'] ?? '';

    // Navigation will be handled by the app's navigator
    // Store the pending navigation so the app can pick it up
    final box = Hive.box('user_prefs');
    box.put('pending_notification_type', type);
    box.put('pending_notification_target', targetId);
  }

  /// Build a payload string from the data map for local notification tap handler
  static String _buildPayload(Map<String, dynamic> data) {
    final type = data['type'] ?? '';
    final targetId = data['target_id'] ?? '';
    return '$type|$targetId';
  }

  // ─── NAVIGATION HELPER ───────────────────────────────────────────

  /// Check if there's a pending notification to navigate to.
  /// Call this from your home screen's initState.
  static Map<String, String>? checkPendingNotification() {
    try {
      final box = Hive.box('user_prefs');
      final type = box.get('pending_notification_type');
      final target = box.get('pending_notification_target');

      if (type != null && type.toString().isNotEmpty) {
        // Clear it so we don't navigate again
        box.delete('pending_notification_type');
        box.delete('pending_notification_target');

        return {
          'type': type.toString(),
          'target_id': target?.toString() ?? '',
        };
      }
    } catch (e) {
      debugPrint('⚠️ [FCM] Error checking pending notification: $e');
    }
    return null;
  }
}
