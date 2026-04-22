import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/admin_service.dart';

class AdminOpportunitiesScreen extends StatefulWidget {
  const AdminOpportunitiesScreen({super.key});
  @override
  State<AdminOpportunitiesScreen> createState() => _AdminOpportunitiesScreenState();
}

class _AdminOpportunitiesScreenState extends State<AdminOpportunitiesScreen> {
  List<Map<String, dynamic>> _opportunities = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final data = await AdminService.getAllOpportunities();
    if (mounted) setState(() { _opportunities = data; _loading = false; });
  }

  void _showAddDialog() {
    final titleC = TextEditingController();
    final typeC = TextEditingController(text: 'hackathon');
    final deadlineC = TextEditingController();
    final descC = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Add Opportunity', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          _field(titleC, 'Title'),
          const SizedBox(height: 10),
          _field(typeC, 'Type (hackathon/internship/scholarship)'),
          const SizedBox(height: 10),
          _field(deadlineC, 'Deadline (YYYY-MM-DD)'),
          const SizedBox(height: 10),
          _field(descC, 'Description', maxLines: 3),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
            onPressed: () async {
              if (titleC.text.isEmpty) return;
              Navigator.pop(ctx);
              await AdminService.addOpportunity({
                'title': titleC.text,
                'type': typeC.text,
                'deadline': deadlineC.text,
                'description': descC.text,
                'is_active': true,
              });
              _load();
            },
            child: Text('Add', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          )),
        ]),
      ),
    );
  }

  Widget _field(TextEditingController c, String hint, {int maxLines = 1}) {
    return TextField(
      controller: c, maxLines: maxLines,
      style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint, hintStyle: GoogleFonts.poppins(color: Colors.grey),
        filled: true, fillColor: Colors.white.withOpacity(0.08),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        title: Text('Opportunities', style: GoogleFonts.orbitron(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white70), onPressed: () => Navigator.pop(context)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orangeAccent,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: _showAddDialog,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.orangeAccent))
          : _opportunities.isEmpty
              ? Center(child: Text('No opportunities yet', style: GoogleFonts.poppins(color: Colors.grey)))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _opportunities.length,
                    itemBuilder: (ctx, i) {
                      final o = _opportunities[i];
                      final active = o['is_active'] == true;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: (active ? Colors.orangeAccent : Colors.grey).withOpacity(0.2)),
                        ),
                        child: Row(children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.orangeAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                            child: Icon(Icons.emoji_events, color: active ? Colors.orangeAccent : Colors.grey, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(o['title'] ?? '', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                            Text('${o['type'] ?? ''} • ${o['deadline'] ?? ''}', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11)),
                          ])),
                          IconButton(
                            icon: Icon(active ? Icons.visibility_off : Icons.visibility, color: Colors.grey, size: 20),
                            onPressed: () async {
                              HapticFeedback.lightImpact();
                              await AdminService.updateOpportunity(o['id'].toString(), {'is_active': !active});
                              _load();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                            onPressed: () async {
                              HapticFeedback.mediumImpact();
                              await AdminService.deleteOpportunity(o['id'].toString());
                              _load();
                            },
                          ),
                        ]),
                      ).animate().fadeIn().slideX(begin: 0.03);
                    },
                  ),
                ),
    );
  }
}
