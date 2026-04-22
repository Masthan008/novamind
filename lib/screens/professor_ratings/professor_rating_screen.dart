import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/student_auth_service.dart';
import '../../services/college_service.dart';

class ProfessorRatingScreen extends StatefulWidget {
  const ProfessorRatingScreen({super.key});
  @override
  State<ProfessorRatingScreen> createState() => _ProfessorRatingScreenState();
}

class _ProfessorRatingScreenState extends State<ProfessorRatingScreen> {
  List<Map<String, dynamic>> _professors = [];
  bool _loading = true;
  String _filterDept = 'All';
  Map<String, dynamic>? _college;
  final _db = Supabase.instance.client;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      _college = await CollegeService.getStudentCollege();
      if (_college != null) {
        final data = await _db.from('professors').select().eq('college_id', _college!['id']).order('avg_overall', ascending: false);
        _professors = List<Map<String, dynamic>>.from(data);
      } else {
        _professors = _fallback;
      }
    } catch (e) {
      _professors = _fallback;
    }
    if (mounted) setState(() => _loading = false);
  }

  void _showAddProfessor() {
    final nameC = TextEditingController();
    final deptC = TextEditingController();
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Add Professor', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          TextField(controller: nameC, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
            decoration: _inputDec('Professor Name')),
          const SizedBox(height: 10),
          TextField(controller: deptC, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
            decoration: _inputDec('Department')),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            onPressed: () async {
              if (nameC.text.isEmpty) return;
              Navigator.pop(ctx);
              try { await _db.from('professors').insert({'name': nameC.text, 'department': deptC.text, 'college_id': _college?['id']}); _load(); } catch (_) {}
            },
            child: Text('Add', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          )),
        ]),
      ),
    );
  }

  void _showRateSheet(Map<String, dynamic> prof) {
    int teaching = 4, availability = 3, fairness = 4, overall = 4;
    final reviewC = TextEditingController();

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Rate ${prof['name']}', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          _ratingRow('Teaching', teaching, (v) => setSheet(() => teaching = v)),
          _ratingRow('Availability', availability, (v) => setSheet(() => availability = v)),
          _ratingRow('Fairness', fairness, (v) => setSheet(() => fairness = v)),
          _ratingRow('Overall', overall, (v) => setSheet(() => overall = v)),
          const SizedBox(height: 12),
          TextField(controller: reviewC, maxLines: 2, style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
            decoration: _inputDec('Write a review (optional)')),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final student = StudentAuthService.currentStudent;
                await _db.from('professor_ratings').insert({
                  'professor_id': prof['id'],
                  'student_id': student?.id.toString(),
                  'teaching_rating': teaching,
                  'availability_rating': availability,
                  'fairness_rating': fairness,
                  'overall_rating': overall,
                  'review_text': reviewC.text,
                });
                _load();
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⭐ Rating submitted!'), backgroundColor: Colors.green));
              } catch (_) {}
            },
            child: Text('Submit Rating', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          )),
        ]),
      )),
    );
  }

  Widget _ratingRow(String label, int value, ValueChanged<int> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        SizedBox(width: 80, child: Text(label, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12))),
        ...List.generate(5, (i) => GestureDetector(
          onTap: () => onChanged(i + 1),
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(i < value ? Icons.star : Icons.star_border, color: Colors.amber, size: 24)),
        )),
      ]),
    );
  }

  InputDecoration _inputDec(String hint) => InputDecoration(
    hintText: hint, hintStyle: GoogleFonts.poppins(color: Colors.grey),
    filled: true, fillColor: Colors.white.withOpacity(0.05),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
  );

  @override
  Widget build(BuildContext context) {
    final depts = <String>{'All'};
    for (final p in _professors) if (p['department'] != null) depts.add(p['department']);
    final filtered = _filterDept == 'All' ? _professors : _professors.where((p) => p['department'] == _filterDept).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        title: Text('Rate Professors', style: GoogleFonts.orbitron(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white70), onPressed: () => Navigator.pop(context)),
        actions: [
          if (_college != null) IconButton(icon: const Icon(Icons.person_add, color: Colors.amber), onPressed: _showAddProfessor),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : Column(children: [
              SizedBox(height: 42, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children:
                depts.map((d) => Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(
                  label: Text(d, style: GoogleFonts.poppins(fontSize: 12)), selected: _filterDept == d,
                  selectedColor: Colors.amber, backgroundColor: Colors.white.withOpacity(0.08),
                  labelStyle: TextStyle(color: _filterDept == d ? Colors.black : Colors.grey),
                  onSelected: (_) => setState(() => _filterDept = d)))).toList(),
              )).animate().fadeIn(),
              Expanded(
                child: filtered.isEmpty
                    ? Center(child: Text('No professors added yet', style: GoogleFonts.poppins(color: Colors.grey)))
                    : RefreshIndicator(onRefresh: _load, child: ListView.builder(
                        padding: const EdgeInsets.all(16), itemCount: filtered.length,
                        itemBuilder: (_, i) => _profCard(filtered[i], i),
                      )),
              ),
            ]),
    );
  }

  Widget _profCard(Map<String, dynamic> p, int index) {
    final overall = (p['avg_overall'] as num?)?.toDouble() ?? 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 20, backgroundColor: Colors.amber.withOpacity(0.2), child: const Icon(Icons.school, color: Colors.amber, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p['name'] ?? '', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
            Text(p['department'] ?? '', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11)),
          ])),
          Column(children: [
            Row(children: [
              Icon(Icons.star, color: Colors.amber, size: 16),
              Text(' ${overall.toStringAsFixed(1)}', style: GoogleFonts.orbitron(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold)),
            ]),
            Text('${p['total_ratings'] ?? 0} ratings', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 9)),
          ]),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          _miniRating('Teaching', p['avg_teaching']),
          _miniRating('Availability', p['avg_availability']),
          _miniRating('Fairness', p['avg_fairness']),
        ]),
        const SizedBox(height: 10),
        SizedBox(width: double.infinity, child: OutlinedButton(
          style: OutlinedButton.styleFrom(foregroundColor: Colors.amber, side: BorderSide(color: Colors.amber.withOpacity(0.3)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          onPressed: () { HapticFeedback.lightImpact(); _showRateSheet(p); },
          child: Text('Rate', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
        )),
      ]),
    ).animate().fadeIn(delay: Duration(milliseconds: 100 + index * 50)).slideX(begin: 0.03);
  }

  Widget _miniRating(String label, dynamic value) {
    final v = (value as num?)?.toDouble() ?? 0.0;
    return Expanded(child: Column(children: [
      Text(v.toStringAsFixed(1), style: GoogleFonts.orbitron(color: Colors.white, fontSize: 12)),
      Text(label, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 9)),
    ]));
  }

  static final _fallback = [
    {'id': '1', 'name': 'Dr. Radhika Iyer', 'department': 'CSE', 'avg_teaching': 4.2, 'avg_availability': 3.8, 'avg_fairness': 4.0, 'avg_overall': 4.0, 'total_ratings': 28},
    {'id': '2', 'name': 'Prof. Kiran Desai', 'department': 'ECE', 'avg_teaching': 3.5, 'avg_availability': 4.0, 'avg_fairness': 3.8, 'avg_overall': 3.7, 'total_ratings': 15},
  ];
}
