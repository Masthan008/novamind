import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/microdegree_service.dart';
import 'microdegree_lesson_screen.dart';

class MicrodegreeDetailScreen extends StatefulWidget {
  final Map<String, dynamic> degree;
  const MicrodegreeDetailScreen({super.key, required this.degree});

  @override
  State<MicrodegreeDetailScreen> createState() => _MicrodegreeDetailScreenState();
}

class _MicrodegreeDetailScreenState extends State<MicrodegreeDetailScreen> {
  List<Map<String, dynamic>> _lessons = [];
  bool _isLoading = true;
  bool _isEnrolled = false;
  bool _enrolling = false;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    final degreeId = widget.degree['id'];
    final lessons = await MicrodegreeService.getLessons(degreeId is int ? degreeId : int.tryParse('$degreeId') ?? 0);
    final progress = await MicrodegreeService.getMyProgress();
    final enrolled = progress.any((p) => p['microdegree_id'] == degreeId);
    if (mounted) {
      setState(() {
        _lessons = lessons;
        _isEnrolled = enrolled;
        _isLoading = false;
      });
    }
  }

  Future<void> _enroll() async {
    setState(() => _enrolling = true);
    final degreeId = widget.degree['id'];
    final ok = await MicrodegreeService.enroll(degreeId is int ? degreeId : int.tryParse('$degreeId') ?? 0);
    if (mounted) {
      setState(() {
        _enrolling = false;
        _isEnrolled = ok;
      });
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('🎉 Enrolled successfully!', style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: const Color(0xFF2A2A3E),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.degree['title'] ?? 'MicroDegree';
    final desc = widget.degree['description'] ?? '';
    final weeks = widget.degree['duration_weeks'] ?? 0;
    final difficulty = widget.degree['difficulty'] ?? 'Beginner';
    final skills = List<String>.from(widget.degree['skills_earned'] ?? []);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFF0A0A0F),
            expandedHeight: 200,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.tealAccent.withOpacity(0.2), const Color(0xFF0A0A0F)],
                  ),
                ),
                child: Center(
                  child: Icon(Icons.school, size: 64, color: Colors.tealAccent.withOpacity(0.4)),
                ),
              ),
              title: Text(title, style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(delegate: SliverChildListDelegate([
              // Info chips
              Row(
                children: [
                  _infoChip(Icons.calendar_today, '$weeks weeks', Colors.tealAccent),
                  const SizedBox(width: 8),
                  _infoChip(Icons.signal_cellular_alt, difficulty,
                      difficulty == 'Beginner' ? Colors.greenAccent : Colors.orangeAccent),
                  const SizedBox(width: 8),
                  _infoChip(Icons.emoji_events, '${skills.length} skills', Colors.amberAccent),
                ],
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 20),

              // Description
              Text(desc, style: GoogleFonts.poppins(color: Colors.grey.shade300, fontSize: 14, height: 1.6)),
              const SizedBox(height: 24),

              // Skills earned
              Text('Skills You\'ll Earn', style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: skills.map((s) => Chip(
                  label: Text(s, style: GoogleFonts.poppins(fontSize: 12, color: Colors.tealAccent)),
                  backgroundColor: Colors.tealAccent.withOpacity(0.1),
                  side: BorderSide(color: Colors.tealAccent.withOpacity(0.3)),
                )).toList(),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 24),

              // Curriculum
              Text('Curriculum', style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 10),

              if (_isLoading)
                const Center(child: CircularProgressIndicator(color: Colors.tealAccent))
              else if (_lessons.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('Curriculum coming soon! Enroll now to get notified.',
                    style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
                    textAlign: TextAlign.center),
                )
              else
                ..._buildCurriculum(),

              const SizedBox(height: 32),

              // Enroll button
              if (!_isEnrolled)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _enrolling ? null : _enroll,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _enrolling
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text('Enroll Now', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2)
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.greenAccent.withOpacity(0.4)),
                  ),
                  child: Center(child: Text('✅ Enrolled', style: GoogleFonts.poppins(
                    color: Colors.greenAccent, fontWeight: FontWeight.w600, fontSize: 15))),
                ),

              const SizedBox(height: 40),
            ])),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCurriculum() {
    // Group lessons by week
    final Map<int, List<Map<String, dynamic>>> byWeek = {};
    for (final l in _lessons) {
      final w = l['week_number'] ?? 1;
      byWeek.putIfAbsent(w, () => []).add(l);
    }

    return byWeek.entries.map((entry) {
      return ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(left: 16),
        title: Text('Week ${entry.key}', style: GoogleFonts.poppins(
          color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text('${entry.value.length} lessons', style: GoogleFonts.poppins(
          color: Colors.grey, fontSize: 11)),
        iconColor: Colors.tealAccent,
        children: entry.value.map((lesson) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.tealAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.play_circle_outline, color: Colors.tealAccent, size: 20),
            ),
            title: Text(lesson['title'] ?? 'Lesson', style: GoogleFonts.poppins(
              color: Colors.white70, fontSize: 13)),
            subtitle: Text('${lesson['duration_minutes'] ?? 0} min', style: GoogleFonts.poppins(
              color: Colors.grey, fontSize: 11)),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
            onTap: () {
              if (_isEnrolled) {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => MicrodegreeLessonScreen(
                    lesson: lesson,
                    degreeId: widget.degree['id'],
                    totalLessons: _lessons.length,
                  ),
                ));
              }
            },
          );
        }).toList(),
      );
    }).toList();
  }

  Widget _infoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(text, style: GoogleFonts.poppins(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
