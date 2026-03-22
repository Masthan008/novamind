import 'dart:async'; // For runZonedGuarded
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:flutter/material.dart';
import 'dart:io'; // For Platform check
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Critical Import
import 'package:firebase_core/firebase_core.dart'; // Firebase Core
import 'package:firebase_messaging/firebase_messaging.dart'; // FCM
import 'package:provider/provider.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

// Imports from your project structure
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/community/doubt_detail_screen.dart'; // Added import
import 'animations/slide_up_route.dart';




import 'providers/theme_provider.dart';
import 'providers/accessibility_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/notification_provider.dart';
import 'models/class_session.dart';
import 'models/cheatsheet.dart';
import 'services/env_config.dart';

import 'services/timetable_service.dart';
import 'services/notification_service.dart';
import 'services/news_service.dart';
import 'services/enhanced_data_management_service.dart';
import 'services/class_notification_service.dart';
import 'services/timetable_preference_service.dart';
import 'services/fcm_service.dart'; // Firebase Cloud Messaging

// ---------------------------------------------------------
// 🔐 SECURITY NOTE: In production, use environment variables
// ---------------------------------------------------------
const String mySupabaseUrl = 'https://gnlkgstnulfenqxvrsur.supabase.co';
const String mySupabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdubGtnc3RudWxmZW5xeHZyc3VyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQyMjg4NjYsImV4cCI6MjA3OTgwNDg2Nn0.aOqkffRPxI4GPM79ravi79gm8ecOG9XXjWCnao59RG0';

// ---------------------------------------------------------
// 🎯 GLOBAL USER PLAN PROVIDER
// ---------------------------------------------------------
// Global variable to store current user's subscription plan
// Default is 'free' until we load their profile
String currentUserPlan = 'free';

// Function to fetch plan from Supabase on App Start or Login
Future<void> fetchUserPlan() async {
  try {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final data = await Supabase.instance.client
          .from('users')
          .select('subscription_tier')
          .eq('id', user.id)
          .maybeSingle();
      
      if (data != null && data['subscription_tier'] != null) {
        // Save it globally!
        currentUserPlan = data['subscription_tier'] ?? 'free';
        print("✅ User plan loaded: $currentUserPlan");
      }
    }
  } catch (e) {
    print("⚠️ Could not fetch user plan: $e");
  }
}

// Helper: Convert text plan to a number score for comparison
int getPlanScore(String plan) {
  final planLower = plan.toLowerCase();
  if (planLower == 'ultra') return 3; // Highest
  if (planLower == 'pro') return 2;   // Middle
  return 1;                           // Lowest (Free)
}

// ─── FCM BACKGROUND HANDLER ─────────────────────────────────────
// MUST be a top-level function (not inside any class).
// MUST be registered before runApp for background delivery to work.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('🔔 [FCM] Background message: ${message.notification?.title}');

  // Explicitly show local notification — some Android OEMs suppress auto-display
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
      notification.title ?? 'Zerno',
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

