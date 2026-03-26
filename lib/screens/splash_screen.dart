import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/auth_service.dart';
import '../animations/slide_up_route.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import '../services/student_auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _loadingController;
  late AnimationController _textController;
  
  late Animation<double> _loadingAnimation;
  late Animation<double> _textFadeAnimation;
  
  double _loadingProgress = 0.0;
  String _loadingText = '🚀 Initializing Zerno...';
  String _subText = 'Preparing your learning experience';
  bool _isLoading = true;
  
  final List<String> _loadingMessages = [
    '🔧 Initializing core systems...',
    '🎯 Loading smart features...',
    '🔐 Securing your data...',
    '🌟 Optimizing performance...',
    '🎨 Preparing beautiful UI...',
    '✨ Almost ready...',
    '🎉 Welcome to Zerno!'
  ];
  
  final List<String> _subMessages = [
    'Setting up your personalized dashboard',
    'Loading AI-powered study tools',
    'Encrypting your personal information',
    'Calibrating adaptive algorithms',
    'Rendering stunning animations',
    'Final touches in progress',
    'Your learning journey begins now!'
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Initialize animations
    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOutCubic,
    ));

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _textController.forward();
    _startLoadingSequence();
  }
  
  @override
  void dispose() {
    _loadingController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _startLoadingSequence() async {
    // Enhanced loading sequence with dynamic messages
    for (int i = 0; i < _loadingMessages.length; i++) {
      double progress = (i + 1) / _loadingMessages.length;
      await _updateProgress(progress, _loadingMessages[i], _subMessages[i]);
      
      if (i == 1) {
        await _checkPermissions();
      }
      
      // Variable delays for realistic loading feel
      int delay = i == 0 ? 800 : (i == _loadingMessages.length - 1 ? 1200 : 600);
      await Future.delayed(Duration(milliseconds: delay));
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      
      // Dramatic pause before navigation
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        await _checkBiometricAndNavigate();
      }
    }
  }

  Future<void> _updateProgress(double progress, String text, String subText) async {
    if (mounted) {
      setState(() {
        _loadingProgress = progress;
        _loadingText = text;
        _subText = subText;
      });
      
      // Animate the progress bar with easing
      _loadingController.animateTo(progress, 
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
      );
      
      // Reset and restart text animation for each update
      _textController.reset();
      _textController.forward();
      
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  Future<void> _checkPermissions() async {
    // Request necessary permissions (removed location to save memory)
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.notification,
      Permission.scheduleExactAlarm,
      Permission.ignoreBatteryOptimizations, // Critical for alarms
    ].request();

    // Log status for debugging
    debugPrint("Permissions: $statuses");

    if (mounted) {
      await _checkBiometricAndNavigate();
    }
  }

  Future<void> _checkBiometricAndNavigate() async {
    // Simply navigate to the next screen - authentication will be handled in _navigateNext()
    if (mounted) {
      _navigateNext();
    }
  }

  Future<void> _navigateNext() async {
    try {
      // 1. Wait a moment for visual smoothness
      await Future.delayed(const Duration(seconds: 2));

      // 2. Ask the Service to initialize
      // (This automatically checks SharedPreferences and loads Supabase data)
      final student = await StudentAuthService.init();
      
      if (!mounted) return;

      if (student != null) {
        // ✅ Logged In -> Home
        Navigator.pushReplacement(
          context, 
          SlideUpRoute(page: const HomeScreen())
        );
      } else {
        // ❌ Not Logged In -> Login
        Navigator.pushReplacement(
          context, 
          SlideUpRoute(page: const LoginScreen())
        );
      }
    } catch (e) {
      debugPrint("Splash Error: $e");
      // Safety Net: Go to login if anything explodes
      if (mounted) {
        Navigator.pushReplacement(
          context, 
          SlideUpRoute(page: const LoginScreen())
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full screen splash background image
          Image.asset(
            'assets/images/splash_screen.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          
          // Subtle gradient overlay for depth at bottom
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.9),
                ],
                stops: const [0.0, 0.6, 0.85, 1.0],
              ),
            ),
          ),
          
          // Loading indicator at bottom
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Loading text
                if (_isLoading) ...[
                  AnimatedBuilder(
                    animation: _textFadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textFadeAnimation.value,
                        child: Text(
                          _loadingText,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Progress bar
                  Container(
                    width: 200,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: Colors.white.withOpacity(0.15),
                    ),
                    child: AnimatedBuilder(
                      animation: _loadingAnimation,
                      builder: (context, child) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 200 * _loadingAnimation.value,
                            height: 4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF6B6B).withOpacity(0.5),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ).animate().fadeIn(delay: 500.ms),
                  
                  const SizedBox(height: 8),
                  
                  // Percentage
                  AnimatedBuilder(
                    animation: _loadingAnimation,
                    builder: (context, child) {
                      return Text(
                        '${(_loadingProgress * 100).toInt()}%',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      );
                    },
                  ),
                ] else ...[
                  // Ready state
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B6B).withOpacity(0.1),
                      border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'Ready to Launch',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFFFF6B6B),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ).animate().fadeIn().scale().shimmer(delay: 500.ms, duration: 2.seconds),
                ],
                
                const SizedBox(height: 20),
                
                // Signature
                Text(
                  "Crafted with ❤️ by MASTHAN VALLI",
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.3),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
