import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/promptcraft_data.dart';
import 'promptcraft_level_screen.dart';

class PromptcraftHomeScreen extends StatefulWidget {
  const PromptcraftHomeScreen({super.key});

  @override
  State<PromptcraftHomeScreen> createState() => _PromptcraftHomeScreenState();
}

class _PromptcraftHomeScreenState extends State<PromptcraftHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _rocketController;
  late AnimationController _pulseController;
  late Box _progressBox;
  int _currentLevel = 1;

  @override
  void initState() {
    super.initState();
    _rocketController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _loadProgress();
  }

  void _loadProgress() {
    _progressBox = Hive.box('user_prefs');
    setState(() {
      _currentLevel = _progressBox.get('promptcraft_current_level', defaultValue: 1);
    });
  }

  bool _isLevelComplete(int level) {
    return _progressBox.get('promptcraft_level_${level}_complete', defaultValue: false);
  }

  int _getLevelScore(int level) {
    return _progressBox.get('promptcraft_level_${level}_score', defaultValue: 0);
  }

  bool _isLevelUnlocked(int level) {
    if (level == 1) return true;
    return _isLevelComplete(level - 1);
  }

  @override
  void dispose() {
    _rocketController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              'PromptCraft',
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          // Progress indicator
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${_currentLevel - 1}/10',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Header
              _buildHeader(),
              const SizedBox(height: 30),
              // Road with levels
              _buildRoadMap(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final completedLevels = List.generate(10, (i) => i + 1)
        .where((l) => _isLevelComplete(l))
        .length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF6B6B).withOpacity(0.15),
            const Color(0xFFFF8E53).withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            'Prompt Engineering Journey',
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Master the art of talking to AI',
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: completedLevels / 10,
              backgroundColor: Colors.white.withOpacity(0.05),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFFF6B6B)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$completedLevels of 10 levels completed',
            style: GoogleFonts.poppins(
              color: Colors.white38,
              fontSize: 11,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2);
  }

  Widget _buildRoadMap() {
    return CustomPaint(
      painter: _RoadPainter(
        levelCount: 10,
        currentLevel: _currentLevel,
        completedLevels: List.generate(10, (i) => _isLevelComplete(i + 1)),
        pulseValue: _pulseController.value,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: List.generate(10, (index) {
            final levelNum = index + 1;
            return _buildLevelNode(levelNum, index);
          }),
        ),
      ),
    );
  }

  Widget _buildLevelNode(int levelNum, int index) {
    final isComplete = _isLevelComplete(levelNum);
    final isUnlocked = _isLevelUnlocked(levelNum);
    final isCurrent = levelNum == _currentLevel;
    final level = promptCraftLevels[levelNum - 1];
    final score = _getLevelScore(levelNum);

    final isEven = index % 2 == 0;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.only(
            left: isEven ? 0 : 80,
            right: isEven ? 80 : 0,
          ),
          child: GestureDetector(
            onTap: isUnlocked
                ? () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PromptcraftLevelScreen(
                          level: level,
                          levelNumber: levelNum,
                        ),
                      ),
                    );
                    // Refresh progress on return
                    _loadProgress();
                  }
                : null,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isComplete
                    ? const Color(0xFF1A2A1A)
                    : isCurrent
                        ? const Color(0xFF1A1A2E)
                        : const Color(0xFF12121F),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isComplete
                      ? Colors.greenAccent.withOpacity(0.4)
                      : isCurrent
                          ? Color.lerp(
                              Colors.white.withOpacity(0.3),
                              Colors.cyanAccent.withOpacity(0.6),
                              _pulseController.value,
                            )!
                          : isUnlocked
                              ? Colors.white.withOpacity(0.1)
                              : Colors.white.withOpacity(0.05),
                  width: isCurrent ? 2 : 1,
                ),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.15 * _pulseController.value),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ]
                    : isComplete
                        ? [
                            BoxShadow(
                              color: Colors.greenAccent.withOpacity(0.1),
                              blurRadius: 12,
                            ),
                          ]
                        : null,
              ),
              child: Row(
                children: [
                  // Level number circle
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isComplete
                          ? const LinearGradient(colors: [Color(0xFF00E676), Color(0xFF69F0AE)])
                          : isCurrent
                              ? const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF9C88FF)])
                              : null,
                      color: !isComplete && !isCurrent
                          ? Colors.white.withOpacity(isUnlocked ? 0.08 : 0.03)
                          : null,
                    ),
                    child: Center(
                      child: isComplete
                          ? const Icon(Icons.check, color: Colors.white, size: 22)
                          : !isUnlocked
                              ? Icon(Icons.lock, color: Colors.white.withOpacity(0.3), size: 18)
                              : Text(
                                  '$levelNum',
                                  style: GoogleFonts.orbitron(
                                    color: isCurrent ? Colors.white : Colors.white54,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Level info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                level.title,
                                style: GoogleFonts.poppins(
                                  color: isUnlocked ? Colors.white : Colors.white38,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isComplete)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$score%',
                                  style: GoogleFonts.poppins(
                                    color: Colors.greenAccent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          level.description,
                          style: GoogleFonts.poppins(
                            color: isUnlocked ? Colors.white38 : Colors.white24,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (isUnlocked && !isComplete)
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white.withOpacity(0.3),
                      size: 16,
                    ),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(delay: (100 * index).ms, duration: 400.ms).slideX(
              begin: isEven ? -0.3 : 0.3,
              end: 0,
            );
      },
    );
  }
}

// Road path painter
class _RoadPainter extends CustomPainter {
  final int levelCount;
  final int currentLevel;
  final List<bool> completedLevels;
  final double pulseValue;

  _RoadPainter({
    required this.levelCount,
    required this.currentLevel,
    required this.completedLevels,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dashPaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.15)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw connecting dashed lines between nodes
    final nodeHeight = 92.0; // Approximate height of each node + margin
    for (int i = 0; i < levelCount - 1; i++) {
      final startY = (i * nodeHeight) + nodeHeight * 0.65;
      final endY = ((i + 1) * nodeHeight) + nodeHeight * 0.35;
      
      final isEven = i % 2 == 0;
      final nextIsEven = (i + 1) % 2 == 0;
      
      final startX = isEven ? size.width * 0.3 : size.width * 0.7;
      final endX = nextIsEven ? size.width * 0.3 : size.width * 0.7;

      // Draw dashed curve
      final path = Path();
      path.moveTo(startX, startY);
      path.cubicTo(
        startX, startY + (endY - startY) * 0.5,
        endX, endY - (endY - startY) * 0.5,
        endX, endY,
      );

      if (completedLevels[i]) {
        final completedPaint = Paint()
          ..color = Colors.greenAccent.withOpacity(0.2)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
        canvas.drawPath(path, completedPaint);
      } else {
        _drawDashedPath(canvas, path, dashPaint);
      }
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final segLength = min(8.0, metric.length - distance);
        final segment = metric.extractPath(distance, distance + segLength);
        canvas.drawPath(segment, paint);
        distance += 16;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RoadPainter oldDelegate) => true;
}
