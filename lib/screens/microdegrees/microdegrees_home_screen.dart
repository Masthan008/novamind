import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/microdegree_service.dart';
import '../../widgets/pro_gate.dart';
import 'microdegree_detail_screen.dart';

class MicrodegreesHomeScreen extends StatefulWidget {
  const MicrodegreesHomeScreen({super.key});

  @override
  State<MicrodegreesHomeScreen> createState() => _MicrodegreesHomeScreenState();
}

class _MicrodegreesHomeScreenState extends State<MicrodegreesHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _degrees = [];
  List<Map<String, dynamic>> _myProgress = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Beginner', 'Intermediate', 'Advanced'];

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
    final degrees = await MicrodegreeService.getAllDegrees();
    final progress = await MicrodegreeService.getMyProgress();
    if (mounted) {
      setState(() {
        _degrees = degrees;
        _myProgress = progress;
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredDegrees {
    if (_selectedFilter == 'All') return _degrees;
    return _degrees.where((d) => d['difficulty'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ProGate(
      featureName: 'MicroDegrees',
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
              colors: [Colors.tealAccent, Color(0xFF00E5FF)],
            ).createShader(bounds),
            child: Text('MicroDegrees', style: GoogleFonts.orbitron(
              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.tealAccent,
            indicatorWeight: 3,
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
            unselectedLabelColor: Colors.grey,
            labelColor: Colors.tealAccent,
            tabs: const [Tab(text: 'Explore'), Tab(text: 'My Progress')],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.tealAccent))
            : TabBarView(
                controller: _tabController,
                children: [_buildExploreTab(), _buildProgressTab()],
              ),
      ),
    );
  }

  Widget _buildExploreTab() {
    final filtered = _filteredDegrees;
    return Column(
      children: [
        // Filters
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _filters.length,
            itemBuilder: (context, i) {
              final isSelected = _selectedFilter == _filters[i];
              return GestureDetector(
                onTap: () => setState(() => _selectedFilter = _filters[i]),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.tealAccent.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.tealAccent : Colors.white12),
                  ),
                  alignment: Alignment.center,
                  child: Text(_filters[i], style: GoogleFonts.poppins(
                    fontSize: 12, color: isSelected ? Colors.tealAccent : Colors.grey,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
                ),
              );
            },
          ),
        ),
        // Degrees grid
        Expanded(
          child: filtered.isEmpty
              ? Center(child: Text('No degrees found', style: GoogleFonts.poppins(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    return _buildDegreeCard(filtered[i], i).animate()
                        .fadeIn(delay: Duration(milliseconds: 100 * i))
                        .slideY(begin: 0.1);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDegreeCard(Map<String, dynamic> degree, int index) {
    final title = degree['title'] ?? 'Untitled';
    final desc = degree['description'] ?? '';
    final weeks = degree['duration_weeks'] ?? 0;
    final difficulty = degree['difficulty'] ?? 'Beginner';
    final skills = List<String>.from(degree['skills_earned'] ?? []);

    final diffColor = difficulty == 'Beginner' ? Colors.greenAccent
        : difficulty == 'Intermediate' ? Colors.orangeAccent
        : Colors.redAccent;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => MicrodegreeDetailScreen(degree: degree)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.tealAccent.withOpacity(0.2)),
          boxShadow: [BoxShadow(color: Colors.tealAccent.withOpacity(0.05), blurRadius: 12)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.tealAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.school, color: Colors.tealAccent, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: GoogleFonts.poppins(
                        color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text('$weeks weeks', style: GoogleFonts.poppins(
                        color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: diffColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: diffColor.withOpacity(0.4)),
                  ),
                  child: Text(difficulty, style: GoogleFonts.poppins(
                    fontSize: 10, color: diffColor, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(desc, style: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: skills.take(4).map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.tealAccent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(s, style: GoogleFonts.poppins(fontSize: 10, color: Colors.tealAccent.shade200)),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTab() {
    if (_myProgress.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 64, color: Colors.grey.shade700),
            const SizedBox(height: 16),
            Text('No enrolled degrees yet', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 8),
            Text('Explore and enroll in a MicroDegree', style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 13)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myProgress.length,
      itemBuilder: (context, i) {
        final progress = _myProgress[i];
        final degreeData = progress['microdegrees'] as Map<String, dynamic>?;
        final title = degreeData?['title'] ?? 'Unknown Degree';
        final percentage = progress['completion_percentage'] ?? 0;
        final isComplete = percentage >= 100;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isComplete
                ? Colors.greenAccent.withOpacity(0.3)
                : Colors.tealAccent.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(isComplete ? Icons.verified : Icons.school,
                    color: isComplete ? Colors.greenAccent : Colors.tealAccent, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(title, style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14))),
                  Text('$percentage%', style: GoogleFonts.poppins(
                    color: isComplete ? Colors.greenAccent : Colors.tealAccent,
                    fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(
                    isComplete ? Colors.greenAccent : Colors.tealAccent),
                  minHeight: 6,
                ),
              ),
              if (isComplete) ...[
                const SizedBox(height: 8),
                Text('✅ Completed!', style: GoogleFonts.poppins(
                  fontSize: 11, color: Colors.greenAccent)),
              ],
            ],
          ),
        ).animate()
            .fadeIn(delay: Duration(milliseconds: 100 * i))
            .slideX(begin: -0.1);
      },
    );
  }
}
