import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/student_auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  bool _isLogin = true;
  bool _isLoading = false;
  
  // Controllers
  final _nameController = TextEditingController();
  final _regdController = TextEditingController();
  
  // Focus nodes for lamp effect
  final _nameFocus = FocusNode();
  final _regdFocus = FocusNode();
  
  // Lamp animation
  late AnimationController _lampController;
  late AnimationController _animController;
  late AnimationController _lampPulseController;
  
  // Avatar Selection
  String? _selectedAvatar;
  final List<String> _avatars = [
    'https://api.dicebear.com/7.x/avataaars/png?seed=Felix',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Aneka',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Bob',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Mila',
  ];
  
  // Dropdown options
  final List<String> _groups = ['CSE', 'ECE', 'EEE', 'MECH', 'CIVIL', 'IT', 'AIDS', 'AIML', 'Cyber Security', 'Other'];
  final List<String> _sections = ['A', 'B', 'C', 'D', 'E'];
  final List<String> _years = ['1', '2', '3', '4'];
  
  String? _selectedGroup;
  String? _selectedSection;
  String? _selectedYear;
  
  bool _hasAnyFocus = false;
  int _filledFieldCount = 0;

  @override
  void initState() {
    super.initState();
    
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animController.forward();
    
    // Lamp on/off controller
    _lampController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    // Lamp breathing pulse
    _lampPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    // Listen for focus changes
    _nameFocus.addListener(_onFocusChange);
    _regdFocus.addListener(_onFocusChange);
    
    // Listen for text changes to track filled fields
    _nameController.addListener(_updateFilledCount);
    _regdController.addListener(_updateFilledCount);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _regdController.dispose();
    _nameFocus.dispose();
    _regdFocus.dispose();
    _animController.dispose();
    _lampController.dispose();
    _lampPulseController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    final hasFocus = _nameFocus.hasFocus || _regdFocus.hasFocus;
    if (hasFocus != _hasAnyFocus) {
      setState(() => _hasAnyFocus = hasFocus);
      if (hasFocus) {
        _lampController.forward();
        _lampPulseController.repeat(reverse: true);
      } else {
        // Keep lamp on if fields have content
        if (_filledFieldCount == 0) {
          _lampController.reverse();
          _lampPulseController.stop();
        }
      }
    }
  }

  void _updateFilledCount() {
    int count = 0;
    if (_nameController.text.trim().isNotEmpty) count++;
    if (_regdController.text.trim().isNotEmpty) count++;
    if (_selectedGroup != null) count++;
    if (_selectedSection != null) count++;
    if (_selectedYear != null) count++;
    
    if (count != _filledFieldCount) {
      setState(() => _filledFieldCount = count);
      // Turn on lamp if any field is filled
      if (count > 0 && !_lampController.isAnimating && _lampController.value == 0) {
        _lampController.forward();
        _lampPulseController.repeat(reverse: true);
      }
    }
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
    _animController.reset();
    _animController.forward();
  }

  Future<void> _handleSubmit() async {
    final name = _nameController.text.trim();
    final regdNo = _regdController.text.trim();
    
    if (name.isEmpty || regdNo.isEmpty) {
      _showError('Please fill all required fields');
      return;
    }
    
    setState(() => _isLoading = true);
    
    if (_isLogin) {
      // Login
      final result = await StudentAuthService.login(name, regdNo);
      
      if (result.student != null && mounted) {
        HapticFeedback.mediumImpact();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else if (mounted) {
        _showError(result.error ?? 'Login failed');
      }
    } else {
      // Register
      if (_selectedGroup == null || _selectedSection == null || _selectedYear == null) {
        _showError('Please fill all required fields');
        setState(() => _isLoading = false);
        return;
      }
      
      final result = await StudentAuthService.register(
        name: name,
        regdNo: regdNo,
        group: _selectedGroup!,
        section: _selectedSection!,
        year: _selectedYear!,
        imageUrl: _selectedAvatar,
      );
      
      if (result.success && mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Please login.'),
            backgroundColor: Colors.green,
          ),
        );
        _toggleMode(); // Switch to login
      } else if (mounted) {
        _showError(result.error ?? 'Registration failed');
      }
    }
    
    if (mounted) setState(() => _isLoading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Calculate lamp intensity (0.0 to 1.0) based on filled fields
  double get _lampIntensity {
    final maxFields = _isLogin ? 2 : 5;
    return (_filledFieldCount / maxFields).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF1A0A2E),
                    const Color(0xFF0A0A0F),
                    Colors.purple.withOpacity(0.15),
                  ],
                ),
              ),
            ),
            
            // Decorative circles
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.purple.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              left: -80,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.cyanAccent.withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            
            // Main content
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  
                  // Logo - Using Launcher Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B6B).withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/launcher_icon.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                  
                  const SizedBox(height: 20),
                  
                  // Title
                  ShaderMask(
                    shaderCallback: (bounds) {
                      if (bounds.isEmpty) {
                        return const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFFF6B6B)],
                        ).createShader(Rect.fromLTWH(0, 0, 1, 1));
                      }
                      return const LinearGradient(
                        colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                      ).createShader(bounds);
                    },
                    child: Text(
                      'Sentinel',
                      style: GoogleFonts.poppins(
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.3),
                  
                  Text(
                    'Student OS',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                      letterSpacing: 6,
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  
                  const SizedBox(height: 30),
                  
                  // === LAMP + FORM CONTAINER ===
                  AnimatedBuilder(
                    animation: Listenable.merge([_lampController, _lampPulseController]),
                    builder: (context, child) {
                      final lampVal = _lampController.value;
                      final pulseVal = _lampPulseController.value;
                      final intensity = _lampIntensity;
                      // warm amber color
                      final lampColor = Color.lerp(
                        Colors.grey.shade600,
                        const Color(0xFFFFB74D), // warm amber
                        lampVal,
                      )!;
                      
                      return Column(
                        children: [
                          // === Desk Lamp Widget ===
                          SizedBox(
                            height: 60,
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                // Lamp base/pole
                                Positioned(
                                  bottom: 0,
                                  child: Container(
                                    width: 4,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade700,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                                // Lamp shade (trapezoid-ish)
                                Positioned(
                                  top: 0,
                                  child: Container(
                                    width: 60,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.grey.shade800,
                                          Colors.grey.shade700,
                                        ],
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(4),
                                        topRight: Radius.circular(4),
                                        bottomLeft: Radius.circular(20),
                                        bottomRight: Radius.circular(20),
                                      ),
                                      border: Border.all(
                                        color: lampColor.withOpacity(0.5),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: lampColor.withOpacity(0.6 * lampVal),
                                          blurRadius: 15 * lampVal,
                                          spreadRadius: 2 * lampVal,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: lampColor,
                                          boxShadow: [
                                            BoxShadow(
                                              color: lampColor.withOpacity(0.8 * lampVal),
                                              blurRadius: 10 * lampVal,
                                              spreadRadius: 3 * lampVal,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // === Light Cone (using CustomPaint) ===
                          SizedBox(
                            width: double.infinity,
                            height: 30,
                            child: CustomPaint(
                              painter: _LightConePainter(
                                intensity: lampVal,
                                pulseValue: pulseVal,
                                color: lampColor,
                                fillProgress: intensity,
                              ),
                            ),
                          ),
                          
                          // === Form Card with lamp illumination ===
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Color.lerp(
                                const Color(0xFF1A1A2E).withOpacity(0.8),
                                const Color(0xFF2A1A1E).withOpacity(0.9),
                                lampVal * 0.3,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Color.lerp(
                                  Colors.purple.withOpacity(0.3),
                                  lampColor.withOpacity(0.5),
                                  lampVal,
                                )!,
                              ),
                              boxShadow: [
                                // Lamp illumination shadow from top
                                BoxShadow(
                                  color: lampColor.withOpacity(0.15 * lampVal + 0.1 * pulseVal * lampVal),
                                  blurRadius: 40 * lampVal,
                                  spreadRadius: 4 * lampVal,
                                  offset: const Offset(0, -5),
                                ),
                                // Subtle ambient glow based on fill progress
                                BoxShadow(
                                  color: lampColor.withOpacity(0.1 * intensity),
                                  blurRadius: 60 * intensity,
                                  spreadRadius: 8 * intensity,
                                ),
                              ],
                            ),
                            child: child!,
                          ),
                        ],
                      );
                    },
                    child: _buildFormContent(),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.15),
                  
                  const SizedBox(height: 24),
                  
                  // Info text
                  Text(
                    _isLogin
                        ? "Don't have an account? Tap Register above"
                        : "Already have an account? Tap Login above",
                    style: GoogleFonts.poppins(
                      color: Colors.purple.shade300,
                      fontSize: 13,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Column(
      children: [
        // Toggle buttons
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.cyanAccent.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _isLogin ? null : _toggleMode(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _isLogin ? Colors.cyanAccent : Colors.transparent,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Text(
                      'Login',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: _isLogin ? Colors.black : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _isLogin ? _toggleMode() : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: !_isLogin ? Colors.purple : Colors.transparent,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Text(
                      'Register',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: !_isLogin ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 28),
        
        // Name field
        _buildTextField(
          controller: _nameController,
          label: 'Full Name',
          icon: Icons.person_outline,
          focusNode: _nameFocus,
        ),
        
        const SizedBox(height: 16),
        
        // Regd No field
        _buildTextField(
          controller: _regdController,
          label: 'Registration Number',
          icon: Icons.badge_outlined,
          focusNode: _regdFocus,
        ),
        
        // Registration-only fields
        if (!_isLogin) ...[
          const SizedBox(height: 24),

          // Avatar Selector
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Select Avatar (Optional)',
              style: GoogleFonts.poppins(
                color: Colors.purple.shade300,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _avatars.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final avatar = _avatars[index];
                final isSelected = _selectedAvatar == avatar;
                return GestureDetector(
                  onTap: () => setState(() => _selectedAvatar = avatar),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.cyanAccent : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.cyanAccent.withOpacity(0.4),
                                blurRadius: 12,
                              )
                            ]
                          : null,
                    ),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(avatar),
                      backgroundColor: Colors.grey.shade800,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          
          // Group dropdown
          _buildDropdown(
            value: _selectedGroup,
            items: _groups,
            label: 'Branch/Group',
            icon: Icons.school_outlined,
            onChanged: (val) {
              setState(() => _selectedGroup = val);
              _updateFilledCount();
            },
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              // Section dropdown
              Expanded(
                child: _buildDropdown(
                  value: _selectedSection,
                  items: _sections,
                  label: 'Section',
                  icon: Icons.class_outlined,
                  onChanged: (val) {
                    setState(() => _selectedSection = val);
                    _updateFilledCount();
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Year dropdown
              Expanded(
                child: _buildDropdown(
                  value: _selectedYear,
                  items: _years,
                  label: 'Year',
                  icon: Icons.calendar_today_outlined,
                  onChanged: (val) {
                    setState(() => _selectedYear = val);
                    _updateFilledCount();
                  },
                ),
              ),
            ],
          ),
        ],
        
        const SizedBox(height: 28),
        
        // Submit button
        SizedBox(
          width: double.infinity,
          child: AnimatedBuilder(
            animation: _lampController,
            builder: (context, child) {
              final lampOn = _lampController.value > 0.5;
              return ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isLogin ? Colors.cyanAccent : Colors.purple,
                  foregroundColor: _isLogin ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: lampOn ? 12 : 8,
                  shadowColor: (_isLogin ? Colors.cyanAccent : Colors.purple).withOpacity(lampOn ? 0.7 : 0.5),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        _isLogin ? 'Login' : 'Create Account',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required FocusNode focusNode,
  }) {
    return AnimatedBuilder(
      animation: _lampController,
      builder: (context, _) {
        final lampVal = _lampController.value;
        final isFocused = focusNode.hasFocus;
        final hasFill = controller.text.trim().isNotEmpty;
        
        // When lamp is on and field is focused/filled, use warm amber glow
        final glowColor = (isFocused || hasFill) && lampVal > 0
            ? Color.lerp(Colors.cyanAccent, const Color(0xFFFFB74D), lampVal)!
            : Colors.cyanAccent;
        
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: isFocused && lampVal > 0
                ? [
                    BoxShadow(
                      color: glowColor.withOpacity(0.3 * lampVal),
                      blurRadius: 12 * lampVal,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            style: GoogleFonts.poppins(color: Colors.white),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
              prefixIcon: Icon(icon, color: glowColor),
              filled: true,
              fillColor: isFocused && lampVal > 0
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: glowColor, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: hasFill && lampVal > 0
                      ? glowColor.withOpacity(0.5)
                      : Colors.cyanAccent.withOpacity(0.3),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String label,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return AnimatedBuilder(
      animation: _lampController,
      builder: (context, _) {
        final lampVal = _lampController.value;
        final hasFill = value != null;
        
        final glowColor = hasFill && lampVal > 0
            ? Color.lerp(Colors.purple, const Color(0xFFFFB74D), lampVal * 0.6)!
            : Colors.purple;
        
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: hasFill && lampVal > 0
                ? [
                    BoxShadow(
                      color: glowColor.withOpacity(0.2 * lampVal),
                      blurRadius: 8 * lampVal,
                    ),
                  ]
                : null,
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            items: items.map((item) => DropdownMenuItem(
              value: item,
              child: Text(item),
            )).toList(),
            onChanged: onChanged,
            style: GoogleFonts.poppins(color: Colors.white),
            dropdownColor: const Color(0xFF1A1A2E),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
              prefixIcon: Icon(icon, color: glowColor),
              filled: true,
              fillColor: Colors.black.withOpacity(0.4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: hasFill && lampVal > 0
                      ? glowColor.withOpacity(0.5)
                      : Colors.purple.withOpacity(0.3),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Custom painter that draws a light cone from the lamp onto the form
class _LightConePainter extends CustomPainter {
  final double intensity; // 0.0 = off, 1.0 = fully on
  final double pulseValue;
  final Color color;
  final double fillProgress;

  _LightConePainter({
    required this.intensity,
    required this.pulseValue,
    required this.color,
    required this.fillProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity < 0.01) return;
    
    final centerX = size.width / 2;
    
    // Light cone: narrow at top (lamp), wide at bottom (form)
    final topWidth = 30.0;
    final bottomWidth = size.width * (0.5 + 0.3 * fillProgress);
    final alpha = (0.15 + 0.1 * pulseValue) * intensity;
    
    final path = Path()
      ..moveTo(centerX - topWidth / 2, 0)
      ..lineTo(centerX - bottomWidth / 2, size.height)
      ..lineTo(centerX + bottomWidth / 2, size.height)
      ..lineTo(centerX + topWidth / 2, 0)
      ..close();
    
    // Gradient fill for the light cone
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(alpha * 1.5),
          color.withOpacity(alpha * 0.8),
          color.withOpacity(alpha * 0.2),
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawPath(path, paint);
    
    // Add a soft glow at the top center (bulb glow)
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(0.4 * intensity),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: Offset(centerX, 0), radius: 25),
      );
    canvas.drawCircle(Offset(centerX, 0), 25, glowPaint);
  }

  @override
  bool shouldRepaint(_LightConePainter oldDelegate) {
    return oldDelegate.intensity != intensity ||
           oldDelegate.pulseValue != pulseValue ||
           oldDelegate.fillProgress != fillProgress;
  }
}
