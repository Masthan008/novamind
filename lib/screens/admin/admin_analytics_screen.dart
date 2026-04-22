import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/admin_service.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});
  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  Map<String, dynamic> _analytics = {};
  List<Map<String, dynamic>> _recentSignups = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final analytics = await AdminService.getPlatformAnalytics();
    final signups = await AdminService.getRecentSignups();
    if (mounted) setState(() { _analytics = analytics; _recentSignups = signups; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        title: Text('Analytics', style: GoogleFonts.orbitron(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 18)),
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
                  // User Distribution Chart
                  _sectionTitle('User Distribution'),
                  const SizedBox(height: 12),
                  _buildUserChart(),
                  const SizedBox(height: 28),

                  // Revenue Overview
                  _sectionTitle('Revenue Overview'),
                  const SizedBox(height: 12),
                  _buildRevenueCards(),
                  const SizedBox(height: 28),

                  // Feature Usage
                  _sectionTitle('Top Features'),
                  const SizedBox(height: 12),
                  _buildFeatureUsage(),
                  const SizedBox(height: 28),

                  // Recent Signups
                  _sectionTitle('Recent Signups'),
                  const SizedBox(height: 12),
                  ..._recentSignups.take(10).map((s) => _signupTile(s)),

                  const SizedBox(height: 40),
                ]),
              ),
            ),
    );
  }

  Widget _sectionTitle(String t) =>
      Text(t, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)).animate().fadeIn();

  Widget _buildUserChart() {
    final total = (_analytics['total_users'] ?? 1) as int;
    final pro = (_analytics['pro_users'] ?? 0) as int;
    final ultra = (_analytics['ultra_users'] ?? 0) as int;
    final free = total - pro - ultra;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: SizedBox(
        height: 200,
        child: Row(
          children: [
            Expanded(
              child: PieChart(PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                sections: [
                  PieChartSectionData(value: free.toDouble(), color: Colors.grey, title: 'Free\n$free', titleStyle: GoogleFonts.poppins(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600), radius: 50),
                  PieChartSectionData(value: pro.toDouble(), color: Colors.amber, title: 'Pro\n$pro', titleStyle: GoogleFonts.poppins(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600), radius: 50),
                  PieChartSectionData(value: ultra.toDouble(), color: Colors.purple, title: 'Ultra\n$ultra', titleStyle: GoogleFonts.poppins(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600), radius: 50),
                ],
              )),
            ),
            Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
              _legendDot('Free', Colors.grey, free),
              _legendDot('Pro', Colors.amber, pro),
              _legendDot('Ultra', Colors.purple, ultra),
            ]),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _legendDot(String label, Color color, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text('$label ($count)', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
      ]),
    );
  }

  Widget _buildRevenueCards() {
    final pro = (_analytics['pro_users'] ?? 0) as int;
    final ultra = (_analytics['ultra_users'] ?? 0) as int;
    final revenue = (pro * 199) + (ultra * 499);

    return Row(children: [
      Expanded(child: _revenueCard('Monthly Revenue', '₹$revenue', Colors.greenAccent)),
      const SizedBox(width: 12),
      Expanded(child: _revenueCard('Yearly Estimate', '₹${revenue * 12}', Colors.blueAccent)),
    ]);
  }

  Widget _revenueCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.15), color.withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11)),
      ]),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildFeatureUsage() {
    final features = [
      {'name': 'Timetable', 'usage': 0.92, 'color': Colors.cyanAccent},
      {'name': 'Nova AI', 'usage': 0.78, 'color': Colors.pinkAccent},
      {'name': 'Quiz Arena', 'usage': 0.65, 'color': Colors.amber},
      {'name': 'SkillProof', 'usage': 0.54, 'color': Colors.greenAccent},
      {'name': 'MicroDegrees', 'usage': 0.42, 'color': Colors.tealAccent},
    ];
    return Column(children: features.map((f) => _featureBar(f)).toList());
  }

  Widget _featureBar(Map<String, dynamic> f) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        SizedBox(width: 90, child: Text(f['name'] as String, style: GoogleFonts.poppins(color: Colors.grey.shade300, fontSize: 12))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: f['usage'] as double,
              backgroundColor: Colors.white.withOpacity(0.08),
              color: f['color'] as Color,
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('${((f['usage'] as double) * 100).toInt()}%', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11)),
      ]),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _signupTile(Map<String, dynamic> s) {
    final tier = s['subscription_tier'] ?? 'free';
    final color = tier == 'ultra' ? Colors.purple : tier == 'pro' ? Colors.amber : Colors.grey;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        CircleAvatar(radius: 16, backgroundColor: color.withOpacity(0.2), child: Icon(Icons.person, color: color, size: 16)),
        const SizedBox(width: 12),
        Expanded(child: Text(s['name'] ?? 'Student', style: GoogleFonts.poppins(color: Colors.white, fontSize: 13))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
          child: Text(tier.toString().toUpperCase(), style: GoogleFonts.poppins(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }
}
