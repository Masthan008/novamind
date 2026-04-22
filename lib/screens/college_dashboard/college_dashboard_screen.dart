import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/college_service.dart';
import 'college_register_screen.dart';
import 'tpo_analytics_screen.dart';
import 'batch_skills_screen.dart';

class CollegeDashboardScreen extends StatefulWidget {
  const CollegeDashboardScreen({super.key});
  @override
  State<CollegeDashboardScreen> createState() => _CollegeDashboardScreenState();
}

class _CollegeDashboardScreenState extends State<CollegeDashboardScreen> {
  Map<String, dynamic>? _college;
  bool _loading = true;
  final _codeController = TextEditingController();

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _codeController.dispose(); super.dispose(); }

  Future<void> _load() async {
    final college = await CollegeService.getStudentCollege();
    if (mounted) setState(() { _college = college; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        title: Text('College Hub', style: GoogleFonts.orbitron(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 20)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white70), onPressed: () => Navigator.pop(context)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.greenAccent))
          : _college == null
              ? _buildJoinOrRegister()
              : _buildDashboard(),
    );
  }

  Widget _buildJoinOrRegister() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        Icon(Icons.account_balance, color: Colors.greenAccent.withOpacity(0.3), size: 80).animate().scale(delay: 100.ms, duration: 600.ms),
        const SizedBox(height: 16),
        Text('Join Your College', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20)).animate().fadeIn(),
        const SizedBox(height: 8),
        Text('Enter your college access code or register a new college', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13), textAlign: TextAlign.center).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 32),

        // Join with code
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.greenAccent.withOpacity(0.2)),
          ),
          child: Column(children: [
            TextField(
              controller: _codeController,
              style: GoogleFonts.orbitron(color: Colors.white, fontSize: 20, letterSpacing: 4),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'ACCESS CODE', hintStyle: GoogleFonts.orbitron(color: Colors.grey.shade700, fontSize: 16),
                filled: true, fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(width: double.infinity, child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              onPressed: () async {
                if (_codeController.text.isEmpty) return;
                final r = await CollegeService.joinCollege(_codeController.text);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(r.success ? '🎉 Joined successfully!' : r.error ?? 'Error', style: GoogleFonts.poppins(fontSize: 13)),
                    backgroundColor: r.success ? Colors.green.shade700 : Colors.red.shade700,
                  ));
                  if (r.success) _load();
                }
              },
              child: Text('Join College', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            )),
          ]),
        ).animate().fadeIn(delay: 200.ms),

        const SizedBox(height: 24),
        Text('OR', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 16),

        OutlinedButton.icon(
          icon: const Icon(Icons.add_business, size: 18),
          label: Text('Register Your College', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(foregroundColor: Colors.greenAccent, side: BorderSide(color: Colors.greenAccent.withOpacity(0.5)),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CollegeRegisterScreen())),
        ).animate().fadeIn(delay: 300.ms),
      ]),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // College Info Card
        Container(
          width: double.infinity, padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.greenAccent.withOpacity(0.15), Colors.greenAccent.withOpacity(0.05)]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.account_balance, color: Colors.greenAccent, size: 28),
              const SizedBox(width: 12),
              Expanded(child: Text(_college!['name'] ?? '', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
            ]),
            const SizedBox(height: 8),
            Text('${_college!['location'] ?? ''} • ${_college!['university'] ?? ''}', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
            Text('Access Code: ${_college!['access_code'] ?? 'N/A'}', style: GoogleFonts.orbitron(color: Colors.greenAccent.withOpacity(0.7), fontSize: 12, letterSpacing: 2)),
          ]),
        ).animate().fadeIn().slideY(begin: -0.05),

        const SizedBox(height: 24),

        // Navigation Tiles
        _dashTile('TPO Analytics', 'Placement stats & insights', Icons.analytics, Colors.blueAccent,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => TpoAnalyticsScreen(collegeId: _college!['id'] as int)))),
        _dashTile('Batch Skills', 'Skill heatmap & distribution', Icons.insights, Colors.orangeAccent,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => BatchSkillsScreen(collegeId: _college!['id'] as int)))),

        const SizedBox(height: 40),
      ]),
    );
  }

  Widget _dashTile(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16), onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.2))),
            child: Row(children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                Text(subtitle, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
              ])),
              Icon(Icons.arrow_forward_ios, color: color.withOpacity(0.5), size: 16),
            ]),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.05);
  }
}
