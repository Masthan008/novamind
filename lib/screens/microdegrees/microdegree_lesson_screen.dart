import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/microdegree_service.dart';

class MicrodegreeLessonScreen extends StatefulWidget {
  final Map<String, dynamic> lesson;
  final dynamic degreeId;
  final int totalLessons;

  const MicrodegreeLessonScreen({
    super.key,
    required this.lesson,
    required this.degreeId,
    required this.totalLessons,
  });

  @override
  State<MicrodegreeLessonScreen> createState() => _MicrodegreeLessonScreenState();
}

class _MicrodegreeLessonScreenState extends State<MicrodegreeLessonScreen> {
  bool _isCompleting = false;
  bool _isCompleted = false;

  Future<void> _markComplete() async {
    setState(() => _isCompleting = true);
    final dId = widget.degreeId is int ? widget.degreeId : int.tryParse('${widget.degreeId}') ?? 0;
    final lId = widget.lesson['id'] is int ? widget.lesson['id'] : int.tryParse('${widget.lesson['id']}') ?? 0;
    final ok = await MicrodegreeService.completeLesson(dId, lId, widget.totalLessons);
    if (mounted) {
      setState(() {
        _isCompleting = false;
        _isCompleted = ok;
      });
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('✅ Lesson completed!', style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: const Color(0xFF2A2A3E),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.lesson['title'] ?? 'Lesson';
    final notes = widget.lesson['notes'] ?? 'No notes available for this lesson yet.';
    final videoUrl = widget.lesson['video_url'];
    final duration = widget.lesson['duration_minutes'] ?? 0;
    final resources = widget.lesson['resources'] as List? ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
          overflow: TextOverflow.ellipsis),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video placeholder
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.tealAccent.withOpacity(0.2)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(videoUrl != null ? Icons.play_circle : Icons.videocam_off,
                    size: 48, color: Colors.tealAccent.withOpacity(0.5)),
                  const SizedBox(height: 8),
                  Text(videoUrl != null ? 'Tap to play video' : 'Video coming soon',
                    style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
                  if (duration > 0)
                    Text('$duration min', style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 11)),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 24),

            // Notes
            Text('Lesson Notes', style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Text(notes, style: GoogleFonts.poppins(
                color: Colors.grey.shade300, fontSize: 13, height: 1.6)),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 24),

            // Resources
            if (resources.isNotEmpty) ...[
              Text('Resources', style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 10),
              ...resources.map((r) {
                final resource = r is Map ? r : {};
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.link, color: Colors.blueAccent, size: 18),
                  ),
                  title: Text(resource['title'] ?? 'Resource', style: GoogleFonts.poppins(
                    color: Colors.white70, fontSize: 13)),
                  trailing: const Icon(Icons.open_in_new, color: Colors.grey, size: 16),
                );
              }),
              const SizedBox(height: 24),
            ],

            // Mark complete
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isCompleted || _isCompleting ? null : _markComplete,
                icon: Icon(_isCompleted ? Icons.check_circle : Icons.check, size: 20),
                label: Text(
                  _isCompleted ? 'Completed!' : 'Mark as Complete',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isCompleted ? Colors.greenAccent : Colors.tealAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ).animate().fadeIn(delay: 500.ms),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
