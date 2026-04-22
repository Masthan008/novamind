import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/mentor_service.dart';
import '../../widgets/pro_gate.dart';
import 'mentor_profile_screen.dart';

class MentorMarketplaceScreen extends StatefulWidget {
  const MentorMarketplaceScreen({super.key});

  @override
  State<MentorMarketplaceScreen> createState() => _MentorMarketplaceScreenState();
}

class _MentorMarketplaceScreenState extends State<MentorMarketplaceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _mentors = [];
  List<Map<String, dynamic>> _mySessions = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final mentors = await MentorService.getAllMentors();
    final sessions = await MentorService.getMySessions();
    if (mounted) {
      setState(() {
        _mentors = mentors;
        _mySessions = sessions;
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredMentors {
    if (_searchQuery.isEmpty) return _mentors;
    return _mentors.where((m) {
      final name = (m['name'] ?? '').toString().toLowerCase();
      final expertise = (m['expertise'] as List?)?.join(' ').toLowerCase() ?? '';
      final q = _searchQuery.toLowerCase();
      return name.contains(q) || expertise.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ProGate(
      featureName: 'Mentor Marketplace',
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0F),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0A0A0F),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
            onPressed: () => Navigator.pop(context),
          ),
          title: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.orangeAccent, Color(0xFFFFAB40)],
            ).createShader(bounds),
            child: Text('Mentors', style: GoogleFonts.orbitron(
              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.orangeAccent,
            indicatorWeight: 3,
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
            unselectedLabelColor: Colors.grey,
            labelColor: Colors.orangeAccent,
            tabs: const [Tab(text: 'Find Mentors'), Tab(text: 'My Sessions')],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.orangeAccent))
            : TabBarView(controller: _tabController, children: [_buildMentorsTab(), _buildSessionsTab()]),
      ),
    );
  }

  Widget _buildMentorsTab() {
    final filtered = _filteredMentors;
    return Column(
      children: [
        // Search
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search mentors or skills...',
              hintStyle: GoogleFonts.poppins(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(child: Text('No mentors found', style: GoogleFonts.poppins(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) => _buildMentorCard(filtered[i], i),
                ),
        ),
      ],
    );
  }

  Widget _buildMentorCard(Map<String, dynamic> mentor, int index) {
    final name = mentor['name'] ?? 'Mentor';
    final title = mentor['title'] ?? '';
    final rating = (mentor['rating'] ?? 5.0).toDouble();
    final sessions = mentor['total_sessions'] ?? 0;
    final expertise = List<String>.from(mentor['expertise'] ?? []);
    final rate = mentor['rate_per_session'] ?? 0;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => MentorProfileScreen(mentor: mentor)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.orangeAccent.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.orangeAccent.withOpacity(0.3), Colors.deepOrange.withOpacity(0.2)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(child: Text(name.isNotEmpty ? name[0] : 'M',
                style: GoogleFonts.poppins(color: Colors.orangeAccent, fontSize: 24, fontWeight: FontWeight.bold))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(name, style: GoogleFonts.poppins(
                        color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15))),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amberAccent, size: 14),
                          const SizedBox(width: 2),
                          Text(rating.toStringAsFixed(1), style: GoogleFonts.poppins(
                            color: Colors.amberAccent, fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                  Text(title, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 4, runSpacing: 2,
                          children: expertise.take(3).map((e) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orangeAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(e, style: GoogleFonts.poppins(fontSize: 9, color: Colors.orangeAccent)),
                          )).toList(),
                        ),
                      ),
                      Text(rate > 0 ? '₹$rate' : 'Free', style: GoogleFonts.poppins(
                        color: rate > 0 ? Colors.orangeAccent : Colors.greenAccent,
                        fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 80 * index)).slideX(begin: -0.1);
  }

  Widget _buildSessionsTab() {
    if (_mySessions.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey.shade700),
        const SizedBox(height: 16),
        Text('No sessions yet', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16)),
        const SizedBox(height: 8),
        Text('Book a session with a mentor', style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 13)),
      ]));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mySessions.length,
      itemBuilder: (context, i) {
        final session = _mySessions[i];
        final mentorData = session['mentors'] as Map<String, dynamic>?;
        final mentorName = mentorData?['name'] ?? 'Mentor';
        final topic = session['topic'] ?? 'Session';
        final status = session['status'] ?? 'pending';
        final statusColor = status == 'confirmed' ? Colors.greenAccent
            : status == 'completed' ? Colors.blueAccent
            : status == 'cancelled' ? Colors.redAccent
            : Colors.orangeAccent;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: statusColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.person, color: statusColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(mentorName, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                Text(topic, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(status.toUpperCase(), style: GoogleFonts.poppins(
                  color: statusColor, fontSize: 10, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 80 * i));
      },
    );
  }
}
