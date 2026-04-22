import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/college_service.dart';

class TpoAnalyticsScreen extends StatefulWidget {
  final int collegeId;
  const TpoAnalyticsScreen({super.key, required this.collegeId});
  @override
  State<TpoAnalyticsScreen> createState() => _TpoAnalyticsScreenState();
}

class _TpoAnalyticsScreenState extends State<TpoAnalyticsScreen> {
  Map<String, dynamic> _analytics = {};
  List<Map<String, dynamic>> _topStudents = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final analytics = await CollegeService.getCollegeAnalytics(widget.collegeId);
    final top = await CollegeService.getTopStudents(widget.collegeId);
    if (mounted) setState(() { _analytics = analytics; _topStudents = top; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        title: Text('TPO Analytics', style: GoogleFonts.orbitron(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white70), onPressed: () => Navigator.pop(context)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Stats Grid
                  GridView.count(
                    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.5,
                    children: [
                      _statCard('Students', '${_analytics['total_students'] ?? 0}', Icons.people, Colors.cyanAccent),
                      _statCard('SkillProof', '${_analytics['skillproof_rate'] ?? 0}%', Icons.verified, Colors.amber),
                      _statCard('Placement Ready', '${_analytics['placement_readiness'] ?? 0}%', Icons.work, Colors.greenAccent),
                      _statCard('Avg CGPA', '${_analytics['avg_cgpa'] ?? 0}', Icons.calculate, Colors.purpleAccent),
                      _statCard('MicroDegrees', '${_analytics['microdegree_completions'] ?? 0}', Icons.school, Colors.tealAccent),
                      _statCard('Applications', '${_analytics['active_applications'] ?? 0}', Icons.send, Colors.orangeAccent),
                    ],
                  ).animate().fadeIn(),

                  const SizedBox(height: 28),
                  Text('Top Skilled Students', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 12),

                  if (_topStudents.isEmpty)
                    Center(child: Padding(padding: const EdgeInsets.all(20), child: Text('No student data yet', style: GoogleFonts.poppins(color: Colors.grey))))
                  else
                    ...List.generate(_topStudents.length, (i) {
                      final s = _topStudents[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(12)),
                        child: Row(children: [
                          Container(width: 28, height: 28, decoration: BoxDecoration(
                            gradient: LinearGradient(colors: i < 3 ? [Colors.amber, Colors.orange] : [Colors.grey.shade600, Colors.grey.shade800]),
                            shape: BoxShape.circle,
                          ), child: Center(child: Text('${i + 1}', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)))),
                          const SizedBox(width: 12),
                          Expanded(child: Text(s['name'] ?? 'Student', style: GoogleFonts.poppins(color: Colors.white, fontSize: 13))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: Colors.cyanAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                            child: Text((s['subscription_tier'] ?? 'free').toString().toUpperCase(), style: GoogleFonts.poppins(color: Colors.cyanAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                        ]),
                      ).animate().fadeIn(delay: Duration(milliseconds: 300 + i * 50));
                    }),

                  const SizedBox(height: 28),
                  SizedBox(width: double.infinity, child: OutlinedButton.icon(
                    icon: const Icon(Icons.file_download, size: 18),
                    label: Text('Export PDF Report', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.blueAccent, side: BorderSide(color: Colors.blueAccent.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📄 PDF export coming soon!')));
                    },
                  )).animate().fadeIn(delay: 500.ms),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.15), color.withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 20),
        const Spacer(),
        Text(value, style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11)),
      ]),
    );
  }
}
