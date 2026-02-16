import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/quiz_service.dart';
import 'quiz_screen.dart';

/// Screen that shows Data Structures quiz topics (units) as tiles.
class QuizTopicsScreen extends StatefulWidget {
  const QuizTopicsScreen({super.key});

  @override
  State<QuizTopicsScreen> createState() => _QuizTopicsScreenState();
}

class _QuizTopicsScreenState extends State<QuizTopicsScreen> {
  // Topics with icons and colors
  static const List<_TopicInfo> _topics = [
    _TopicInfo(
      topic: 'Arrays',
      subtitle: 'Unit 1 — Linear Data Structures',
      icon: Icons.view_array_rounded,
      color: Color(0xFF42A5F5),
      gradient: [Color(0xFF42A5F5), Color(0xFF1565C0)],
    ),
    _TopicInfo(
      topic: 'Linked Lists',
      subtitle: 'Unit 2 — Pointers & Nodes',
      icon: Icons.link_rounded,
      color: Color(0xFF66BB6A),
      gradient: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
    ),
    _TopicInfo(
      topic: 'Stacks',
      subtitle: 'Unit 3 — LIFO Structures',
      icon: Icons.layers_rounded,
      color: Color(0xFFFF7043),
      gradient: [Color(0xFFFF7043), Color(0xFFD84315)],
    ),
    _TopicInfo(
      topic: 'Queues',
      subtitle: 'Unit 4 — FIFO Structures',
      icon: Icons.queue_rounded,
      color: Color(0xFFAB47BC),
      gradient: [Color(0xFFAB47BC), Color(0xFF6A1B9A)],
    ),
    _TopicInfo(
      topic: 'Trees',
      subtitle: 'Unit 5 — Hierarchical Structures',
      icon: Icons.account_tree_rounded,
      color: Color(0xFFFFCA28),
      gradient: [Color(0xFFFFCA28), Color(0xFFF9A825)],
    ),
    _TopicInfo(
      topic: 'Sorting',
      subtitle: 'Unit 6 — Sorting Algorithms',
      icon: Icons.sort_rounded,
      color: Color(0xFF26C6DA),
      gradient: [Color(0xFF26C6DA), Color(0xFF00838F)],
    ),
  ];

  final Map<String, Map<String, int>> _topicStats = {};
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    for (final t in _topics) {
      final stats = await QuizService.getTopicStats(t.topic);
      if (mounted) {
        setState(() => _topicStats[t.topic] = stats);
      }
    }
    if (mounted) setState(() => _loadingStats = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'DS Quiz Practice',
          style: GoogleFonts.orbitron(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Choose a Topic',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
            const SizedBox(height: 4),
            Text(
              '10 random questions per attempt. No two quizzes are the same!',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white54,
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
            const SizedBox(height: 24),

            // Topic Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.95,
                ),
                itemCount: _topics.length,
                itemBuilder: (context, index) {
                  final t = _topics[index];
                  final stats = _topicStats[t.topic];
                  return _buildTopicTile(t, stats, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicTile(_TopicInfo info, Map<String, int>? stats, int index) {
    final attempted = stats?['total'] ?? 0;
    final correct = stats?['correct'] ?? 0;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuizScreen(topic: info.topic),
          ),
        );
        // Refresh stats on return
        _loadStats();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              info.gradient[0].withOpacity(0.25),
              info.gradient[1].withOpacity(0.10),
            ],
          ),
          border: Border.all(
            color: info.color.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: info.color.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: info.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(info.icon, color: info.color, size: 26),
            ),
            const Spacer(),
            // Title
            Text(
              info.topic,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            // Subtitle
            Text(
              info.subtitle,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white54,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // Stats
            if (attempted > 0)
              Text(
                '$correct/$attempted correct',
                style: GoogleFonts.sourceCodePro(
                  fontSize: 12,
                  color: info.color.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              Text(
                'Not attempted',
                style: GoogleFonts.sourceCodePro(
                  fontSize: 12,
                  color: Colors.white38,
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (100 + index * 80).ms).scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          delay: (100 + index * 80).ms,
          duration: 400.ms,
          curve: Curves.easeOut,
        );
  }
}

/// Internal topic metadata.
class _TopicInfo {
  final String topic;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<Color> gradient;

  const _TopicInfo({
    required this.topic,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.gradient,
  });
}
