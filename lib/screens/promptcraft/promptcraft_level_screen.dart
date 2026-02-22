import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/promptcraft_models.dart';
import '../../modules/ai/nova_chat_screen.dart';
import 'promptcraft_exam_screen.dart';
import 'promptcraft_battle_screen.dart';
import 'promptcraft_image_task_screen.dart';

class PromptcraftLevelScreen extends StatefulWidget {
  final PromptLevel level;
  final int levelNumber;

  const PromptcraftLevelScreen({
    super.key,
    required this.level,
    required this.levelNumber,
  });

  @override
  State<PromptcraftLevelScreen> createState() => _PromptcraftLevelScreenState();
}

class _PromptcraftLevelScreenState extends State<PromptcraftLevelScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  late int _totalPages;

  @override
  void initState() {
    super.initState();
    // Lessons + 1 action card (exam or special)
    _totalPages = widget.level.lessons.length + 1;
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Level ${widget.levelNumber}',
              style: GoogleFonts.orbitron(
                color: Colors.white54,
                fontSize: 11,
              ),
            ),
            Text(
              widget.level.title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_currentPage + 1}/$_totalPages',
              style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress dots
          _buildProgressDots(),
          // Page content
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _totalPages,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                if (index < widget.level.lessons.length) {
                  return _buildLessonCard(widget.level.lessons[index], index);
                } else {
                  return _buildActionCard();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDots() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_totalPages, (index) {
          final isActive = index == _currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isActive
                  ? const Color(0xFFFF6B6B)
                  : Colors.white.withOpacity(0.15),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLessonCard(PromptLesson lesson, int index) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Asset area (top 55%)
          Container(
            height: MediaQuery.of(context).size.height * 0.38,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF12121F),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: _buildAssetWidget(lesson.assetPath),
          ),
          // Title
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              lesson.title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
          const SizedBox(height: 10),
          // Description
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              lesson.description,
              style: GoogleFonts.poppins(
                color: Colors.white60,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 20),
          // Try in Nova AI button
          if (lesson.tryPrompt != null)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NovaChatScreen(),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6C63FF).withOpacity(0.2),
                      const Color(0xFF9C88FF).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.auto_awesome, color: Color(0xFF9C88FF), size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Try in Sentinel AI',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Test this prompt pattern live',
                            style: GoogleFonts.poppins(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 16),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
          // Swipe hint
          const SizedBox(height: 24),
          Text(
            'Swipe for next →',
            style: GoogleFonts.poppins(
              color: Colors.white24,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildAssetWidget(String? assetPath) {
    if (assetPath == null) {
      return Center(
        child: Icon(
          Icons.auto_awesome,
          color: Colors.white.withOpacity(0.1),
          size: 60,
        ),
      );
    }

    // Check if the file exists as an asset
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Show a styled placeholder when asset doesn't exist yet
          return _buildAssetPlaceholder(assetPath);
        },
      ),
    );
  }

  Widget _buildAssetPlaceholder(String assetPath) {
    final isSvg = assetPath.endsWith('.svg');
    final isFlowchart = assetPath.contains('flowchart');
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFlowchart ? Icons.account_tree : Icons.image_outlined,
            color: const Color(0xFFFF6B6B).withOpacity(0.3),
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            isFlowchart ? 'Flowchart' : 'Illustration',
            style: GoogleFonts.poppins(
              color: Colors.white38,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            assetPath.split('/').last,
            style: GoogleFonts.firaCode(
              color: Colors.white24,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard() {
    // Special screens for Level 7 and Level 8
    if (widget.levelNumber == 7 && widget.level.isSpecialLevel) {
      return _buildSpecialActionCard(
        title: 'Image Prompt Challenge',
        description: 'Write prompts to describe target images. AI scores your accuracy.',
        icon: Icons.image_search,
        color: const Color(0xFFFF6B6B),
        buttonLabel: 'Start Image Challenge',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PromptcraftImageTaskScreen(levelNumber: widget.levelNumber),
          ),
        ),
        showExamButton: true,
      );
    }

    if (widget.levelNumber == 8 && widget.level.isSpecialLevel) {
      return _buildSpecialActionCard(
        title: 'Prompt Battle Arena',
        description: 'Write the best prompt for a given task. Compete with other students.',
        icon: Icons.flash_on,
        color: Colors.orangeAccent,
        buttonLabel: 'Enter Battle Arena',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PromptcraftBattleScreen(levelNumber: widget.levelNumber),
          ),
        ),
        showExamButton: true,
      );
    }

    return _buildExamStartCard();
  }

  Widget _buildSpecialActionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String buttonLabel,
    required VoidCallback onTap,
    required bool showExamButton,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [color.withOpacity(0.3), color.withOpacity(0.05)],
              ),
            ),
            child: Icon(icon, color: color, size: 48),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 30),
          // Special action button
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    buttonLabel,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showExamButton) ...[
            const SizedBox(height: 16),
            _buildTakeExamButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildExamStartCard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.greenAccent.withOpacity(0.3),
                  Colors.greenAccent.withOpacity(0.05),
                ],
              ),
            ),
            child: const Icon(Icons.quiz, color: Colors.greenAccent, size: 48),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 24),
          Text(
            'Ready for the Exam?',
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '5 questions • Score 70% to pass\nUnlock the next level!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 30),
          _buildTakeExamButton(),
        ],
      ),
    );
  }

  Widget _buildTakeExamButton() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => PromptcraftExamScreen(
              level: widget.level,
              levelNumber: widget.levelNumber,
            ),
          ),
        );
        if (result == true && mounted) {
          Navigator.pop(context); // Go back to home to see updated progress
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00E676), Color(0xFF69F0AE)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.greenAccent.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.quiz, color: Colors.black87, size: 20),
            const SizedBox(width: 10),
            Text(
              'Take Exam',
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
