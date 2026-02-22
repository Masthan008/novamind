import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/ai_service.dart';
import '../../models/promptcraft_models.dart';

class PromptcraftImageTaskScreen extends StatefulWidget {
  final int levelNumber;

  const PromptcraftImageTaskScreen({super.key, required this.levelNumber});

  @override
  State<PromptcraftImageTaskScreen> createState() => _PromptcraftImageTaskScreenState();
}

class _PromptcraftImageTaskScreenState extends State<PromptcraftImageTaskScreen> {
  final TextEditingController _promptController = TextEditingController();
  int _currentTask = 0;
  bool _isEvaluating = false;
  ImageTaskResult? _result;

  final List<Map<String, String>> _tasks = const [
    {
      'asset': 'assets/promptcraft/level7/l7_task_target_1.png',
      'title': 'Robot Student',
      'description': 'Describe this image: A robot student at a futuristic desk reading a holographic book.',
    },
    {
      'asset': 'assets/promptcraft/level7/l7_task_target_2.png',
      'title': 'Brain-Chip Connection',
      'description': 'Describe this image: A brain connected to a computer chip with neural network lines.',
    },
    {
      'asset': 'assets/promptcraft/level7/l7_task_target_3.png',
      'title': 'Code City',
      'description': 'Describe this image: A city made of programming symbols and code blocks.',
    },
    {
      'asset': 'assets/promptcraft/level7/l7_task_target_4.png',
      'title': 'Space Graduation',
      'description': 'Describe this image: A graduation cap floating in space among stars and planets.',
    },
    {
      'asset': 'assets/promptcraft/level7/l7_task_target_5.png',
      'title': 'Data Flow',
      'description': 'Describe this image: Data particles flowing through a network with glowing nodes.',
    },
  ];

  Future<void> _evaluate() async {
    if (_promptController.text.trim().isEmpty) return;

    setState(() {
      _isEvaluating = true;
      _result = null;
    });

    try {
      final task = _tasks[_currentTask];
      final evalPrompt = '''You are an expert image prompt evaluator. A student was shown a target image and asked to write an image generation prompt to recreate it.

Target Image Description: ${task['description']}

Student's Prompt: ${_promptController.text.trim()}

Evaluate how well the student's prompt would recreate the target image. Return your evaluation as JSON only (no markdown, no extra text):

{
  "similarity_score": <0-100 overall match>,
  "color_match": <0-100 how well colors are specified>,
  "composition_match": <0-100 how well layout/composition is described>,
  "style_match": <0-100 how well art style is specified>,
  "missing_elements": ["element 1", "element 2"],
  "improvement_tips": ["tip 1", "tip 2", "tip 3"]
}''';

      final response = await AIService.getResponse(evalPrompt);
      
      // Parse JSON from response
      try {
        // Extract JSON from response (might have surrounding text)
        final jsonStart = response.indexOf('{');
        final jsonEnd = response.lastIndexOf('}');
        if (jsonStart != -1 && jsonEnd != -1) {
          final jsonStr = response.substring(jsonStart, jsonEnd + 1);
          final json = jsonDecode(jsonStr);
          setState(() {
            _result = ImageTaskResult.fromJson(json);
            _isEvaluating = false;
          });
        } else {
          throw Exception('No JSON found');
        }
      } catch (e) {
        // Fallback if JSON parsing fails
        setState(() {
          _result = ImageTaskResult(
            similarityScore: 50,
            colorMatch: 50,
            compositionMatch: 50,
            styleMatch: 50,
            missingElements: ['Could not parse detailed feedback'],
            improvementTips: ['Try being more specific about colors, composition, and art style'],
          );
          _isEvaluating = false;
        });
      }
    } catch (e) {
      setState(() => _isEvaluating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
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
        title: Text(
          'Image Prompt Lab',
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
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
              '${_currentTask + 1}/${_tasks.length}',
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Target image
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF12121F),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.2)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  _tasks[_currentTask]['asset']!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, color: const Color(0xFFFF6B6B).withOpacity(0.3), size: 48),
                          const SizedBox(height: 8),
                          Text(
                            _tasks[_currentTask]['title']!,
                            style: GoogleFonts.poppins(
                              color: Colors.white38,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _tasks[_currentTask]['description']!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.white24,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                '🎯 Target: ${_tasks[_currentTask]['title']}',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Task navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_tasks.length, (index) {
                final isActive = index == _currentTask;
                return GestureDetector(
                  onTap: () => setState(() {
                    _currentTask = index;
                    _result = null;
                    _promptController.clear();
                  }),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 28 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: isActive
                          ? const Color(0xFFFF6B6B)
                          : Colors.white.withOpacity(0.15),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            // Prompt input
            Text(
              'Your Image Prompt',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Describe this image as if you\'re writing a prompt for an AI image generator',
              style: GoogleFonts.poppins(
                color: Colors.white38,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF12121F),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: TextField(
                controller: _promptController,
                maxLines: 6,
                minLines: 4,
                style: GoogleFonts.firaCode(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'A robot student sitting at a futuristic desk...\nInclude: subject, style, colors, composition, lighting',
                  hintStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.2), fontSize: 12),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Evaluate button
            GestureDetector(
              onTap: _isEvaluating ? null : _evaluate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isEvaluating
                        ? [Colors.grey, Colors.grey.shade700]
                        : [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: _isEvaluating
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            ),
                            const SizedBox(width: 10),
                            Text('Evaluating...', style: GoogleFonts.poppins(color: Colors.white)),
                          ],
                        )
                      : Text(
                          '🔍 Evaluate My Prompt',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
            // Results
            if (_result != null) ...[
              const SizedBox(height: 24),
              _buildResultsSection(),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Evaluation Results',
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(),
        const SizedBox(height: 16),
        // Score circles
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildScoreCircle('Overall', _result!.similarityScore, const Color(0xFFFF6B6B)),
            _buildScoreCircle('Color', _result!.colorMatch, Colors.cyanAccent),
            _buildScoreCircle('Compose', _result!.compositionMatch, Colors.purpleAccent),
            _buildScoreCircle('Style', _result!.styleMatch, Colors.orangeAccent),
          ],
        ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.8, 0.8)),
        const SizedBox(height: 20),
        // Missing elements
        if (_result!.missingElements.isNotEmpty) ...[
          Text(
            '❌ Missing Elements',
            style: GoogleFonts.poppins(
              color: Colors.redAccent,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(_result!.missingElements.length, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 13)),
                Expanded(
                  child: Text(
                    _result!.missingElements[i],
                    style: GoogleFonts.poppins(color: Colors.white60, fontSize: 13),
                  ),
                ),
              ],
            ),
          )),
        ],
        const SizedBox(height: 16),
        // Tips
        if (_result!.improvementTips.isNotEmpty) ...[
          Text(
            '💡 Improvement Tips',
            style: GoogleFonts.poppins(
              color: Colors.greenAccent,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(_result!.improvementTips.length, (i) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.greenAccent.withOpacity(0.1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${i + 1}. ', style: GoogleFonts.poppins(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.w600)),
                Expanded(
                  child: Text(
                    _result!.improvementTips[i],
                    style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12, height: 1.4),
                  ),
                ),
              ],
            ),
          )),
        ],
      ],
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _buildScoreCircle(String label, int score, Color color) {
    return Column(
      children: [
        SizedBox(
          width: 68,
          height: 68,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: score / 100,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation(color),
                strokeWidth: 5,
              ),
              Text(
                '$score',
                style: GoogleFonts.orbitron(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white38,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