void main() async {
  // 1. Ensure Bindings FIRST
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Register FCM background handler — MUST be before everything else
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 2. Initialize Environment Configuration
  await EnvConfig.initialize();
  print("✅ Environment Configuration Initialized");
  
  // DEBUG: Check API keys
  if (kDebugMode) {
    print("DEBUG - Groq Key: ${EnvConfig.hasGroqKey ? 'LOADED' : 'MISSING'}");
    print("DEBUG - OpenRouter Key: ${EnvConfig.hasOpenRouterKey ? 'LOADED' : 'MISSING'}");
    print("DEBUG - Bytez Key: ${EnvConfig.hasBytezKey ? 'LOADED' : 'MISSING'}");
  }

  // 3. Fix White Bar UI Bug - Set System UI Overlay
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black, // Fixes white bar
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // 4. Initialize WebView for Android (Critical for DevRef)
  if (WebViewPlatform.instance is! AndroidWebViewController) {
    WebViewPlatform.instance = AndroidWebViewPlatform();
  }
  print("✅ WebView Platform Initialized");

  // 3. Wrap EVERYTHING in a safety block
  try {
    print("🔧 Starting Hive initialization...");
    
    // --- Hive Init ---
    await Hive.initFlutter();
    
    // Safety check for Adapters (Fixes "Adapter already registered" crash)
    try {
      if (!Hive.isAdapterRegistered(ClassSessionAdapter().typeId)) {
        Hive.registerAdapter(ClassSessionAdapter());
        print("✅ ClassSession adapter registered");
      }

      // Register CheatSheet adapter
      if (!Hive.isAdapterRegistered(10)) { // CheatSheet typeId is 10
        Hive.registerAdapter(CheatSheetAdapter());
        print("✅ CheatSheet adapter registered");
      }

    } catch (e) {
      print("⚠️ Adapter Warning: $e");
    }
    
    // Open Boxes SAFELY - Check if already open first
    // This fixes "Box is already open" crash
    print("🔧 Opening Hive boxes...");
    
    if (!Hive.isBoxOpen('calculator_history')) {
      await Hive.openBox('calculator_history');
      print("✅ Calculator history box opened");
    }
    
    if (!Hive.isBoxOpen('class_sessions')) {
      await Hive.openBox<ClassSession>('class_sessions');
      print("✅ Class sessions box opened");
    }
    
    if (!Hive.isBoxOpen('user_prefs')) {
      await Hive.openBox('user_prefs');
      print("✅ User prefs box opened");
    }
    
    if (!Hive.isBoxOpen('books_notes')) {
      await Hive.openBox('books_notes');
      print("✅ Books notes box opened");
    }
    
    if (!Hive.isBoxOpen('cheatsheets')) {
      await Hive.openBox<CheatSheet>('cheatsheets');
      print("✅ Cheatsheets box opened");
    }
    
    // --- Zerno Phase 1 Hive Boxes ---
    if (!Hive.isBoxOpen('bunk_meter_data')) {
      await Hive.openBox('bunk_meter_data');
      print("✅ Bunk Meter data box opened");
    }
    if (!Hive.isBoxOpen('cgpa_data')) {
      await Hive.openBox('cgpa_data');
      print("✅ CGPA data box opened");
    }
    if (!Hive.isBoxOpen('exam_countdown_data')) {
      await Hive.openBox('exam_countdown_data');
      print("✅ Exam Countdown data box opened");
    }
    if (!Hive.isBoxOpen('assignments_data')) {
      await Hive.openBox('assignments_data');
      print("✅ Assignments data box opened");
    }
    if (!Hive.isBoxOpen('saved_tools')) {
      await Hive.openBox('saved_tools');
      print("✅ Saved Tools box opened");
    }
    if (!Hive.isBoxOpen('saved_opportunities')) {
      await Hive.openBox('saved_opportunities');
      print("✅ Saved Opportunities box opened");
    }
    if (!Hive.isBoxOpen('promptcraft_progress')) {
      await Hive.openBox('promptcraft_progress');
      print("✅ PromptCraft Progress box opened");
    }
    
    print("✅ Hive Initialized Successfully");

    // --- Supabase Init ---
    // Safety check for Placeholder URL (Fixes "Invalid Argument" crash)
    if (mySupabaseUrl.contains('YOUR_SUPABASE_URL')) {
      print("⚠️ WARNING: Supabase Keys not set! Skipping Cloud Connection.");
    } else {
      await Supabase.initialize(
        url: mySupabaseUrl,
        anonKey: mySupabaseKey,
      );
      print("✅ Supabase Initialized Successfully");
    }

    try {
      await Firebase.initializeApp();
      print("✅ Firebase Initialized Successfully");
    } catch (e) {
      print("⚠️ Firebase Init Error: $e");
    }
    
    // --- Services Init ---

    
    await TimetableService.initializeTimetable();
    print("✅ Timetable Service Initialized");

    // --- Enhanced Data Management Service Init ---
    await EnhancedDataManagementService.initializeHiveBoxes();
    print("✅ Enhanced Data Management Service Initialized");

    // --- Timetable Preference Service Init ---
    await TimetablePreferenceService.init();
    print("✅ Timetable Preference Service Initialized");

    // --- Notification Service Init ---
    // Initialize timezone database BEFORE notification service
    try {
      tzdata.initializeTimeZones();
      // Set default location using new API (timezone package 0.9+)
      // Use tz.local which is automatically set based on device timezone
      // or we can use getLocation from the data
      final location = tz.getLocation('Asia/Kolkata');
      tz.setLocalLocation(location);
      print('✅ Timezone Database Initialized (Asia/Kolkata set)');
    } catch (e) {
      print('⚠️ Timezone Init Error: $e');
      // Fallback - just initialize without setting location
      try {
        tzdata.initializeTimeZones();
        // Use UTC as fallback if location setting fails
        tz.setLocalLocation(tz.getLocation('UTC'));
        print('⚠️ Fallback to UTC Timezone');
      } catch (e2) {
        print('❌ Critical Timezone Error: $e2');
      }
    }
    
    await NotificationService.init();
    print('✅ Notification Service Initialized');
    
    // --- Class Notification Service Init (Smart Scheduler) ---
    await ClassNotificationService.init();
    print('✅ Class Notification Service Initialized');
    
    // Request notification permissions (Android 13+)
    // Skip on Web to avoid crash
    if (!kIsWeb) {
      await ClassNotificationService.requestPermissions();
      print('✅ Notification Permissions Requested');
    }
    
    // Schedule all timetable classes automatically
    // On Web, persistent notifications might not be supported/reliable same way
    if (!kIsWeb) {
      await NotificationService.scheduleTimetable();
      print('✅ Timetable Notifications Scheduled');
    } else {
      print('ℹ️ Skipping Timetable Scheduling on Web');
    }
    
    // Start listening for news updates
    NewsService.listenForUpdates();
    print("✅ News Notification Listener Started");

    // --- FCM Push Notification Service Init ---
    try {
      await FCMService.initialize();
      print("✅ FCM Push Notification Service Initialized");
    } catch (e) {
      print("⚠️ FCM Service Init Error: $e");
    }

    // --- Fetch User Plan ---
    await fetchUserPlan();
    print("✅ User Plan Fetched");

    // --- Permissions ---
    // Using a separate try-catch because permissions can be finicky on some Android versions
    try {
      if (!kIsWeb) {
        await _requestPermissions();
        print("✅ Permissions Requested");
      }
    } catch (e) {
      print("⚠️ Permission Request Warning: $e");
    }

  } catch (e, stackTrace) {
    // 4. THE SAFETY NET
    // If anything above fails, print it, but DO NOT STOP the app.
    print("❌ CRITICAL ERROR during init: $e");
    print("Stack trace: $stackTrace");
  }

  // 5. Global Error Boundary & App Launch
  // This catches errors that would otherwise crash the app (Red Screen)
  runZonedGuarded(() {
    // Prevent Red Screen of Death in Production
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details); // Log to console
      // Don't show red screen in release mode
      if (!kDebugMode) {
        // Optional: Send to crash analytics
      }
    };
    
    // Custom Error Widget for Build Phase Errors
    ErrorWidget.builder = (FlutterErrorDetails details) {
      // Print detailed error info for debugging
      debugPrint("⛔ BUILD ERROR CAUGHT: ${details.exceptionAsString()}");
      debugPrint("⛔ ERROR CONTEXT: ${details.context?.toDescription() ?? 'No context'}");
      debugPrint("⛔ ERROR LIBRARY: ${details.library ?? 'Unknown'}");
      debugPrint("⛔ STACK TRACE:\n${details.stack}");
      
      return Material(
        color: Colors.black,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.orange, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Something went wrong',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'We avoided a crash. Please restart the app.',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Show error message in debug mode to help diagnose
                if (kDebugMode) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Text(
                      details.exceptionAsString(),
                      style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontFamily: 'monospace'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    };

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AccessibilityProvider()),
          ChangeNotifierProvider(create: (_) => DashboardProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),


        ],
        child: const ZernoApp(),
      ),
    );
  }, (error, stack) {
    // 6. Catch Async Errors (Futures, Streams) here
    debugPrint("🔴 GLOBAL ASYNC ERROR: $error");
    debugPrint("Stack: $stack");
  });
}

