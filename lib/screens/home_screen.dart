import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
import '../providers/accessibility_provider.dart';
import '../widgets/aquamorphic_nav_bar.dart';
import '../widgets/accessibility_wrapper.dart';
import '../modules/data_structures/data_structures_screen.dart';
import 'quiz/quiz_topics_screen.dart';

import 'launchpad/launchpad_screen.dart';
import 'promptcraft/promptcraft_home_screen.dart';
import '../modules/cyber/cyber_vault_screen.dart';

import '../modules/news/news_screen.dart';
import '../modules/academic/syllabus_screen.dart';
import '../modules/academic/books_notes_screen.dart';
import '../modules/roadmaps/roadmaps_screen.dart';
import '../modules/ai/nova_chat_screen.dart';
import '../screens/engineering/engineering_hub.dart';
import '../screens/flowcharts_screen.dart';
import '../screens/devref/devref_hub_screen.dart';

import '../modules/study_companion/study_companion_screen.dart';

import '../modules/cybersecurity/cybersecurity_hub_screen.dart';
import 'timetable_screen.dart';

import 'library_screen.dart';
import 'video_library_screen.dart';

import 'leaderboard_screen.dart';
import 'subscription_screen.dart';
import 'shop/projects_screen.dart';
import 'student_profile_screen.dart';
import 'login_screen.dart';


import 'about_screen.dart';
import 'settings/main_settings_screen.dart';
import 'chat_screen.dart';
import '../features/code_lens/code_lens_screen.dart';
import '../features/lab_mesh/lab_mesh_screen.dart';
import 'community/community_screen.dart';
import 'personal/daily_routine_screen.dart';
import 'personal/diary_screen.dart';
import '../widgets/flux_drawer.dart';

