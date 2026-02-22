import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/promptcraft_models.dart';
import '../../services/ai_service.dart';

class PromptcraftBattleScreen extends StatefulWidget {
  final int levelNumber;

  const PromptcraftBattleScreen({super.key, required this.levelNumber});

  @override
  State<PromptcraftBattleScreen> createState() => _PromptcraftBattleScreenState();
}

class _PromptcraftBattleScreenState extends State<PromptcraftBattleScreen> {
  final TextEditingController _promptController = TextEditingController();
  bool _isSubmitting = false;
  bool _showComparison = false;
  String? _aiOutput;
  int? _score;
  List<PromptBattleSubmission> _otherSubmissions = [];
  String? _evaluationText;
  int _currentTaskId = 1;

  final List<Map<String, String>> _battleTasks = const [
    {
      'title': 'Study Plan Generator',
      'description': 'Write a prompt that generates a complete 2-week study plan for a CS student preparing for final exams in 3 subjects.',
    },
    {
      'title': 'Code Reviewer',
      'description': 'Write a prompt that makes AI review a Python function and provide detailed feedback on bugs, performance, and style.',
    },
    {
      'title': 'Career Advisor',
      'description': 'Write a prompt that generates a personalized 6-month career roadmap for a student transitioning into AI/ML engineering.',
    },
  ];

  Map<String, String> get _currentTask => _battleTasks[(_currentTaskId - 1) % _battleTasks.length];

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _submitPrompt() async {
    if (_promptController.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      // Get AI output using the student's prompt
      final output = await AIService.getResponse(_promptController.text.trim());
      
      // Score the prompt using AI
      final scorePrompt = '''Rate this prompt on a scale of 0-100 based on:
- Completeness (20 pts): Does it cover all aspects of the task?
- Specificity (20 pts): Is it specific enough for good results?
- Structure (20 pts): Is it well-organized?
- Creativity (20 pts): Does it use advanced techniques?
- Result Quality (20 pts): Would this produce excellent output?

Task: ${_currentTask['description']}
Student's Prompt: ${_promptController.text.trim()}

Respond with ONLY a number between 0-100.''';

      final scoreResponse = await AIService.getResponse(scorePrompt);
      final parsedScore = int.tryParse(
        scoreResponse.replaceAll(RegExp(r'[^0-9]'), '').substring(0, 
          scoreResponse.replaceAll(RegExp(r'[^0-9]'), '').length.clamp(0, 3))
      ) ?? 65;
      final clampedScore = parsedScore.clamp(0, 100);

      // Save to Supabase
      try {
        final user = Supabase.instance.client.auth.currentUser;
        await Supabase.instance.client.from('promptcraft_battles').insert({
          'student_id': user?.id != null ? user!.id.hashCode : 0,
          'student_name': user?.userMetadata?['name'] ?? 'Anonymous',
          'task_id': _currentTaskId,
          'prompt_text': _promptController.text.trim(),
          'ai_output': output,
          'score': clampedScore,
        });
      } catch (e) {
        debugPrint('Supabase save failed: $e');
      }

      // Fetch other submissions
      try {
        final response = await Supabase.instance.client
            .from('promptcraft_battles')
            .select()
            .eq('task_id', _currentTaskId)
            .order('score', ascending: false)
            .limit(3);

        _otherSubmissions = (response as List)
            .map((e) => PromptBattleSubmission.fromJson(e))
            .toList();
      } catch (e) {
        debugPrint('Fetch submissions failed: $e');
      }

      // Get comparison evaluation
      if (_otherSubmissions.length >= 2) {
        try {
          final evalPrompt = '''Compare these prompt submissions for the task: "${_currentTask['description']}"

Submission 1 (Score: $clampedScore): ${_promptController.text.trim()}

Submission 2 (Score: ${_otherSubmissions.first.score}): ${_otherSubmissions.first.promptText}

Give brief pros/cons for each (2-3 bullets each). Be constructive. Format with **bold** headers.''';

          _evaluationText = await AIService.getResponse(evalPrompt);
        } catch (e) {
          debugPrint('Evaluation failed: $e');
        }
      }

      setState(() {
        _aiOutput = output;
        _score = clampedScore;
        _showComparison = true;
        _isSubmitting = false;
      });
    } catch (e) {
      setState(() => _isSubmitting = false);
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
          'Prompt Battle Arena',
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _showComparison ? _buildComparisonView() : _buildSubmissionView(),
    );
  }

