import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/skillmatch_service.dart';
import '../../widgets/pro_gate.dart';

class SkillmatchScreen extends StatefulWidget {
  const SkillmatchScreen({super.key});

  @override
  State<SkillmatchScreen> createState() => _SkillmatchScreenState();
}

class _SkillmatchScreenState extends State<SkillmatchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _jobs = [];
  List<Map<String, dynamic>> _applications = [];
  bool _isLoading = true;
  String _selectedType = 'All';

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
    final jobs = await SkillmatchService.getJobPostings();
    final apps = await SkillmatchService.getMyApplications();
    if (mounted) {
      setState(() {
        _jobs = jobs;
        _applications = apps;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProGate(
      featureName: 'SkillMatch',
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
              colors: [Colors.lightGreenAccent, Color(0xFF00E676)],
            ).createShader(bounds),
            child: Text('SkillMatch', style: GoogleFonts.orbitron(
              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.lightGreenAccent,
            indicatorWeight: 3,
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
            unselectedLabelColor: Colors.grey,
            labelColor: Colors.lightGreenAccent,
            tabs: const [Tab(text: 'Jobs'), Tab(text: 'Applications')],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.lightGreenAccent))
            : TabBarView(controller: _tabController, children: [_buildJobsTab(), _buildAppsTab()]),
      ),
    );
  }

  Widget _buildJobsTab() {
    final filtered = _selectedType == 'All' ? _jobs
        : _jobs.where((j) => j['type'] == _selectedType.toLowerCase()).toList();

    return Column(
      children: [
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: ['All', 'Internship', 'Full-time'].map((t) {
              final sel = _selectedType == t;
              return GestureDetector(
                onTap: () => setState(() => _selectedType = t),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: sel ? Colors.lightGreenAccent.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? Colors.lightGreenAccent : Colors.white12),
                  ),
                  alignment: Alignment.center,
                  child: Text(t, style: GoogleFonts.poppins(fontSize: 12,
                    color: sel ? Colors.lightGreenAccent : Colors.grey,
                    fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (context, i) => _buildJobCard(filtered[i], i),
          ),
        ),
      ],
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job, int index) {
    final title = job['title'] ?? 'Job Title';
    final company = (job['companies'] as Map?)?['name'] ?? 'Company';
    final type = job['type'] ?? 'internship';
    final skills = List<String>.from(job['required_skills'] ?? []);
    final location = job['location'] ?? 'Remote';
    final salary = job['salary_range'] ?? '';

    final typeColor = type == 'internship' ? Colors.cyanAccent : Colors.lightGreenAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.lightGreenAccent.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: Colors.lightGreenAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Text(company.isNotEmpty ? company[0] : 'C',
                  style: GoogleFonts.poppins(color: Colors.lightGreenAccent, fontSize: 18, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                Text(company, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(type.toUpperCase(), style: GoogleFonts.poppins(fontSize: 9, color: typeColor, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(children: [
            Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(location, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500)),
            if (salary.isNotEmpty) ...[
              const SizedBox(width: 12),
              Icon(Icons.attach_money, size: 14, color: Colors.grey.shade500),
              Text(salary, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500)),
            ],
          ]),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 4, children: skills.take(4).map((s) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.lightGreenAccent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(s, style: GoogleFonts.poppins(fontSize: 10, color: Colors.lightGreenAccent.shade200)),
          )).toList()),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showApplyDialog(job),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreenAccent.withOpacity(0.15),
                foregroundColor: Colors.lightGreenAccent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Apply Now', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 80 * index)).slideY(begin: 0.1);
  }

  void _showApplyDialog(Map<String, dynamic> job) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Apply to ${job['title']}', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Why are you a good fit?',
              hintStyle: GoogleFonts.poppins(color: Colors.grey),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final jobId = job['id'] is int ? job['id'] : int.tryParse('${job['id']}') ?? 0;
                final ok = await SkillmatchService.applyToJob(
                  jobId: jobId, coverMessage: controller.text.trim());
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  if (ok) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('🎉 Application submitted!', style: GoogleFonts.poppins(fontSize: 13)),
                      backgroundColor: const Color(0xFF2A2A3E),
                    ));
                    _loadData();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreenAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Submit Application', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _buildAppsTab() {
    if (_applications.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.work_outline, size: 64, color: Colors.grey.shade700),
        const SizedBox(height: 16),
        Text('No applications yet', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16)),
      ]));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _applications.length,
      itemBuilder: (context, i) {
        final app = _applications[i];
        final jobData = app['job_postings'] as Map<String, dynamic>?;
        final title = jobData?['title'] ?? 'Job';
        final company = (jobData?['companies'] as Map?)?['name'] ?? 'Company';
        final status = app['status'] ?? 'applied';
        final statusColor = status == 'accepted' ? Colors.greenAccent
            : status == 'rejected' ? Colors.redAccent
            : status == 'interview' ? Colors.cyanAccent
            : Colors.orangeAccent;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: statusColor.withOpacity(0.3)),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.work, color: statusColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
              Text(company, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
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
          ]),
        ).animate().fadeIn(delay: Duration(milliseconds: 80 * i));
      },
    );
  }
}
