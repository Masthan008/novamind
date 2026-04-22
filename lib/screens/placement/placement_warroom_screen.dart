import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/pro_gate.dart';

/// Placement War Room
///
/// --- Supabase SQL ---
/// CREATE TABLE IF NOT EXISTS placement_companies (
///   id bigserial PRIMARY KEY,
///   name text NOT NULL,
///   role text,
///   package_lpa text,
///   visit_date text,
///   status text DEFAULT 'upcoming',
///   required_skills text[],
///   eligibility text,
///   apply_link text,
///   created_at timestamp DEFAULT now()
/// );
///
/// CREATE TABLE IF NOT EXISTS interview_experiences (
///   id bigserial PRIMARY KEY,
///   company_name text NOT NULL,
///   student_name text,
///   role text,
///   experience text NOT NULL,
///   rounds text[],
///   difficulty text DEFAULT 'medium',
///   result text DEFAULT 'pending',
///   year text,
///   created_at timestamp DEFAULT now()
/// );
///
/// ALTER TABLE placement_companies ENABLE ROW LEVEL SECURITY;
/// ALTER TABLE interview_experiences ENABLE ROW LEVEL SECURITY;
/// CREATE POLICY "Public all" ON placement_companies FOR ALL USING (true) WITH CHECK (true);
/// CREATE POLICY "Public all" ON interview_experiences FOR ALL USING (true) WITH CHECK (true);
/// ---
class PlacementWarroomScreen extends StatefulWidget {
  const PlacementWarroomScreen({super.key});

  @override
  State<PlacementWarroomScreen> createState() => _PlacementWarroomScreenState();
}

