import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/college_service.dart';

class BatchSkillsScreen extends StatefulWidget {
  final int collegeId;
  const BatchSkillsScreen({super.key, required this.collegeId});
  @override
  State<BatchSkillsScreen> createState() => _BatchSkillsScreenState();
}

class _BatchSkillsScreenState extends State<BatchSkillsScreen> {
  List<Map<String, dynamic>> _skills = [];
  bool _loading = true;
  String _filterBranch = 'All';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final skills = await CollegeService.getBatchSkills(widget.collegeId);
    if (mounted) setState(() { _skills = skills; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        title: Text('Batch Skills', style: GoogleFonts.orbitron(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white70), onPressed: () => Navigator.pop(context)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.orangeAccent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Filter Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: ['All', 'CSE', 'ECE', 'EEE', 'ME', 'CE'].map((b) =>
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(b, style: GoogleFonts.poppins(fontSize: 12)),
                        selected: _filterBranch == b,
                        selectedColor: Colors.orangeAccent,
                        backgroundColor: Colors.white.withOpacity(0.08),
                        labelStyle: TextStyle(color: _filterBranch == b ? Colors.black : Colors.white),
                        onSelected: (_) => setState(() => _filterBranch = b),
                      ),
                    ),
                  ).toList()),
                ).animate().fadeIn(),

                const SizedBox(height: 24),
                Text('Skill Distribution Heatmap', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 16),

                // Heatmap Grid
                ..._skills.asMap().entries.map((entry) {
                  final i = entry.key;
                  final s = entry.value;
                  final proficiency = (s['proficiency'] as num).toDouble();
                  final color = proficiency > 0.7 ? Colors.greenAccent : proficiency > 0.5 ? Colors.amber : proficiency > 0.3 ? Colors.orangeAccent : Colors.redAccent;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
                        stops: [0, proficiency.clamp(0.1, 1.0)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Row(children: [
                      SizedBox(width: 100, child: Text(s['skill'] ?? '', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13))),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: proficiency,
                            backgroundColor: Colors.white.withOpacity(0.08),
                            color: color,
                            minHeight: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('${(proficiency * 100).toInt()}%', style: GoogleFonts.orbitron(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Text('${s['students']}', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 10)),
                      const Icon(Icons.person, color: Colors.grey, size: 12),
                    ]),
                  ).animate().fadeIn(delay: Duration(milliseconds: 200 + i * 60)).slideX(begin: 0.03);
                }),

                const SizedBox(height: 28),
                // Insights
                Container(
                  width: double.infinity, padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Icon(Icons.warning_amber, color: Colors.redAccent, size: 20),
                      const SizedBox(width: 8),
                      Text('Weakest Skills', style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.w600, fontSize: 14)),
                    ]),
                    const SizedBox(height: 8),
                    ..._skills.where((s) => (s['proficiency'] as num) < 0.4).map((s) =>
                      Text('• ${s['skill']} — needs more training', style: GoogleFonts.poppins(color: Colors.grey.shade300, fontSize: 12)),
                    ),
                  ]),
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 40),
              ]),
            ),
    );
  }
}
