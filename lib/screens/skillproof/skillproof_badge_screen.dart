import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SkillProofBadgeScreen extends StatelessWidget {
  final String skillName;
  final int score;
  final int timeTakenSeconds;

  const SkillProofBadgeScreen({
    super.key,
    required this.skillName,
    required this.score,
    required this.timeTakenSeconds,
  });

  String _formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get _badgeLevel {
    if (score >= 90) return 'Platinum';
    if (score >= 75) return 'Gold';
    if (score >= 50) return 'Silver';
    if (score >= 30) return 'Bronze';
    return 'Participant';
  }

  Color get _badgeColor {
    if (score >= 90) return const Color(0xFFE5E4E2);
    if (score >= 75) return Colors.amber;
    if (score >= 50) return Colors.grey.shade400;
    if (score >= 30) return const Color(0xFFCD7F32);
    return Colors.white38;
  }

  IconData get _badgeIcon {
    if (score >= 75) return Icons.emoji_events;
    if (score >= 50) return Icons.military_tech;
    if (score >= 30) return Icons.workspace_premium;
    return Icons.card_membership;
  }

  @override
  Widget build(BuildContext context) {
    final passed = score >= 50;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _badgeColor.withOpacity(0.4),
                        _badgeColor.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                    border: Border.all(color: _badgeColor.withOpacity(0.6), width: 3),
                  ),
                  child: Icon(_badgeIcon, size: 56, color: _badgeColor),
                ),
                const SizedBox(height: 24),
                Text(
                  _badgeLevel,
                  style: GoogleFonts.orbitron(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _badgeColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  skillName,
                  style: GoogleFonts.poppins(fontSize: 18, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _badgeColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$score%',
                        style: GoogleFonts.orbitron(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: passed ? Colors.greenAccent : Colors.redAccent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        passed ? 'PASSED' : 'FAILED',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: passed ? Colors.greenAccent : Colors.redAccent,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.timer_outlined, color: Colors.white54, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Time: ${_formatTime(timeTakenSeconds)}',
                            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      'Done',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
