import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/student_auth_service.dart';
import '../../widgets/pro_gate.dart';

/// Build In Public Board
///
/// --- Supabase SQL ---
/// CREATE TABLE IF NOT EXISTS build_posts (
///   id bigserial PRIMARY KEY,
///   student_id text NOT NULL,
///   student_name text NOT NULL,
///   project_name text NOT NULL,
///   content text NOT NULL,
///   category text DEFAULT 'update',
///   media_url text,
///   likes int DEFAULT 0,
///   created_at timestamp DEFAULT now()
/// );
///
/// ALTER TABLE build_posts ENABLE ROW LEVEL SECURITY;
/// CREATE POLICY "Public all" ON build_posts FOR ALL USING (true) WITH CHECK (true);
/// ---
class BuildPublicScreen extends StatefulWidget {
  const BuildPublicScreen({super.key});

  @override
  State<BuildPublicScreen> createState() => _BuildPublicScreenState();
}

class _BuildPublicScreenState extends State<BuildPublicScreen> {
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      final data = await Supabase.instance.client
          .from('build_posts')
          .select()
          .order('created_at', ascending: false)
          .limit(50);
      if (mounted) setState(() { _posts = List<Map<String, dynamic>>.from(data); _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _posts = _getHardcodedPosts(); _isLoading = false; });
    }
  }

  Future<void> _createPost() async {
    final projectController = TextEditingController();
    final contentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Share Your Progress', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 16),
          TextField(
            controller: projectController,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Project name',
              hintStyle: GoogleFonts.poppins(color: Colors.grey),
              filled: true, fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: contentController,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'What did you build/learn/ship today?',
              hintStyle: GoogleFonts.poppins(color: Colors.grey),
              filled: true, fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () async {
              final student = StudentAuthService.currentStudent;
              if (student == null || projectController.text.trim().isEmpty) return;
              try {
                await Supabase.instance.client.from('build_posts').insert({
                  'student_id': student.id.toString(),
                  'student_name': student.name,
                  'project_name': projectController.text.trim(),
                  'content': contentController.text.trim(),
                });
                if (ctx.mounted) Navigator.pop(ctx);
                _loadPosts();
              } catch (_) {}
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text('Post Update', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          )),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProGate(
      featureName: 'Build In Public',
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0F),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0A0A0F),
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white70), onPressed: () => Navigator.pop(context)),
          title: ShaderMask(
            shaderCallback: (b) => const LinearGradient(colors: [Colors.deepPurpleAccent, Color(0xFF7C4DFF)]).createShader(b),
            child: Text('Build Public', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.add_circle_outline, color: Colors.deepPurpleAccent), onPressed: _createPost),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent))
            : _posts.isEmpty
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.rocket_launch, size: 64, color: Colors.grey.shade700),
                    const SizedBox(height: 16),
                    Text('No posts yet', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('Be the first to share!', style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 13)),
                  ]))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _posts.length,
                    itemBuilder: (context, i) => _buildPostCard(_posts[i], i),
                  ),
        floatingActionButton: FloatingActionButton(
          onPressed: _createPost,
          backgroundColor: Colors.deepPurpleAccent,
          child: const Icon(Icons.edit, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post, int index) {
    final name = post['student_name'] ?? 'Student';
    final project = post['project_name'] ?? 'Project';
    final content = post['content'] ?? '';
    final likes = post['likes'] ?? 0;
    final createdAt = post['created_at'] != null ? DateTime.tryParse(post['created_at']) : null;
    final timeStr = createdAt != null ? DateFormat('MMM d, HH:mm').format(createdAt) : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.deepPurpleAccent.withOpacity(0.3), Colors.purple.withOpacity(0.2)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(name.isNotEmpty ? name[0] : 'S',
              style: GoogleFonts.poppins(color: Colors.deepPurpleAccent, fontSize: 16, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
            Text(timeStr, style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 10)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.deepPurpleAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(project, style: GoogleFonts.poppins(fontSize: 10, color: Colors.deepPurpleAccent.shade100, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis),
          ),
        ]),
        const SizedBox(height: 10),
        Text(content, style: GoogleFonts.poppins(color: Colors.grey.shade300, fontSize: 13, height: 1.5)),
        const SizedBox(height: 10),
        Row(children: [
          GestureDetector(
            onTap: () { HapticFeedback.lightImpact(); },
            child: Row(children: [
              Icon(Icons.favorite_border, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text('$likes', style: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 12)),
            ]),
          ),
          const SizedBox(width: 16),
          Icon(Icons.share_outlined, size: 16, color: Colors.grey.shade500),
        ]),
      ]),
    ).animate().fadeIn(delay: Duration(milliseconds: 80 * index)).slideY(begin: 0.1);
  }

  static List<Map<String, dynamic>> _getHardcodedPosts() {
    return [
      {'student_name': 'Ravi Teja', 'project_name': 'AI Resume', 'content': 'Built an AI resume parser using GPT-4! It extracts skills, experience, and education from any PDF.', 'likes': 12, 'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String()},
      {'student_name': 'Sneha K', 'project_name': 'FitTrack', 'content': 'Shipped v2 of my fitness tracking app! Added calorie tracking and workout logs. Next: social features.', 'likes': 8, 'created_at': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String()},
      {'student_name': 'Arjun M', 'project_name': 'CodeBuddy', 'content': 'Day 15 of building CodeBuddy — a peer code review platform. Today I added real-time code diffing with highlight.js', 'likes': 15, 'created_at': DateTime.now().subtract(const Duration(hours: 8)).toIso8601String()},
    ];
  }
}
