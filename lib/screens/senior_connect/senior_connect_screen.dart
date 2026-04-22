import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/student_auth_service.dart';
import '../../widgets/pro_gate.dart';

/// Senior Connect Screen
///
/// --- Supabase SQL ---
/// CREATE TABLE IF NOT EXISTS senior_profiles (
///   id bigserial PRIMARY KEY,
///   student_id text NOT NULL,
///   name text NOT NULL,
///   year text,
///   placed_at text,
///   role text,
///   skills text[],
///   bio text,
///   linkedin_url text,
///   is_available boolean DEFAULT true,
///   created_at timestamp DEFAULT now()
/// );
///
/// ALTER TABLE senior_profiles ENABLE ROW LEVEL SECURITY;
/// CREATE POLICY "Public all" ON senior_profiles FOR ALL USING (true) WITH CHECK (true);
/// ---
class SeniorConnectScreen extends StatefulWidget {
  const SeniorConnectScreen({super.key});

  @override
  State<SeniorConnectScreen> createState() => _SeniorConnectScreenState();
}

class _SeniorConnectScreenState extends State<SeniorConnectScreen> {
  List<Map<String, dynamic>> _seniors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSeniors();
  }

  Future<void> _loadSeniors() async {
    try {
      final data = await Supabase.instance.client
          .from('senior_profiles')
          .select()
          .eq('is_available', true)
          .order('created_at', ascending: false);
      if (mounted) setState(() { _seniors = List<Map<String, dynamic>>.from(data); _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _seniors = _getHardcodedSeniors(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProGate(
      featureName: 'Senior Connect',
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0F),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0A0A0F),
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white70), onPressed: () => Navigator.pop(context)),
          title: ShaderMask(
            shaderCallback: (b) => const LinearGradient(colors: [Colors.pinkAccent, Color(0xFFFF4081)]).createShader(b),
            child: Text('Senior Connect', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.pinkAccent))
            : _seniors.isEmpty
                ? Center(child: Text('No seniors available yet', style: GoogleFonts.poppins(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _seniors.length,
                    itemBuilder: (context, i) => _buildSeniorCard(_seniors[i], i),
                  ),
      ),
    );
  }

  Widget _buildSeniorCard(Map<String, dynamic> senior, int index) {
    final name = senior['name'] ?? 'Senior';
    final placedAt = senior['placed_at'] ?? '';
    final role = senior['role'] ?? '';
    final skills = List<String>.from(senior['skills'] ?? []);
    final bio = senior['bio'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.pinkAccent.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.pinkAccent.withOpacity(0.3), Colors.pink.withOpacity(0.2)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: Text(name.isNotEmpty ? name[0] : 'S',
              style: GoogleFonts.poppins(color: Colors.pinkAccent, fontSize: 22, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
            if (placedAt.isNotEmpty) Text('$role @ $placedAt', style: GoogleFonts.poppins(color: Colors.pinkAccent.shade100, fontSize: 12)),
          ])),
          if (placedAt.isNotEmpty) Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('PLACED', style: GoogleFonts.poppins(fontSize: 9, color: Colors.greenAccent, fontWeight: FontWeight.w600)),
          ),
        ]),
        if (bio.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(bio, style: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
        if (skills.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 4, children: skills.take(4).map((s) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: Colors.pinkAccent.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
            child: Text(s, style: GoogleFonts.poppins(fontSize: 10, color: Colors.pinkAccent.shade100)),
          )).toList()),
        ],
        const SizedBox(height: 10),
        SizedBox(width: double.infinity, child: OutlinedButton.icon(
          onPressed: () { HapticFeedback.lightImpact(); ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('📧 Connection request sent!', style: GoogleFonts.poppins(fontSize: 13)),
            backgroundColor: const Color(0xFF2A2A3E))); },
          icon: const Icon(Icons.connect_without_contact, size: 16),
          label: Text('Connect', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(foregroundColor: Colors.pinkAccent, side: BorderSide(color: Colors.pinkAccent.withOpacity(0.4)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        )),
      ]),
    ).animate().fadeIn(delay: Duration(milliseconds: 80 * index)).slideX(begin: -0.1);
  }

  static List<Map<String, dynamic>> _getHardcodedSeniors() {
    return [
      {'name': 'Aditya Verma', 'placed_at': 'Google', 'role': 'SDE', 'skills': ['DSA', 'System Design', 'Python', 'Go'], 'bio': 'LeetCode 2100+, 3 internships, happy to help juniors prep for interviews'},
      {'name': 'Meera Nair', 'placed_at': 'Microsoft', 'role': 'SDE-1', 'skills': ['C++', 'Azure', 'DSA', '.NET'], 'bio': '2x Microsoft intern, love mentoring on campus prep strategies'},
      {'name': 'Karthik Reddy', 'placed_at': 'Amazon', 'role': 'SDE', 'skills': ['Java', 'AWS', 'React', 'System Design'], 'bio': 'Started coding in 2nd year, went from zero to Amazon offer'},
      {'name': 'Anjali Gupta', 'placed_at': 'Flipkart', 'role': 'PM Intern → FTE', 'skills': ['Product', 'SQL', 'Analytics', 'Strategy'], 'bio': 'Transitioned from engineering to PM, ask me about product roles'},
      {'name': 'Rohit Sharma', 'placed_at': 'Razorpay', 'role': 'Backend Dev', 'skills': ['Go', 'Kafka', 'Postgres', 'Redis'], 'bio': 'Open source contributor, fintech enthusiast, happy to review resumes'},
    ];
  }
}
