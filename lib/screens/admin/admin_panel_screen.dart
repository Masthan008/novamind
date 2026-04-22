import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/admin_service.dart';
import 'admin_analytics_screen.dart';
import 'admin_mentors_screen.dart';
import 'admin_opportunities_screen.dart';
import 'admin_colleges_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  bool _isAdmin = false;
  bool _loading = true;
  Map<String, dynamic> _analytics = {};

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    final admin = await AdminService.isAdmin();
    final analytics = await AdminService.getPlatformAnalytics();
    if (mounted) setState(() { _isAdmin = admin; _analytics = analytics; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Admin Panel', style: GoogleFonts.orbitron(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 20)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white70), onPressed: () => Navigator.pop(context)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : !_isAdmin
              ? _buildAccessDenied()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick Stats
                      Text('Platform Overview', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18))
                          .animate().fadeIn(),
                      const SizedBox(height: 16),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.6,
                        children: [
                          _statCard('Total Users', '${_analytics['total_users'] ?? 0}', Icons.people, Colors.cyanAccent),
                          _statCard('Pro Users', '${_analytics['pro_users'] ?? 0}', Icons.star, Colors.amber),
                          _statCard('Ultra Users', '${_analytics['ultra_users'] ?? 0}', Icons.diamond, Colors.purple),
                          _statCard('Mentors', '${_analytics['total_mentors'] ?? 0}', Icons.school, Colors.tealAccent),
                          _statCard('Jobs', '${_analytics['total_jobs'] ?? 0}', Icons.work, Colors.orangeAccent),
                          _statCard('Colleges', '${_analytics['total_colleges'] ?? 0}', Icons.account_balance, Colors.greenAccent),
                        ],
                      ).animate().fadeIn(delay: 100.ms),

                      const SizedBox(height: 32),
                      Text('Management', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18))
                          .animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 16),

                      _managementTile('Analytics Dashboard', 'Revenue, DAU, trends', Icons.analytics, Colors.blueAccent,
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAnalyticsScreen()))),
                      _managementTile('Manage Mentors', 'Approve, reject, suspend', Icons.people_outline, Colors.tealAccent,
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminMentorsScreen()))),
                      _managementTile('Manage Opportunities', 'Add, edit, deactivate', Icons.emoji_events, Colors.orangeAccent,
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminOpportunitiesScreen()))),
                      _managementTile('Manage Colleges', 'Approve registrations', Icons.account_balance, Colors.greenAccent,
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCollegesScreen()))),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
    );
  }

  Widget _buildAccessDenied() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, color: Colors.redAccent.withOpacity(0.5), size: 80),
          const SizedBox(height: 16),
          Text('Access Denied', style: GoogleFonts.orbitron(color: Colors.redAccent, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Admin privileges required', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
        ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const Spacer(),
          Text(value, style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
          Text(label, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _managementTile(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () { HapticFeedback.lightImpact(); onTap(); },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                  Text(subtitle, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                ])),
                Icon(Icons.arrow_forward_ios, color: color.withOpacity(0.5), size: 16),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.05);
  }
}
