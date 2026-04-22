import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/student_auth_service.dart';
import '../../services/college_service.dart';

class ConfessionScreen extends StatefulWidget {
  const ConfessionScreen({super.key});
  @override
  State<ConfessionScreen> createState() => _ConfessionScreenState();
}

class _ConfessionScreenState extends State<ConfessionScreen> {
  List<Map<String, dynamic>> _confessions = [];
  bool _loading = true;
  String _filter = 'All';
  Map<String, dynamic>? _college;
  final _db = Supabase.instance.client;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      _college = await CollegeService.getStudentCollege();
      if (_college != null) {
        final data = await _db.from('confessions').select()
            .eq('college_id', _college!['id']).eq('is_approved', true)
            .order('created_at', ascending: false);
        _confessions = List<Map<String, dynamic>>.from(data);
      } else {
        _confessions = _fallback;
      }
    } catch (e) {
      _confessions = _fallback;
    }
    if (mounted) setState(() => _loading = false);
  }

  void _showPostSheet() {
    final contentC = TextEditingController();
    String cat = 'Confession';

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheetState) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('New Confession', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 4),
          Text('100% anonymous — no one will know 🤫', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11)),
          const SizedBox(height: 16),
          TextField(
            controller: contentC, maxLines: 4, maxLength: 500,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Spill the tea... ☕', hintStyle: GoogleFonts.poppins(color: Colors.grey),
              filled: true, fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              counterStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 10),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: ['Funny', 'Advice', 'Confession', 'Question', 'Appreciation'].map((c) =>
            ChoiceChip(label: Text(c, style: GoogleFonts.poppins(fontSize: 11)), selected: cat == c,
              selectedColor: Colors.deepPurpleAccent, backgroundColor: Colors.white.withOpacity(0.08),
              labelStyle: TextStyle(color: cat == c ? Colors.white : Colors.grey),
              onSelected: (_) => setSheetState(() => cat = c))
          ).toList()),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            onPressed: () async {
              if (contentC.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              try {
                await _db.from('confessions').insert({
                  'college_id': _college?['id'],
                  'content': contentC.text.trim(),
                  'category': cat,
                });
                _load();
              } catch (_) {}
            },
            child: Text('Post Anonymously', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          )),
        ]),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['All', 'Funny', 'Advice', 'Confession', 'Question', 'Appreciation'];
    final filtered = _filter == 'All' ? _confessions : _confessions.where((c) => c['category'] == _filter).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        title: Text('Confessions', style: GoogleFonts.orbitron(color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white70), onPressed: () => Navigator.pop(context)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurpleAccent,
        child: const Icon(Icons.edit, color: Colors.white),
        onPressed: _showPostSheet,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent))
          : Column(children: [
              // Category chips
              SizedBox(height: 42, child: ListView.builder(
                scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(label: Text(categories[i], style: GoogleFonts.poppins(fontSize: 12)), selected: _filter == categories[i],
                    selectedColor: Colors.deepPurpleAccent, backgroundColor: Colors.white.withOpacity(0.08),
                    labelStyle: TextStyle(color: _filter == categories[i] ? Colors.white : Colors.grey),
                    onSelected: (_) => setState(() => _filter = categories[i])),
                ),
              )).animate().fadeIn(),
              const SizedBox(height: 8),
              Expanded(
                child: filtered.isEmpty
                    ? Center(child: Text('No confessions yet', style: GoogleFonts.poppins(color: Colors.grey)))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) => _confessionCard(filtered[i], i),
                        ),
                      ),
              ),
            ]),
    );
  }

  Widget _confessionCard(Map<String, dynamic> c, int index) {
    final cat = c['category'] ?? 'Confession';
    final catColor = cat == 'Funny' ? Colors.amber : cat == 'Advice' ? Colors.greenAccent : cat == 'Question' ? Colors.blueAccent : cat == 'Appreciation' ? Colors.pinkAccent : Colors.deepPurpleAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16),
        border: Border.all(color: catColor.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: catColor.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: Text(cat, style: GoogleFonts.poppins(color: catColor, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const Spacer(),
          Icon(Icons.person_off, color: Colors.grey.shade700, size: 14),
          const SizedBox(width: 4),
          Text('Anonymous', style: GoogleFonts.poppins(color: Colors.grey.shade700, fontSize: 10)),
        ]),
        const SizedBox(height: 10),
        Text(c['content'] ?? '', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9), fontSize: 14, height: 1.5)),
        const SizedBox(height: 12),
        Row(children: [
          GestureDetector(
            onTap: () async {
              HapticFeedback.lightImpact();
              try { await _db.from('confessions').update({'upvotes': (c['upvotes'] ?? 0) + 1}).eq('id', c['id']); _load(); } catch (_) {}
            },
            child: Row(children: [
              Icon(Icons.arrow_upward, color: Colors.deepPurpleAccent, size: 18),
              const SizedBox(width: 4),
              Text('${c['upvotes'] ?? 0}', style: GoogleFonts.poppins(color: Colors.deepPurpleAccent, fontSize: 13, fontWeight: FontWeight.w600)),
            ]),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () async {
              try { await _db.from('confessions').update({'is_reported': true}).eq('id', c['id']); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🚩 Reported'))); } catch (_) {}
            },
            child: Icon(Icons.flag_outlined, color: Colors.grey.shade700, size: 18),
          ),
        ]),
      ]),
    ).animate().fadeIn(delay: Duration(milliseconds: 100 + index * 50)).slideY(begin: 0.03);
  }

  static final _fallback = [
    {'content': 'The library Wi-Fi password is literally the best kept secret on campus 😂', 'category': 'Funny', 'upvotes': 89, 'id': '1'},
    {'content': 'If you\'re struggling with DSA, check out Striver\'s A2Z sheet. Saved my life.', 'category': 'Advice', 'upvotes': 67, 'id': '2'},
    {'content': 'I secretly fixed a bug in the college website and nobody knows 🤫', 'category': 'Confession', 'upvotes': 124, 'id': '3'},
  ];
}
