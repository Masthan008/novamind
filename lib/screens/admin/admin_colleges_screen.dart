import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/admin_service.dart';

class AdminCollegesScreen extends StatefulWidget {
  const AdminCollegesScreen({super.key});
  @override
  State<AdminCollegesScreen> createState() => _AdminCollegesScreenState();
}

class _AdminCollegesScreenState extends State<AdminCollegesScreen> {
  List<Map<String, dynamic>> _pending = [];
  List<Map<String, dynamic>> _all = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final pending = await AdminService.getPendingColleges();
    final all = await AdminService.getAllColleges();
    if (mounted) setState(() { _pending = pending; _all = all; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        title: Text('Colleges', style: GoogleFonts.orbitron(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white70), onPressed: () => Navigator.pop(context)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.greenAccent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (_pending.isNotEmpty) ...[
                  Text('Pending Approval (${_pending.length})', style: GoogleFonts.poppins(color: Colors.orangeAccent, fontWeight: FontWeight.w600, fontSize: 15)).animate().fadeIn(),
                  const SizedBox(height: 12),
                  ..._pending.map((c) => _collegeCard(c, isPending: true)),
                  const SizedBox(height: 24),
                ],
                Text('All Colleges (${_all.length})', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 12),
                if (_all.isEmpty)
                  Center(child: Padding(padding: const EdgeInsets.all(40), child: Text('No colleges registered yet', style: GoogleFonts.poppins(color: Colors.grey)))),
                ..._all.map((c) => _collegeCard(c)),
                const SizedBox(height: 40),
              ]),
            ),
    );
  }

  Widget _collegeCard(Map<String, dynamic> c, {bool isPending = false}) {
    final approved = c['is_approved'] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: (approved ? Colors.greenAccent : Colors.orangeAccent).withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.account_balance, color: approved ? Colors.greenAccent : Colors.orangeAccent, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c['name'] ?? '', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
            Text('${c['location'] ?? ''} • ${c['university'] ?? ''}', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11)),
          ])),
          if (approved)
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
              child: Text('ACTIVE', style: GoogleFonts.poppins(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold))),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          _infoChip('TPO: ${c['tpo_name'] ?? 'N/A'}'),
          const SizedBox(width: 8),
          _infoChip('Students: ${c['total_students'] ?? 0}'),
          if (approved) ...[
            const SizedBox(width: 8),
            _infoChip('Code: ${c['access_code'] ?? 'N/A'}'),
          ],
        ]),
        if (isPending) ...[
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            icon: const Icon(Icons.check, size: 16),
            label: Text('Approve College', style: GoogleFonts.poppins(fontSize: 12)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              HapticFeedback.mediumImpact();
              await AdminService.approveCollege(c['id'].toString());
              _load();
            },
          )),
        ],
      ]),
    ).animate().fadeIn().slideX(begin: 0.03);
  }

  Widget _infoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: GoogleFonts.poppins(color: Colors.grey.shade300, fontSize: 10)),
    );
  }
}