class _PlacementWarroomScreenState extends State<PlacementWarroomScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _companies = [];
  List<Map<String, dynamic>> _experiences = [];
  bool _isLoading = true;

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
    try {
      final companies = await Supabase.instance.client.from('placement_companies').select().order('created_at', ascending: false);
      final experiences = await Supabase.instance.client.from('interview_experiences').select().order('created_at', ascending: false);
      if (mounted) setState(() { _companies = List<Map<String, dynamic>>.from(companies); _experiences = List<Map<String, dynamic>>.from(experiences); _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _companies = _getHardcodedCompanies(); _experiences = _getHardcodedExperiences(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProGate(
      featureName: 'Placement War Room',
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0F),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0A0A0F),
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white70), onPressed: () => Navigator.pop(context)),
          title: ShaderMask(
            shaderCallback: (b) => const LinearGradient(colors: [Colors.indigoAccent, Color(0xFF536DFE)]).createShader(b),
            child: Text('Placement', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.indigoAccent,
            indicatorWeight: 3,
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
            unselectedLabelColor: Colors.grey,
            labelColor: Colors.indigoAccent,
            tabs: const [Tab(text: 'Companies'), Tab(text: 'Experiences')],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.indigoAccent))
            : TabBarView(controller: _tabController, children: [_buildCompaniesTab(), _buildExperiencesTab()]),
      ),
    );
  }

  Widget _buildCompaniesTab() {
    if (_companies.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.business_center_outlined, size: 64, color: Colors.grey.shade700),
        const SizedBox(height: 16),
        Text('No upcoming companies', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16)),
      ]));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _companies.length,
      itemBuilder: (context, i) {
        final c = _companies[i];
        final name = c['name'] ?? 'Company';
        final role = c['role'] ?? '';
        final pkg = c['package_lpa'] ?? '';
        final status = c['status'] ?? 'upcoming';
        final skills = List<String>.from(c['required_skills'] ?? []);
        final visitDate = c['visit_date'] ?? '';

        final statusColor = status == 'hiring' ? Colors.greenAccent
            : status == 'completed' ? Colors.grey
            : Colors.indigoAccent;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: statusColor.withOpacity(0.25)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text(name.isNotEmpty ? name[0] : 'C',
                  style: GoogleFonts.poppins(color: statusColor, fontSize: 20, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                Text('$role • $pkg', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                child: Text(status.toUpperCase(), style: GoogleFonts.poppins(color: statusColor, fontSize: 9, fontWeight: FontWeight.w600)),
              ),
            ]),
            if (visitDate.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(children: [
                Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(visitDate, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500)),
              ]),
            ],
            if (skills.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 4, children: skills.take(4).map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.indigoAccent.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                child: Text(s, style: GoogleFonts.poppins(fontSize: 10, color: Colors.indigoAccent.shade100)),
              )).toList()),
            ],
          ]),
        ).animate().fadeIn(delay: Duration(milliseconds: 80 * i)).slideX(begin: -0.1);
      },
    );
  }

  Widget _buildExperiencesTab() {
    if (_experiences.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey.shade700),
        const SizedBox(height: 16),
        Text('No experiences shared yet', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16)),
      ]));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _experiences.length,
      itemBuilder: (context, i) {
        final exp = _experiences[i];
        final company = exp['company_name'] ?? '';
        final student = exp['student_name'] ?? '';
        final experience = exp['experience'] ?? '';
        final result = exp['result'] ?? 'pending';
        final difficulty = exp['difficulty'] ?? 'medium';
        final rounds = List<String>.from(exp['rounds'] ?? []);

        final resultColor = result == 'selected' ? Colors.greenAccent
            : result == 'rejected' ? Colors.redAccent
            : Colors.orangeAccent;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: resultColor.withOpacity(0.2)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(company, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                Text('by $student', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: resultColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                child: Text(result.toUpperCase(), style: GoogleFonts.poppins(color: resultColor, fontSize: 9, fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 8),
            Text(experience, style: GoogleFonts.poppins(color: Colors.grey.shade300, fontSize: 12, height: 1.5), maxLines: 4, overflow: TextOverflow.ellipsis),
            if (rounds.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(spacing: 6, children: rounds.map((r) => Chip(
                label: Text(r, style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70)),
                backgroundColor: Colors.white.withOpacity(0.08),
                visualDensity: VisualDensity.compact,
              )).toList()),
            ],
            Row(children: [
              Text('Difficulty: ', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500)),
              Text(difficulty, style: GoogleFonts.poppins(fontSize: 11, color: difficulty == 'hard' ? Colors.redAccent : difficulty == 'easy' ? Colors.greenAccent : Colors.orangeAccent, fontWeight: FontWeight.w600)),
            ]),
          ]),
        ).animate().fadeIn(delay: Duration(milliseconds: 80 * i));
      },
    );
  }

  static List<Map<String, dynamic>> _getHardcodedCompanies() {
    return [
      {'name': 'TCS', 'role': 'Digital Trainee', 'package_lpa': '3.3-7 LPA', 'status': 'upcoming', 'visit_date': 'April 2026', 'required_skills': ['Aptitude', 'Coding', 'Communication']},
      {'name': 'Infosys', 'role': 'SE/PP', 'package_lpa': '3.6-9 LPA', 'status': 'hiring', 'visit_date': 'March 2026', 'required_skills': ['DSA', 'DBMS', 'Java/Python']},
      {'name': 'Wipro', 'role': 'WILP', 'package_lpa': '3.5 LPA', 'status': 'completed', 'visit_date': 'Feb 2026', 'required_skills': ['Aptitude', 'English', 'Coding']},
      {'name': 'Capgemini', 'role': 'Associate', 'package_lpa': '3.8-7.5 LPA', 'status': 'upcoming', 'visit_date': 'April 2026', 'required_skills': ['Problem Solving', 'Communication']},
    ];
  }

  static List<Map<String, dynamic>> _getHardcodedExperiences() {
    return [
      {'company_name': 'Infosys SP', 'student_name': 'Ravi T.', 'experience': 'Online test → 3 coding questions + MCQs in 2.5 hrs. I focused on Java and solved 2/3 coding. MCQs covered DBMS, OS. Got selected for SP role.', 'rounds': ['Online Test', 'HR Interview'], 'difficulty': 'medium', 'result': 'selected'},
      {'company_name': 'TCS Digital', 'student_name': 'Priya S.', 'experience': 'NQT exam: Aptitude + Coding + Advanced Coding. The advanced coding section was tough — needed DP and graph knowledge. Post NQT, there was an interview focusing on projects.', 'rounds': ['NQT', 'Technical', 'HR'], 'difficulty': 'hard', 'result': 'selected'},
      {'company_name': 'Wipro WILP', 'student_name': 'Karthik R.', 'experience': 'Straight-forward online test with basic aptitude and 2 easy coding questions. Essay writing round followed. Wipro is looking for communication skills more than hard technical skills.', 'rounds': ['Online Test', 'Essay', 'Interview'], 'difficulty': 'easy', 'result': 'selected'},
    ];
  }
}
