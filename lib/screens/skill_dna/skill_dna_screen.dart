import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/student_auth_service.dart';

class SkillDnaScreen extends StatefulWidget {
  const SkillDnaScreen({super.key});
  @override
  State<SkillDnaScreen> createState() => _SkillDnaScreenState();
}

class _SkillDnaScreenState extends State<SkillDnaScreen> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(duration: const Duration(seconds: 3), vsync: this)..repeat(reverse: true);
    _load();
  }

  @override
  void dispose() { _pulseController.dispose(); super.dispose(); }

  Future<void> _load() async {
    try {
      final student = StudentAuthService.currentStudent;
      if (student != null) {
        final data = await Supabase.instance.client.from('skill_dna_profiles').select().eq('student_id', student.id.toString()).maybeSingle();
        _profile = data ?? _fallbackProfile;
      } else { _profile = _fallbackProfile; }
    } catch (e) { _profile = _fallbackProfile; }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0,
        title: Text('Skill DNA', style: GoogleFonts.orbitron(color: const Color(0xFF6C63FF), fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white70), onPressed: () => Navigator.pop(context))),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
              // DNA Score Card
              AnimatedBuilder(
                animation: _pulseController,
                builder: (_, child) => Container(
                  width: double.infinity, padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(radius: 1.5, colors: [
                      const Color(0xFF6C63FF).withOpacity(0.2 + _pulseController.value * 0.1),
                      const Color(0xFF0A0A0F),
                    ]),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
                  ),
                  child: child,
                ),
                child: Column(children: [
                  Text('YOUR SKILL DNA', style: GoogleFonts.orbitron(color: const Color(0xFF6C63FF), fontSize: 12, letterSpacing: 3)),
                  const SizedBox(height: 16),
                  Text('${_profile?['overall_score'] ?? 0}', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 56, fontWeight: FontWeight.bold)),
                  Text('Overall Score', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: const Color(0xFF6C63FF).withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                    child: Text(_profile?['learning_style'] ?? 'Visual Learner', style: GoogleFonts.poppins(color: const Color(0xFF6C63FF), fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ]),
              ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
              const SizedBox(height: 24),

              // Peak Hours
              _sectionCard('⏰ Peak Study Hours', Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ...(_profile?['peak_hours'] as List? ?? ['9 PM - 11 PM', '6 AM - 8 AM']).map((h) =>
                  Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [
                    Icon(Icons.access_time, color: Colors.amber, size: 16),
                    const SizedBox(width: 8),
                    Text(h.toString(), style: GoogleFonts.poppins(color: Colors.white, fontSize: 13)),
                  ]))),
              ])),
              const SizedBox(height: 12),

              // Strong Subjects
              _sectionCard('💪 Strong Subjects', Wrap(spacing: 8, runSpacing: 8,
                children: (_profile?['strong_subjects'] as List? ?? ['Python', 'SQL', 'JavaScript']).map((s) =>
                  Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                    child: Text(s.toString(), style: GoogleFonts.poppins(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.w600)))).toList(),
              )),
              const SizedBox(height: 12),

              // Weak Subjects
              _sectionCard('🎯 Areas to Improve', Wrap(spacing: 8, runSpacing: 8,
                children: (_profile?['weak_subjects'] as List? ?? ['System Design', 'DevOps']).map((s) =>
                  Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                    child: Text(s.toString(), style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w600)))).toList(),
              )),

              const SizedBox(height: 24),

              // Radar Chart (simplified)
              _sectionCard('📊 Skill Radar', SizedBox(
                height: 200,
                child: CustomPaint(painter: _RadarPainter(), size: const Size(200, 200)),
              )),

              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: OutlinedButton.icon(
                icon: const Icon(Icons.share, size: 18),
                label: Text('Share Skill DNA Card', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF6C63FF), side: BorderSide(color: const Color(0xFF6C63FF).withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📤 Sharing coming soon!'))),
              )).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 40),
            ])),
    );
  }

  Widget _sectionCard(String title, Widget child) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.08))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 12),
        child,
      ]),
    ).animate().fadeIn(delay: 200.ms);
  }

  static final _fallbackProfile = {
    'overall_score': 72,
    'learning_style': 'Visual Learner',
    'peak_hours': ['9 PM - 11 PM', '6 AM - 8 AM'],
    'strong_subjects': ['Python', 'SQL', 'Data Structures'],
    'weak_subjects': ['System Design', 'DevOps', 'ML'],
  };
}

class _RadarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;
    final skills = ['DSA', 'Web', 'ML', 'DB', 'DevOps', 'Mobile'];
    final values = [0.8, 0.6, 0.4, 0.7, 0.3, 0.5];
    final n = skills.length;

    // Draw grid
    for (int ring = 1; ring <= 4; ring++) {
      final r = radius * ring / 4;
      final path = Path();
      for (int i = 0; i <= n; i++) {
        final angle = -pi / 2 + (2 * pi * (i % n) / n);
        final p = Offset(center.dx + r * cos(angle), center.dy + r * sin(angle));
        if (i == 0) path.moveTo(p.dx, p.dy); else path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, Paint()..color = Colors.white.withOpacity(0.08)..style = PaintingStyle.stroke);
    }

    // Draw data
    final dataPath = Path();
    for (int i = 0; i <= n; i++) {
      final angle = -pi / 2 + (2 * pi * (i % n) / n);
      final r = radius * values[i % n];
      final p = Offset(center.dx + r * cos(angle), center.dy + r * sin(angle));
      if (i == 0) dataPath.moveTo(p.dx, p.dy); else dataPath.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(dataPath, Paint()..color = const Color(0xFF6C63FF).withOpacity(0.3)..style = PaintingStyle.fill);
    canvas.drawPath(dataPath, Paint()..color = const Color(0xFF6C63FF)..style = PaintingStyle.stroke..strokeWidth = 2);

    // Draw labels
    for (int i = 0; i < n; i++) {
      final angle = -pi / 2 + (2 * pi * i / n);
      final p = Offset(center.dx + (radius + 16) * cos(angle), center.dy + (radius + 16) * sin(angle));
      final tp = TextPainter(text: TextSpan(text: skills[i], style: const TextStyle(color: Colors.grey, fontSize: 10)), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(p.dx - tp.width / 2, p.dy - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