  Widget _buildSubmissionView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orangeAccent.withOpacity(0.15),
                  Colors.deepOrangeAccent.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orangeAccent.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flash_on, color: Colors.orangeAccent, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Battle Task #$_currentTaskId',
                      style: GoogleFonts.orbitron(
                        color: Colors.orangeAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _currentTask['title']!,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _currentTask['description']!,
                  style: GoogleFonts.poppins(
                    color: Colors.white60,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 20),
          // Prompt input
          Text(
            'Your Prompt',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF12121F),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: TextField(
              controller: _promptController,
              maxLines: 10,
              minLines: 6,
              style: GoogleFonts.firaCode(
                color: Colors.white,
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: 'Write your best prompt here...\n\nTip: Use Role, Context, Task, Format, and Constraints for maximum score!',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.white24,
                  fontSize: 13,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Submit button
          GestureDetector(
            onTap: _isSubmitting ? null : _submitPrompt,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isSubmitting
                      ? [Colors.grey, Colors.grey.shade700]
                      : [Colors.orangeAccent, Colors.deepOrangeAccent],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: _isSubmitting
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'AI is evaluating...',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        '⚔️ Submit & Battle',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Task switcher
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_battleTasks.length, (index) {
              final isActive = index + 1 == _currentTaskId;
              return GestureDetector(
                onTap: () => setState(() => _currentTaskId = index + 1),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 30 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: isActive ? Colors.orangeAccent : Colors.white.withOpacity(0.15),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Score
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  (_score! >= 70 ? Colors.greenAccent : Colors.orangeAccent).withOpacity(0.3),
                  (_score! >= 70 ? Colors.greenAccent : Colors.orangeAccent).withOpacity(0.05),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_score',
                    style: GoogleFonts.orbitron(
                      color: _score! >= 70 ? Colors.greenAccent : Colors.orangeAccent,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '/100',
                    style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 16),
          Text(
            _score! >= 80 ? '🔥 Excellent Prompt!' : _score! >= 60 ? '💪 Good Effort!' : '📝 Keep Practicing!',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          // Your output
          _buildOutputCard('Your AI Output', _aiOutput ?? '', const Color(0xFF6C63FF)),
          const SizedBox(height: 16),
          // Evaluation
          if (_evaluationText != null) ...[
            _buildOutputCard('AI Evaluation', _evaluationText!, Colors.cyanAccent),
            const SizedBox(height: 16),
          ],
          // Other submissions
          if (_otherSubmissions.isNotEmpty) ...[
            Text(
              'Other Submissions',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ..._otherSubmissions.take(2).map((sub) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF12121F),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        sub.studentName,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${sub.score}/100',
                          style: GoogleFonts.poppins(
                            color: Colors.orangeAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    sub.promptText,
                    style: GoogleFonts.firaCode(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )),
          ],
          const SizedBox(height: 20),
          // Try again button
          GestureDetector(
            onTap: () {
              setState(() {
                _showComparison = false;
                _promptController.clear();
                _aiOutput = null;
                _score = null;
                _evaluationText = null;
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.orangeAccent, Colors.deepOrangeAccent],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  '⚔️ Battle Again',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildOutputCard(String title, String content, Color accentColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12121F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: accentColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.poppins(
              color: Colors.white60,
              fontSize: 12,
              height: 1.5,
            ),
            maxLines: 15,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
