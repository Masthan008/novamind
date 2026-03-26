import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/skill_gap_service.dart';
import '../../widgets/glass_container.dart';

/// Skill Gap Analyzer — 3-step wizard: Role → Skills → Analysis
class SkillGapScreen extends StatefulWidget {
  const SkillGapScreen({super.key});

  @override
  State<SkillGapScreen> createState() => _SkillGapScreenState();
}

class _SkillGapScreenState extends State<SkillGapScreen> {
  int _step = 0; // 0=role, 1=skills, 2=result
  String? _selectedRole;
  Set<String> _selectedSkills = {};
  Map<String, dynamic>? _analysisResult;

  void _selectRole(String role) {
    HapticFeedback.lightImpact();
    setState(() { _selectedRole = role; _step = 1; });
  }

  bool _isAnalyzing = false;

  Future<void> _analyze() async {
    if (_selectedRole == null) return;
    HapticFeedback.mediumImpact();
    setState(() { _isAnalyzing = true; });
    final result = await SkillGapService.analyzeGap(
      targetRole: _selectedRole!,
      currentSkills: _selectedSkills.toList(),
    );
    if (mounted) {
      setState(() { _analysisResult = result; _step = 2; _isAnalyzing = false; });
    }
  }

  void _reset() {
    setState(() { _step = 0; _selectedRole = null; _selectedSkills = {}; _analysisResult = null; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
          onPressed: _step > 0 ? () => setState(() => _step--) : () => Navigator.pop(context),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(colors: [Colors.purpleAccent, Colors.cyanAccent]).createShader(bounds),
          child: Text('Skill Gap Analyzer', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        actions: [
          if (_step == 2) IconButton(icon: const Icon(Icons.refresh, color: Colors.cyanAccent), onPressed: _reset),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _step == 0 ? _buildRoleStep() : _step == 1 ? _buildSkillsStep() : _buildResultStep(),
      ),
    );
  }

  Widget _buildRoleStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choose Your Target Role', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('What do you want to become?', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 16),
          ...SkillGapService.roleSkills.keys.map((role) => InkWell(
            onTap: () => _selectRole(role),
            borderRadius: BorderRadius.circular(14),
            child: GlassContainer(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              borderRadius: 14,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.purpleAccent.withOpacity(0.3), Colors.cyanAccent.withOpacity(0.2)]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_roleIcon(role), color: Colors.cyanAccent, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(role, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                      Text('${SkillGapService.roleSkills[role]?.length ?? 0} skills required',
                        style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11)),
                    ]),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSkillsStep() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Your Current Skills', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            Text('Select all skills you currently have', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 4),
            Text('${_selectedSkills.length} selected', style: GoogleFonts.poppins(color: Colors.cyanAccent, fontSize: 12)),
          ]),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 6, runSpacing: 6,
              children: SkillGapService.allSkills.map((skill) {
                final selected = _selectedSkills.contains(skill);
                return FilterChip(
                  label: Text(skill, style: TextStyle(color: selected ? Colors.black : Colors.white70, fontSize: 12)),
                  selected: selected,
                  selectedColor: Colors.cyanAccent,
                  backgroundColor: Colors.white.withOpacity(0.08),
                  checkmarkColor: Colors.black,
                  onSelected: (_) => setState(() {
                    selected ? _selectedSkills.remove(skill) : _selectedSkills.add(skill);
                  }),
                );
              }).toList(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _analyze,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _isAnalyzing 
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                : Text('Analyze Gap', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultStep() {
    if (_analysisResult == null) return const SizedBox();
    final result = _analysisResult!;
    final readiness = result['readinessPercent'] as double;
    final matched = List<String>.from(result['matchedSkills'] ?? []);
    final missing = List<String>.from(result['missingSkills'] ?? []);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Readiness gauge
          GlassContainer(
            padding: const EdgeInsets.all(24),
            borderRadius: 16,
            child: Column(children: [
              Text(result['targetRole'] ?? '', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                width: 140, height: 140,
                child: Stack(alignment: Alignment.center, children: [
                  SizedBox(
                    width: 140, height: 140,
                    child: CircularProgressIndicator(
                      value: readiness / 100,
                      strokeWidth: 12,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        readiness >= 75 ? Colors.greenAccent : readiness >= 50 ? Colors.amberAccent : Colors.redAccent,
                      ),
                    ),
                  ),
                  Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('${readiness.toStringAsFixed(0)}%',
                      style: GoogleFonts.orbitron(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    Text('Ready', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
                  ]),
                ]),
              ),
              const SizedBox(height: 16),
              Text(
                readiness >= 75 ? '🎉 Almost there!' : readiness >= 50 ? '💪 Good progress!' : '🚀 Time to learn!',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          // Matched skills
          if (matched.isNotEmpty) ...[
            _buildSkillSection('Skills You Have ✅', matched, Colors.greenAccent),
            const SizedBox(height: 12),
          ],

          // Missing skills
          if (missing.isNotEmpty) ...[
            _buildSkillSection('Skills to Learn 📚', missing, Colors.redAccent),
          ],
        ],
      ),
    );
  }

  Widget _buildSkillSection(String title, List<String> skills, Color color) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 14,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 10),
        Wrap(spacing: 6, runSpacing: 6, children: skills.map((s) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3))),
          child: Text(s, style: GoogleFonts.poppins(color: color, fontSize: 12)),
        )).toList()),
      ]),
    );
  }

  IconData _roleIcon(String role) {
    switch (role) {
      case 'Frontend Developer': return Icons.web;
      case 'Backend Developer': return Icons.dns;
      case 'Full-Stack Developer': return Icons.layers;
      case 'Mobile Developer': return Icons.phone_android;
      case 'Data Scientist': return Icons.bar_chart;
      case 'ML Engineer': return Icons.psychology;
      case 'DevOps Engineer': return Icons.cloud;
      case 'Cybersecurity Analyst': return Icons.security;
      case 'UI/UX Designer': return Icons.palette;
      case 'Cloud Architect': return Icons.architecture;
      default: return Icons.work;
    }
  }
}