import '../services/auth_service.dart';
import '../services/student_auth_service.dart';
import '../services/notification_service.dart';
import '../widgets/user_badge.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _drawerAnimationController;
  late AnimationController _appBarAnimationController;
  late AnimationController _backgroundController;
  
  final List<Widget> _screens = [
    const TimetableScreen(),  // Index 0 - Timetable
    const ChatScreen(),       // Index 1 - Chat
    const DailyRoutineScreen(), // Index 2 - Routine
    const DiaryScreen(), // Index 3 - Diary
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _drawerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _appBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    
    // Start animations
    _appBarAnimationController.forward();
    _backgroundController.repeat();
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkFirstRun();
      if (mounted && StudentAuthService.isLoggedIn) {
        await syncUserProfile();
      }
    });
  }

  Future<void> syncUserProfile() async {
    try {
      // Use the centralized Auth Service to refresh data from 'students' table
      final updatedStudent = await StudentAuthService.refreshCurrentStudent();
      
      if (updatedStudent != null && mounted) {
        // Also update Hive for fallback (though UI uses StudentAuthService mostly)
        try {
          var box = Hive.box('user_prefs');
          await box.put('user_name', updatedStudent.name);
          if (updatedStudent.imageUrl != null) {
             await box.put('user_photo', updatedStudent.imageUrl);
          }
        } catch (e) {
          print("⚠️ Hive update error: $e");
        }

        if (mounted) {
          setState(() {}); // Force UI rebuild with new data
          
          // Debug feedback for user
          try {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("✅ Profile Synced: ${updatedStudent.name}"),
                backgroundColor: Colors.green.withOpacity(0.8),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } catch (e) {
            print("⚠️ SnackBar error: $e");
          }
        }
        print("✅ Profile synced via StudentAuthService!");
      }
    } catch (e) {
      print("⚠️ Sync error: $e");
      // Don't crash the app, just log the error
    }
  }

  @override
  void dispose() {
    _drawerAnimationController.dispose();
    _appBarAnimationController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  // Helper method to safely get student name
  String _getSafeStudentName() {
    try {
      return StudentAuthService.currentStudent?.name ?? 'Student';
    } catch (e) {
      print("⚠️ Error getting student name: $e");
      return 'Student';
    }
  }

  // Helper method to safely build user badge
  Widget _buildSafeUserBadge() {
    try {
      final student = StudentAuthService.currentStudent;
      if (student != null && student.subscriptionTier != null) {
        return UserBadge(
          tier: student.subscriptionTier!,
          compact: false,
        );
      }
      return const SizedBox.shrink();
    } catch (e) {
      print("⚠️ Error building user badge: $e");
      return const SizedBox.shrink();
    }
  }

  Future<void> _checkFirstRun() async {
    try {
      // Check if user is logged in using the new service
      final student = await StudentAuthService.init();
      
      if (student == null) {
        // If not logged in, redirect to login
        if (mounted) {
           Navigator.pushReplacementNamed(context, '/auth');
        }
        return; // Exit if not logged in
      } else {
        // Check if biometric is enabled
        try {
          final box = Hive.box('user_prefs');
          final isBiometricEnabled = box.get('biometric_enabled', defaultValue: false);
          
          if (isBiometricEnabled) {
            // Biometric Auth on startup
            final authenticated = await AuthService.authenticate();
            if (!authenticated && mounted) {
              // Show authentication failed dialog
              _showAuthFailedDialog();
              return;
            }
          }

          // Start checking for notifications now that we are logged in
          NotificationService.listenForBuzzNotifications();
          
        } catch (e) {
          print("⚠️ Biometric check error: $e");
          // Continue without biometric if there's an error
          
          // Still try to listen for notifications
          NotificationService.listenForBuzzNotifications();
        }
      }
    } catch (e) {
      print("⚠️ First run check error: $e");
      // If there's any error, redirect to login as safety measure
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/auth');
      }
    }
  }

  void _showAuthFailedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text(
          'Authentication Required',
          style: TextStyle(color: Colors.redAccent),
        ),
        content: const Text(
          'Please authenticate to access Sentinel',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final authenticated = await AuthService.authenticate();
              if (!authenticated) {
                // Navigate back to auth screen
                Navigator.pushReplacementNamed(context, '/auth');
              }
            },
            child: const Text('Retry', style: TextStyle(color: Colors.cyanAccent)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/auth');
            },
            child: const Text('Login Again', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final box = Hive.box('user_prefs');
    final userName = box.get('user_name', defaultValue: 'Student');
    final userPhoto = box.get('user_photo');
    
    return Consumer2<ThemeProvider, AccessibilityProvider>(
      builder: (context, themeProvider, accessibilityProvider, child) {
        return Scaffold(
          extendBody: true, // Important for floating nav bar
          drawer: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black.withOpacity(0.98),
              Colors.grey.shade900.withOpacity(0.95),
              Colors.black.withOpacity(0.98),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(0.2),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Drawer(
          backgroundColor: Colors.transparent,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Revolutionary Drawer Header with Advanced Animations
              Container(
                height: 220,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.cyanAccent.withOpacity(0.9),
                      Colors.purple.withOpacity(0.8),
                      Colors.pink.withOpacity(0.7),
                      Colors.deepPurple.withOpacity(0.6),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.4),
                      blurRadius: 25,
                      spreadRadius: 8,
                    ),
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Enhanced Animated Background Pattern
                    AnimatedBuilder(
                      animation: _backgroundController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: DrawerPatternPainter(_backgroundController.value),
                          size: Size.infinite,
                        );
                      },
                    ),
                    
                    // Floating Orbs Animation
                    AnimatedBuilder(
                      animation: _backgroundController,
                      builder: (context, child) {
                        return Stack(
                          children: List.generate(8, (index) {
                            double phase = (_backgroundController.value + (index * 0.125)) % 1.0;
                            double x = 50 + (index * 25.0) + (15 * sin(phase * 2 * pi));
                            double y = 30 + (index * 20.0) + (20 * cos(phase * 2 * pi));
                            
                            return Positioned(
                              left: x,
                              top: y,
                              child: Container(
                                width: 12 + sin(phase * 4 * pi) * 4,
                                height: 12 + sin(phase * 4 * pi) * 4,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.white.withOpacity((sin(phase * pi) * 0.5 + 0.5).clamp(0.0, 1.0) * 0.6),
                                      Colors.cyanAccent.withOpacity((cos(phase * pi) * 0.5 + 0.5).clamp(0.0, 1.0) * 0.4),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                    
                    // Header Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Student Profile Row
                          // Profile Section - Clickable
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const StudentProfileScreen(),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.cyanAccent.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Profile Avatar
                                    Builder(
                                      builder: (context) {
                                        try {
                                          final student = StudentAuthService.currentStudent;
                                          final imageUrl = student?.imageUrl;
                                          final hasImage = imageUrl != null && imageUrl.isNotEmpty;
                                          
                                          return Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: !hasImage
                                                  ? RadialGradient(
                                                      colors: [
                                                        Colors.white.withOpacity(0.9),
                                                        Colors.cyanAccent.withOpacity(0.7),
                                                      ],
                                                    )
                                                  : null,
                                              image: hasImage
                                                  ? DecorationImage(
                                                      image: NetworkImage(imageUrl),
                                                      fit: BoxFit.cover,
                                                      onError: (exception, stackTrace) {
                                                        // Handle image loading error
                                                        print("Image loading error: $exception");
                                                      },
                                                    )
                                                  : null,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.white.withOpacity(0.5),
                                                  blurRadius: 15,
                                                  spreadRadius: 3,
                                                ),
                                              ],
                                            ),
                                            child: !hasImage
                                                ? Icon(
                                                    Icons.person,
                                                    color: Colors.black,
                                                    size: 30,
                                                  )
                                                : null,
                                          );
                                        } catch (e) {
                                          print("⚠️ Profile avatar error: $e");
                                          // Return fallback avatar
                                          return Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: RadialGradient(
                                                colors: [
                                                  Colors.white.withOpacity(0.9),
                                                  Colors.cyanAccent.withOpacity(0.7),
                                                ],
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.person,
                                              color: Colors.black,
                                              size: 30,
                                            ),
                                          );
                                        }
                                      },
                                    )
                                      .animate()
                                      .scale(delay: 200.ms, duration: 600.ms, curve: Curves.elasticOut)
                                      .then()
                                      .shimmer(duration: 2.seconds, color: Colors.white),
                                    
                                    const SizedBox(width: 12),
                                    
                                    // Student Name & Tier Badge
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _getSafeStudentName(),
                                            style: GoogleFonts.sourceCodePro(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          _buildSafeUserBadge(),
                                        ],
                                      ),
                                    ),
                                    
                                    // Edit icon hint
                                    Icon(
                                      Icons.edit_outlined,
                                      color: Colors.cyanAccent.withOpacity(0.6),
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                            .animate()
                            .fadeIn(delay: 300.ms)
                            .slideX(begin: -0.2),
                          
                          const SizedBox(height: 16),
                          
                          // App Title
                          ShaderMask(
                            shaderCallback: (bounds) {
                              // Prevent assertion error when bounds are empty or invalid
                              if (bounds.isEmpty || bounds.width <= 0 || bounds.height <= 0) {
                                return const LinearGradient(colors: [Colors.white, Colors.white]).createShader(const Rect.fromLTWH(0, 0, 1, 1));
                              }
                              return const LinearGradient(
                                colors: [Colors.white, Colors.cyanAccent, Colors.white],
                              ).createShader(bounds);
                            },
                            child: Text(
                              'Sentinel OS',
                              style: GoogleFonts.orbitron(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          )
                            .animate()
                            .fadeIn(delay: 400.ms, duration: 800.ms)
                            .slideX(begin: -0.3, end: 0)
                            .then()
                            .shimmer(duration: 3.seconds, color: Colors.white),
                          
                          // Subtitle
                          Text(
                            'Next-Gen Learning Platform',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w300,
                              letterSpacing: 1,
                            ),
                          )
                            .animate()
                            .fadeIn(delay: 600.ms, duration: 600.ms)
                            .slideX(begin: -0.2, end: 0),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            _buildAnimatedDrawerItem(
              icon: Icons.data_array_rounded,
              title: 'Data Structures',
              subtitle: '10 C Programs with Explanations',
              color: const Color(0xFFFF8E53),
              delay: 100,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DataStructuresScreen(),
                  ),
                );
              },
            ),
            _buildAnimatedDrawerItem(
              icon: Icons.quiz_outlined,
              title: 'DS Quiz Practice',
              subtitle: 'Random MCQs with AI Tutor',
              color: const Color(0xFF26C6DA),
              delay: 150,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuizTopicsScreen(),
                  ),
                );
              },
            ),


            _buildAnimatedDrawerItem(
              icon: Icons.shield_outlined,
              title: 'Cyber Library',
              color: Colors.amber,
              delay: 700,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CyberVaultScreen(),
                  ),
                );
              },
            ),
            _buildAnimatedDrawerItem(
              icon: Icons.account_tree,
              title: 'C Flowcharts',
              subtitle: '10 Programming Flowcharts',
              color: Colors.blue,
              delay: 725,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FlowchartsScreen(),
                  ),
                );
              },
            ),




            _buildAnimatedDrawerItem(
              icon: Icons.auto_stories_outlined,
              title: 'Academic Syllabus',
              color: Colors.amber,
              delay: 900,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SyllabusScreen(),
                  ),
                );
              },
            ),
            _buildAnimatedDrawerItem(
              icon: Icons.library_books,
              title: 'DevRef',
              subtitle: '100+ Developer References',
              color: Colors.deepPurple,
              delay: 950,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DevRefHubScreen(),
                  ),
                );
              },
            ),
            _buildAnimatedDrawerItem(
              icon: Icons.route_outlined,
              title: 'Tech Roadmaps',
              color: Colors.blue,
              delay: 950,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RoadmapsScreen(),
                  ),
                );
              },
            ),
            _buildAnimatedDrawerItem(
              icon: Icons.rocket_launch,
              title: 'LaunchPad',
              subtitle: 'Internships & Job Board',
              color: const Color(0xFF6C63FF),
              delay: 960,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LaunchpadScreen(),
                  ),
                );
              },
            ),
            _buildAnimatedDrawerItem(
              icon: Icons.auto_awesome,
              title: 'PromptCraft',
              subtitle: 'Prompt Engineering Course',
              color: const Color(0xFFFF6B6B),
              delay: 980,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PromptcraftHomeScreen(),
                  ),
                );
              },
            ),
            _buildAnimatedDrawerItem(
              icon: Icons.engineering_outlined,
              title: 'Engineering Hub',
              subtitle: 'Graphics & Diagrams',
              color: Colors.orangeAccent,
              delay: 1015,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EngineeringHub(),
                  ),
                );
              },
            ),
            // Sentinel AI Chat
            _buildAnimatedDrawerItem(
              icon: Icons.auto_awesome,
              title: 'Sentinel AI',
              subtitle: 'Your intelligent study assistant',
              color: const Color(0xFFFF6B6B),
              delay: 1025,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NovaChatScreen(),
                  ),
                );
              },
            ),
            _buildAnimatedDrawerItem(
              icon: Icons.forum_rounded,
              title: 'Community Doubts',
              subtitle: 'Ask & Solve Questions',
              color: Colors.cyanAccent,
              delay: 1035,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CommunityScreen(),
                  ),
                );
              },
            ),
            _buildAnimatedDrawerItem(
              icon: Icons.menu_book_outlined,
              title: 'Student Library',
              color: Colors.green,
              delay: 1050,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LibraryScreen(),
                  ),
                );
              },
            ),
            _buildAnimatedDrawerItem(
              icon: Icons.play_circle_outlined,
              title: 'Video Library',
              color: Colors.blue,
              delay: 1075,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VideoLibraryScreen(),
                  ),
                );
              },
            ),
            _buildAnimatedDrawerItem(
              icon: Icons.folder_special,
              title: 'Projects Store',
              subtitle: 'Download ready-made projects',
              color: Colors.purple,
              delay: 1090,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProjectsScreen(),
                  ),
                );
              },
            ),
            _buildAnimatedDrawerItem(
              icon: Icons.person_outline,
              title: 'Student Profile',
              subtitle: 'Manage your profile',
              color: Colors.teal,
              delay: 1095,
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StudentProfileScreen(),
                  ),
                );
                // Refresh home screen data when returning from profile
                if (mounted) {
                  setState(() {});
                }
              },
            ),

            _buildAnimatedDrawerItem(
              icon: Icons.leaderboard_outlined,
              title: 'Leaderboard',
              color: Colors.amber,
              delay: 1125,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LeaderboardScreen(),
                  ),
                );
              },
            ),

            _buildAnimatedDrawerItem(
              icon: Icons.security,
              title: 'Cybersecurity Tools',
              color: Colors.red,
              delay: 1150,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CybersecurityHubScreen(),
                  ),
                );
              },
            ),

            _buildAnimatedDrawerItem(
              icon: Icons.info_outline,
              title: 'About Sentinel',
              color: Colors.cyanAccent,
              delay: 1250,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutScreen(),
                  ),
                );
              },
            ),
            _buildAnimatedDrawerItem(
              icon: Icons.settings_outlined,
              title: 'System Settings',
              color: Colors.grey,
              delay: 1300,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainSettingsScreen(),
                  ),
                );
              },
            ),
            
            // Subscription Plans - NEW
            _buildAnimatedDrawerItem(
              icon: Icons.star,
              title: 'Subscription Plans',
              subtitle: 'Upgrade to Pro/Ultra',
              color: Colors.green,
              delay: 1350,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SubscriptionScreen(),
                  ),
                );
              },
            ),
            


            // Code Lens - AR Scanner
            _buildAnimatedDrawerItem(
              icon: Icons.qr_code_scanner_rounded,
              title: 'Code Lens',
              subtitle: 'Scan & clean code with AI',
              color: Colors.cyanAccent,
              delay: 1370,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CodeLensScreen(),
                  ),
                );
              },
            ),
            
            // LabMesh - P2P Sharing
            _buildAnimatedDrawerItem(
              icon: Icons.wifi_tethering_rounded,
              title: 'LabMesh',
              subtitle: 'Offline P2P sharing',
              color: Colors.greenAccent,
              delay: 1400,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LabMeshScreen(),
                  ),
                );
              },
            ),

            // Logout Button
            _buildAnimatedDrawerItem(
              icon: Icons.logout,
              title: 'Logout',
              subtitle: 'Sign out of account',
              color: Colors.redAccent,
              delay: 1450,
              onTap: () async {
                Navigator.pop(context);
                
                // Show confirmation dialog
                final confirm = await showGeneralDialog<bool>(
                  context: context,
                  barrierDismissible: true,
                  barrierLabel: 'Logout',
                  barrierColor: Colors.black.withOpacity(0.7),
                  transitionDuration: const Duration(milliseconds: 400),
                  transitionBuilder: (context, anim1, anim2, child) {
                    return ScaleTransition(
                      scale: CurvedAnimation(
                        parent: anim1,
                        curve: Curves.elasticOut,
                        reverseCurve: Curves.easeInBack,
                      ),
                      child: FadeTransition(opacity: anim1, child: child),
                    );
                  },
                  pageBuilder: (context, anim1, anim2) {
                    return Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: Material(
                          color: Colors.transparent,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1A2E).withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: Colors.redAccent.withOpacity(0.4),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.redAccent.withOpacity(0.3),
                                      blurRadius: 30,
                                      spreadRadius: 2,
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 20,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Animated warning icon
                                    TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      duration: const Duration(milliseconds: 600),
                                      builder: (context, value, child) {
                                        return Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: RadialGradient(
                                              colors: [
                                                Colors.redAccent.withOpacity(0.3 * value),
                                                Colors.redAccent.withOpacity(0.1 * value),
                                                Colors.transparent,
                                              ],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.redAccent.withOpacity(0.5 * value),
                                                blurRadius: 20 * value,
                                                spreadRadius: 4 * value,
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons.power_settings_new_rounded,
                                            size: 42,
                                            color: Color.lerp(Colors.grey, Colors.redAccent, value),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    
                                    // Title
                                    Text(
                                      'Sign Out?',
                                      style: GoogleFonts.poppins(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    // Subtitle
                                    Text(
                                      'You will need to login again\nto access your account',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey.shade400,
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 28),
                                    
                                    // Buttons
                                    Row(
                                      children: [
                                        // Cancel button
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => Navigator.pop(context, false),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.08),
                                                borderRadius: BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: Colors.white.withOpacity(0.15),
                                                ),
                                              ),
                                              child: Text(
                                                'Cancel',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.grey.shade300,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        // Logout button
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => Navigator.pop(context, true),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                                                ),
                                                borderRadius: BorderRadius.circular(16),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.redAccent.withOpacity(0.4),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                'Logout',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );

                if (confirm == true) {
                  try {
                    await StudentAuthService.logout();
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    }
                  } catch (e) {
                    print("⚠️ Logout error: $e");
                    // Force navigation to login even if logout fails
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AnimatedBuilder(
          animation: _appBarAnimationController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black.withOpacity(0.9),
                    Colors.grey.shade900.withOpacity(0.8),
                    Colors.black.withOpacity(0.9),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.cyanAccent.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.menu,
                      color: Colors.cyanAccent,
                    ),
                  ),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                )
                  .animate()
                  .scale(delay: 200.ms, duration: 600.ms, curve: Curves.elasticOut)
                  .then()
                  .shimmer(duration: 2.seconds, color: Colors.cyanAccent),
                
                title: ShaderMask(
                  shaderCallback: (bounds) {
                    // Prevent assertion error when bounds are empty or invalid
                    if (bounds.isEmpty || bounds.width <= 0 || bounds.height <= 0) {
                      return const LinearGradient(
                        colors: [Colors.cyanAccent, Colors.cyanAccent],
                      ).createShader(const Rect.fromLTWH(0, 0, 1, 1));
                    }
                    return LinearGradient(
                      colors: [
                        Colors.cyanAccent,
                        Colors.white,
                        Colors.cyanAccent,
                      ],
                    ).createShader(bounds);
                  },
                  child: Text(
                    userName,
                    style: GoogleFonts.orbitron(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 800.ms)
                  .slideX(begin: -0.3, end: 0)
                  .then()
                  .shimmer(duration: 3.seconds, color: Colors.white),
                actions: [
                  // Animated News Bell Icon with Badge
                  FutureBuilder<int>(
                    future: NotificationService.getUnreadCount(),
                    builder: (context, snapshot) {
                      final unreadCount = snapshot.data ?? 0;
                      
                      // Listen for badge updates
                      try {
                        NotificationService.setOnUnreadCountChanged((count) {
                          if (mounted) {
                            try {
                              setState(() {});
                            } catch (e) {
                              print("⚠️ setState error in notification listener: $e");
                            }
                          }
                        });
                      } catch (e) {
                        print("⚠️ Notification listener setup error: $e");
                      }
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: Badge(
                          label: Text('$unreadCount'),
                          isLabelVisible: unreadCount > 0,
                          backgroundColor: Colors.red,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.cyanAccent.withOpacity(0.3),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.notifications_outlined, color: Colors.cyanAccent),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const NewsScreen(),
                                  ),
                                ).then((_) {
                                  // Refresh badge when returning from news screen
                                  if (mounted) setState(() {});
                                });
                              },
                            ),
                          ),
                        ),
                      )
                        .animate()
                        .scale(delay: 600.ms, duration: 600.ms, curve: Curves.elasticOut)
                        .then()
                        .shake(hz: 2, curve: Curves.easeInOut);
                    },
                  ),
                  
                  // Enhanced User Photo
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.cyanAccent,
                          Colors.purple,
                          Colors.cyanAccent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: userPhoto != null
                        ? ClipOval(
                            child: Image.file(
                              File(userPhoto),
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const CircleAvatar(
                                  backgroundColor: Colors.cyanAccent,
                                  child: Icon(Icons.person, color: Colors.black),
                                );
                              },
                            ),
                          )
                        : const CircleAvatar(
                            backgroundColor: Colors.cyanAccent,
                            child: Icon(Icons.person, color: Colors.black),
                          ),
                  )
                    .animate()
                    .scale(delay: 800.ms, duration: 600.ms, curve: Curves.elasticOut)
                    .then()
                    .shimmer(duration: 2.seconds, color: Colors.white),
                  

                ],
              ),
            );
          },
        ),
      ),
          body: Stack(
            children: [
              // Revolutionary Animated Background
              AnimatedBuilder(
                animation: _backgroundController,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.5 + sin(_backgroundController.value * 2 * pi) * 0.3,
                        colors: [
                          const Color(0xFF0A0A0A),
                          const Color(0xFF1A1A2E),
                          const Color(0xFF16213E),
                          Colors.black,
                        ],
                      ),
                    ),
                    child: CustomPaint(
                      painter: BackgroundPatternPainter(_backgroundController.value),
                      size: Size.infinite,
                    ),
                  );
                },
              ),

              // Floating Orbs Background
              AnimatedBuilder(
                animation: _backgroundController,
                builder: (context, child) {
                  return Stack(
                    children: List.generate(8, (index) {
                      double phase = (_backgroundController.value + (index * 0.125)) % 1.0;
                      double x = MediaQuery.of(context).size.width * (0.1 + (index * 0.1));
                      double y = MediaQuery.of(context).size.height * (0.2 + sin(phase * 2 * pi) * 0.3);
                      
                      return Positioned(
                        left: x,
                        top: y,
                        child: Container(
                          width: 20 + sin(phase * 4 * pi) * 5,
                          height: 20 + sin(phase * 4 * pi) * 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.cyanAccent.withOpacity((sin(phase * pi) * 0.5 + 0.5).clamp(0.0, 1.0) * 0.3),
                                Colors.purple.withOpacity((cos(phase * pi) * 0.5 + 0.5).clamp(0.0, 1.0) * 0.2),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),

              // Content with Page Transition Animation
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 125),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.3, 0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        )),
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      key: ValueKey(_currentIndex),
                      child: _screens[_currentIndex],
                    ),
                  ),
                ),
              ),

              // Enhanced Glass Bottom Nav
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                  child: AquamorphicNavBar(
                    currentIndex: _currentIndex,
                    onTap: (index) {
                      accessibilityProvider.provideFeedback(
                        text: 'Switched to ${_getScreenName(index)}',
                      );
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getScreenName(int index) {
    switch (index) {
      case 0: return 'Timetable';
      case 1: return 'Chat';
      case 2: return 'Routine';
      case 3: return 'Diary';
      default: return 'Screen';
    }
  }

  Widget _buildAnimatedDrawerItem({
  required IconData icon,
  required String title,
  required Color color,
  required VoidCallback onTap,
  int delay = 0,
  String? subtitle,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      gradient: LinearGradient(
        colors: [
          Colors.transparent,
          color.withOpacity(0.08),
          Colors.transparent,
        ],
      ),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        splashColor: color.withOpacity(0.2),
        highlightColor: color.withOpacity(0.1),
        onTap: onTap,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withOpacity(0.3),
                  color.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: color.withOpacity(0.6),
            size: 20,
          ),
        ),
      ),
    ),
  );
}

  Widget _buildAnimatedExpansionTile({
    required IconData icon,
    required String title,
    required Color color,
    required List<Widget> children,
    int delay = 0,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            color.withOpacity(0.08),
            Colors.transparent,
          ],
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withOpacity(0.3),
                  color.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          iconColor: color,
          collapsedIconColor: color.withOpacity(0.7),
          children: children,
        ),
      ),
    );
  }
}

