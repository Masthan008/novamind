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

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  bool _isLoading = false;
  
  // Controllers
  final _nameController = TextEditingController();
  final _regdController = TextEditingController();
  
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
  
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _regdController.dispose();
    _animController.dispose();
    super.dispose();
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
                  
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.cyanAccent.withOpacity(0.2),
                          Colors.purple.withOpacity(0.2),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.cyanAccent.withOpacity(0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.school,
                      size: 50,
                      color: Colors.cyanAccent,
                    ),
                  ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                  
                  const SizedBox(height: 20),
                  
                  // Title
                  ShaderMask(
                    shaderCallback: (bounds) {
                      if (bounds.isEmpty) {
                        return const LinearGradient(
                          colors: [Colors.cyanAccent, Colors.cyanAccent],
                        ).createShader(Rect.fromLTWH(0, 0, 1, 1));
                      }
                      return const LinearGradient(
                        colors: [Colors.cyanAccent, Colors.purple],
                      ).createShader(bounds);
                    },
                    child: Text(
                      'Sentinel',
                      style: GoogleFonts.orbitron(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
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
                  
                  const SizedBox(height: 40),
                  
                  // Form Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.purple.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
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
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Regd No field
                        _buildTextField(
                          controller: _regdController,
                          label: 'Registration Number',
                          icon: Icons.badge_outlined,
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
                            onChanged: (val) => setState(() => _selectedGroup = val),
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
                                  onChanged: (val) => setState(() => _selectedSection = val),
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
                                  onChanged: (val) => setState(() => _selectedYear = val),
                                ),
                              ),
                            ],
                          ),
                        ],
                        
                        const SizedBox(height: 28),
                        
                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isLogin ? Colors.cyanAccent : Colors.purple,
                              foregroundColor: _isLogin ? Colors.black : Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 8,
                              shadowColor: (_isLogin ? Colors.cyanAccent : Colors.purple).withOpacity(0.5),
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
                          ),
                        ),
                      ],
                    ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
        prefixIcon: Icon(icon, color: Colors.cyanAccent),
        filled: true,
        fillColor: Colors.black.withOpacity(0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.cyanAccent, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.cyanAccent.withOpacity(0.3)),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String label,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
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
        prefixIcon: Icon(icon, color: Colors.purple),
        filled: true,
        fillColor: Colors.black.withOpacity(0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.purple.withOpacity(0.3)),
        ),
      ),
    );
  }
}
