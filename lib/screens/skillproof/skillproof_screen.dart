import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../../widgets/glass_container.dart';
import '../../services/skillproof_service.dart';
import 'skillproof_exam_screen.dart';

class SkillProofScreen extends StatefulWidget {
  const SkillProofScreen({super.key});

  @override
  State<SkillProofScreen> createState() => _SkillProofScreenState();
}

class _SkillProofScreenState extends State<SkillProofScreen> {
  bool _isLoading = true;
  final Map<String, bool> _cooldowns = {};

  final List<Map<String, dynamic>> _assessments = [
    {'name': 'Python Basics', 'category': 'Programming', 'difficulty': 'Beginner'},
    {'name': 'JavaScript Basics', 'category': 'Programming', 'difficulty': 'Beginner'},
    {'name': 'HTML/CSS', 'category': 'Web Dev', 'difficulty': 'Beginner'},
    {'name': 'DSA Fundamentals', 'category': 'Computer Science', 'difficulty': 'Intermediate'},
    {'name': 'SQL Basics', 'category': 'Database', 'difficulty': 'Beginner'},
    {'name': 'Git Basics', 'category': 'Tools', 'difficulty': 'Beginner'},
    {'name': 'Flutter Basics', 'category': 'Mobile Dev', 'difficulty': 'Intermediate'},
    {'name': 'Prompt Engineering', 'category': 'AI', 'difficulty': 'Beginner'},
    {'name': 'Web Dev Basics', 'category': 'Web Dev', 'difficulty': 'Beginner'},
    {'name': 'Linux Basics', 'category': 'OS', 'difficulty': 'Beginner'},
  ];

  @override
  void initState() {
    super.initState();
    _loadCooldowns();
  }

  Future<void> _loadCooldowns() async {
    for (var a in _assessments) {
      final name = a['name'] as String;
      _cooldowns[name] = await SkillProofService.isOnCooldown(name);
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _startAssessment(String skillName) {
    if (_cooldowns[skillName] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You are on a 24-hour cooldown for $skillName. Try again later.'),
          backgroundColor: Colors.redAccent,
        )
      );
      return;
    }
    
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SkillProofExamScreen(skillName: skillName)),
    ).then((_) => _loadCooldowns()); // Reload cooldowns when returning
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(colors: [Colors.amber, Colors.orangeAccent]).createShader(bounds),
          child: Text('SkillProof', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.amber))
        : RefreshIndicator(
            onRefresh: _loadCooldowns,
            color: Colors.black,
            backgroundColor: Colors.amber,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _assessments.length,
              itemBuilder: (context, index) {
                final assessment = _assessments[index];
                final onCooldown = _cooldowns[assessment['name']] ?? false;

                return GlassContainer(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  borderRadius: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              assessment['category'],
                              style: GoogleFonts.poppins(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              assessment['difficulty'],
                              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        assessment['name'],
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildMetadataPoint(Icons.help_outline, '20 Questions'),
                          const SizedBox(width: 16),
                          _buildMetadataPoint(Icons.timer_outlined, '15 Minutes'),
                          const SizedBox(width: 16),
                          _buildMetadataPoint(Icons.sports_score, '80% to Pass'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onCooldown ? null : () => _startAssessment(assessment['name']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                            disabledBackgroundColor: Colors.white12,
                            disabledForegroundColor: Colors.white38,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(onCooldown ? Icons.lock_clock : Icons.play_arrow, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                onCooldown ? 'On Cooldown (24h)' : 'Start Assessment',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
    );
  }

  Widget _buildMetadataPoint(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white54),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11)),
      ],
    );
  }
}