// Custom Painter for Drawer Background Pattern
class DrawerPatternPainter extends CustomPainter {
  final double animationValue;

  DrawerPatternPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;

    // Draw animated grid pattern
    for (int i = 0; i < 10; i++) {
      double offset = (animationValue * 50) % 50;
      double x = (i * 20.0) + offset;
      
      if (x < size.width) {
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, size.height),
          paint,
        );
      }
    }

    // Draw floating circles
    for (int i = 0; i < 5; i++) {
      double phase = (animationValue + (i * 0.2)) % 1.0;
      double x = size.width * 0.2 + (i * size.width * 0.15);
      double y = size.height * 0.3 + sin(phase * 2 * pi) * 30;
      
      canvas.drawCircle(
        Offset(x, y),
        5 + sin(phase * 4 * pi) * 2,
        Paint()
          ..color = Colors.white.withOpacity(0.2)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Background Pattern Painter for Main Screen
class BackgroundPatternPainter extends CustomPainter {
  final double animationValue;

  BackgroundPatternPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.05)
      ..strokeWidth = 1;

    // Draw animated hexagonal pattern
    for (int i = 0; i < 20; i++) {
      for (int j = 0; j < 15; j++) {
        double x = (i * 40.0) + (j % 2) * 20 + (animationValue * 10) % 40;
        double y = (j * 35.0) + (animationValue * 5) % 35;
        
        if (x < size.width + 40 && y < size.height + 40) {
          _drawHexagon(canvas, Offset(x, y), 15, paint);
        }
      }
    }

    // Draw flowing lines
    final linePaint = Paint()
      ..color = Colors.purple.withOpacity(0.1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 5; i++) {
      final path = Path();
      double startY = size.height * (0.2 + i * 0.15);
      path.moveTo(0, startY);
      
      for (double x = 0; x <= size.width; x += 10) {
        double y = startY + sin((x / 100) + (animationValue * 2 * pi) + (i * pi / 3)) * 20;
        path.lineTo(x, y);
      }
      
      canvas.drawPath(path, linePaint);
    }
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      double angle = (i * pi) / 3;
      double x = center.dx + radius * cos(angle);
      double y = center.dy + radius * sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
