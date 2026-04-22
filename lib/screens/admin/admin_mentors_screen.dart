import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/admin_service.dart';

class AdminMentorsScreen extends StatefulWidget {
  const AdminMentorsScreen({super.key});
  @override
  State<AdminMentorsScreen> createState() => _AdminMentorsScreenState();
}

class _AdminMentorsScreenState extends State<AdminMentorsScreen> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _pending = [];
  List<Map<String, dynamic>> _all = [];
  bool _loading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  Future<void> _load() async {
    final pending = await AdminService.getPendingMentors();
    final all = await AdminService.getAllMentors();
    if (mounted) setState(() { _pending = pending; _all = all; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        title: Text('Manage Mentors', style: GoogleFonts.orbitron(color: Colors.tealAccent, fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white70), onPressed: () => Navigator.pop(context)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.tealAccent,
          labelColor: Colors.tealAccent,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(text: 'Pending (${_pending.length})'),
            Tab(text: 'All (${_all.length})'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.tealAccent))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(_pending, isPending: true),
                _buildList(_all),
              ],
            ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> mentors, {bool isPending = false}) {
    if (mentors.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.check_circle, color: Colors.tealAccent.withOpacity(0.3), size: 60),
        const SizedBox(height: 12),
        Text(isPending ? 'No pending applications' : 'No mentors yet', style: GoogleFonts.poppins(color: Colors.grey)),
      ]));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mentors.length,
        itemBuilder: (ctx, i) => _mentorCard(mentors[i], isPending),
      ),
    );
  }

  Widget _mentorCard(Map<String, dynamic> m, bool isPending) {
    final approved = m['is_approved'] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: (approved ? Colors.tealAccent : Colors.orangeAccent).withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 20, backgroundColor: Colors.tealAccent.withOpacity(0.2), child: const Icon(Icons.person, color: Colors.tealAccent, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(m['name'] ?? 'Mentor', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
            Text(m['expertise'] ?? '', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
          ])),
          if (approved)
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
              child: Text('APPROVED', style: GoogleFonts.poppins(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold))),
        ]),
        if (isPending) ...[
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: ElevatedButton.icon(
              icon: const Icon(Icons.check, size: 16),
              label: Text('Approve', style: GoogleFonts.poppins(fontSize: 12)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () async {
                HapticFeedback.mediumImpact();
                await AdminService.approveMentor(m['id'].toString());
                _load();
              },
            )),
            const SizedBox(width: 8),
            Expanded(child: ElevatedButton.icon(
              icon: const Icon(Icons.close, size: 16),
              label: Text('Reject', style: GoogleFonts.poppins(fontSize: 12)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () async {
                HapticFeedback.mediumImpact();
                await AdminService.rejectMentor(m['id'].toString());
                _load();
              },
            )),
          ]),
        ],
      ]),
    ).animate().fadeIn().slideX(begin: 0.03);
  }
}