class ZernoApp extends StatefulWidget {
  const ZernoApp({super.key});

  @override
  State<ZernoApp> createState() => _ZernoAppState();
}

class _ZernoAppState extends State<ZernoApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();



  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Zerno',
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: themeProvider.getCurrentTheme(),
          home: const SplashScreen(),
          onGenerateRoute: (settings) {
            Widget page;
            switch (settings.name) {
              case '/onboarding':
                page = const OnboardingScreen();
                break;
              case '/auth':
                page = const AuthScreen();
                break;
              case '/home':
                page = const HomeScreen();
                break;
              case '/doubt-detail':
                final doubt = settings.arguments as Map<String, dynamic>;
                page = DoubtDetailScreen(doubt: doubt);
                break;
              default:
                page = const SplashScreen();
            }
            
            // Use slide-up animation for all routes except splash
            if (settings.name == '/') {
              return MaterialPageRoute(builder: (context) => page);
            } else {
              return SlideUpRoute(page: page);
            }
          },
        );
      },
    );
  }
}

Future<void> _requestPermissions() async {
  // Notification permission
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
  
  // Exact alarm permission (Android 12+)
  if (await Permission.scheduleExactAlarm.isDenied) {
    await Permission.scheduleExactAlarm.request();
  }
  
  // System alert window (for full-screen intent)
  if (await Permission.systemAlertWindow.isDenied) {
    await Permission.systemAlertWindow.request();
  }
  
  // CRITICAL: Battery optimization bypass for reliable alarms
  // This prevents Android from killing the app in Doze mode
  if (await Permission.ignoreBatteryOptimizations.isDenied) {
    await Permission.ignoreBatteryOptimizations.request();
  }
}
