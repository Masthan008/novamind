import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
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

// Phase 1 â€” New Zerno Screens
import 'bunk_meter/bunk_meter_screen.dart';
import 'cgpa/cgpa_warroom_screen.dart';
import 'exam_countdown/exam_countdown_screen.dart';
import 'assignments/assignment_tracker_screen.dart';
import 'tools_directory/tools_directory_screen.dart';
import 'skill_gap/skill_gap_screen.dart';
import 'opportunities/opportunities_screen.dart';
import 'skillproof/skillproof_screen.dart';
import 'community/community_screen.dart';
import 'personal/daily_routine_screen.dart';
import 'personal/diary_screen.dart';
import '../widgets/flux_drawer.dart';
import '../widgets/animated_side_menu.dart';

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

  // â”€â”€â”€ ANIMATED SIDEBAR â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  late AnimationController _sidebarController;
  late Animation<double> _sidebarAnim;
  bool _isSideMenuOpen = false;

  final _springDesc = const SpringDescription(
    mass: 0.1,
    stiffness: 40,
    damping: 5,
  );

  void _toggleSideMenu() {
    if (_isSideMenuOpen) {
      _sidebarController.reverse();
    } else {
      final springAnim = SpringSimulation(_springDesc, 0, 1, 0);
      _sidebarController.animateWith(springAnim);
    }
    setState(() {
      _isSideMenuOpen = !_isSideMenuOpen;
    });
  }

  void _closeSideMenu() {
    if (_isSideMenuOpen) {
      _sidebarController.reverse();
      setState(() {
        _isSideMenuOpen = false;
      });
    }
  }
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  
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

    // Sidebar animation
    _sidebarController = AnimationController(
      duration: const Duration(milliseconds: 200),
      upperBound: 1,
      vsync: this,
    );
    _sidebarAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _sidebarController, curve: Curves.linear),
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
          print("âš ï¸ Hive update error: $e");
        }

        if (mounted) {
          setState(() {}); // Force UI rebuild with new data
          
          // Debug feedback for user
          try {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("âœ… Profile Synced: ${updatedStudent.name}"),
                backgroundColor: Colors.green.withOpacity(0.8),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } catch (e) {
            print("âš ï¸ SnackBar error: $e");
          }
        }
        print("âœ… Profile synced via StudentAuthService!");
      }
    } catch (e) {
      print("âš ï¸ Sync error: $e");
      // Don't crash the app, just log the error
    }
  }

  @override
  void dispose() {
    _drawerAnimationController.dispose();
    _appBarAnimationController.dispose();
    _backgroundController.dispose();
    _sidebarController.dispose();
    super.dispose();
  }

  // Helper method to safely get student name
  String _getSafeStudentName() {
    try {
      return StudentAuthService.currentStudent?.name ?? 'Student';
    } catch (e) {
      print("âš ï¸ Error getting student name: $e");
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
      print("âš ï¸ Error building user badge: $e");
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
          print("âš ï¸ Biometric check error: $e");
          // Continue without biometric if there's an error
          
          // Still try to listen for notifications
          NotificationService.listenForBuzzNotifications();
        }
      }
    } catch (e) {
      print("âš ï¸ First run check error: $e");
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
          'Please authenticate to access Zerno',
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
        return Stack(
          children: [
            // â”€â”€â”€ 1) DARK BACKGROUND BEHIND SIDEBAR â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Positioned.fill(
              child: Container(color: const Color(0xFF17203A)),
            ),

            // â”€â”€â”€ 2) ANIMATED SIDE MENU â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            RepaintBoundary(
              child: AnimatedBuilder(
                animation: _sidebarAnim,
                builder: (context, child) {
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(((1 - _sidebarAnim.value) * -30) * pi / 180)
                      ..translate((1 - _sidebarAnim.value) * -300.0),
                    child: child,
                  );
                },
                child: FadeTransition(
                  opacity: _sidebarAnim,
                  child: AnimatedSideMenu(
                    onClose: _closeSideMenu,
                    onLogout: () async {
                      _closeSideMenu();
                      // Reuse existing logout dialog
                      final confirm = await _showLogoutDialog(context);
                      if (confirm == true) {
                        try {
                          await StudentAuthService.logout();
                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                          }
                        }
                      }
                    },
                  ),
                ),
              ),
            ),

            // â”€â”€â”€ 3) ANIMATED MAIN BODY â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            RepaintBoundary(
              child: AnimatedBuilder(
                animation: _sidebarAnim,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1 - (_sidebarAnim.value * 0.1),
                    child: Transform.translate(
                      offset: Offset(_sidebarAnim.value * 265, 0),
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY((_sidebarAnim.value * 30) * pi / 180),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(_sidebarAnim.value * 24),
                          child: child,
                        ),
                      ),
                    ),
                  );
                },
                child: GestureDetector(
                  onTap: _isSideMenuOpen ? _closeSideMenu : null,
                  child: AbsorbPointer(
                    absorbing: _isSideMenuOpen,
                    child: Scaffold(
          extendBody: true,
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
                  onPressed: _toggleSideMenu,
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
                              print("âš ï¸ setState error in notification listener: $e");
                            }
                          }
                        });
                      } catch (e) {
                        print("âš ï¸ Notification listener setup error: $e");
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
        ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Logout',
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut, reverseCurve: Curves.easeInBack),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
      pageBuilder: (ctx, anim1, anim2) {
        return Center(
          child: Container(
            width: MediaQuery.of(ctx).size.width * 0.85,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.redAccent.withOpacity(0.4), width: 1.5),
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.power_settings_new_rounded, size: 42, color: Colors.redAccent),
                  const SizedBox(height: 20),
                  Text('Sign Out?', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text('You will need to login again', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade400)),
                  const SizedBox(height: 28),
                  Row(children: [
                    Expanded(child: GestureDetector(onTap: () => Navigator.pop(ctx, false), child: Container(padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(16)), child: Text('Cancel', textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.grey.shade300, fontWeight: FontWeight.w600))))),
                    const SizedBox(width: 14),
                    Expanded(child: GestureDetector(onTap: () => Navigator.pop(ctx, true), child: Container(padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)]), borderRadius: BorderRadius.circular(16)), child: Text('Logout', textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold))))),
                  ]),
                ],
              ),
            ),
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
