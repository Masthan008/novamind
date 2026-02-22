import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/promptcraft_models.dart';

class PromptcraftExamScreen extends StatefulWidget {
  final PromptLevel level;
  final int levelNumber;

  const PromptcraftExamScreen({
    super.key,
    required this.level,
    required this.levelNumber,
  });

  @override
  State<PromptcraftExamScreen> createState() => _PromptcraftExamScreenState();
}

class _PromptcraftExamScreenState extends State<PromptcraftExamScreen>
    with TickerProviderStateMixin {
  int _currentQuestion = 0;
  final Map<int, int> _selectedAnswers = {};
  bool _showResults = false;
  late AnimationController _celebrationController;

  List<PromptExamQuestion> get _questions => widget.level.examQuestions;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  int get _correctCount {
    int count = 0;
    for (var entry in _selectedAnswers.entries) {
      if (entry.value == _questions[entry.key].correctIndex) count++;
    }
    return count;
  }

  int get _scorePercent => (_correctCount * 100 / _questions.length).round();
  bool get _passed => _scorePercent >= 70;

  void _selectAnswer(int questionIndex, int optionIndex) {
    if (_showResults) return;
    setState(() {
      _selectedAnswers[questionIndex] = optionIndex;
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < _questions.length - 1) {
      setState(() => _currentQuestion++);
    }
  }

  void _previousQuestion() {
    if (_currentQuestion > 0) {
      setState(() => _currentQuestion--);
    }
  }

  void _submitExam() {
    if (_selectedAnswers.length < _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please answer all ${_questions.length} questions',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.orangeAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _showResults = true);

    if (_passed) {
      _celebrationController.forward();
      // Save progress
      final box = Hive.box('user_prefs');
      box.put('promptcraft_level_${widget.levelNumber}_complete', true);
      box.put('promptcraft_level_${widget.levelNumber}_score', _scorePercent);
      final currentLevel = box.get('promptcraft_current_level', defaultValue: 1);
      if (widget.levelNumber >= currentLevel) {
        box.put('promptcraft_current_level', widget.levelNumber + 1);
      }
    }
  }

  void _retry() {
    setState(() {
      _currentQuestion = 0;
      _selectedAnswers.clear();
      _showResults = false;
    });
    _celebrationController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white70),
          onPressed: () => Navigator.pop(context, _passed),
        ),
        title: Text(
          'Level ${widget.levelNumber} Exam',
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _showResults ? _buildResultsView() : _buildQuestionView(),
    );
  }

  Widget _buildQuestionView() {
    final question = _questions[_currentQuestion];

    return Column(
      children: [
        // Progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${_currentQuestion + 1}/${_questions.length}',
                    style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
                  ),
                  Text(
                    '${_selectedAnswers.length}/${_questions.length} answered',
                    style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (_currentQuestion + 1) / _questions.length,
                  backgroundColor: Colors.white.withOpacity(0.05),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFFF6B6B)),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
        // Question
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.question,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ).animate().fadeIn(duration: 300.ms),
                const SizedBox(height: 24),
                // Options
                ...List.generate(question.options.length, (index) {
                  final isSelected = _selectedAnswers[_currentQuestion] == index;

                  return GestureDetector(
                    onTap: () => _selectAnswer(_currentQuestion, index),
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF6C63FF).withOpacity(0.2)
                            : const Color(0xFF12121F),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF6C63FF)
                              : Colors.white.withOpacity(0.06),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? const Color(0xFF6C63FF)
                                  : Colors.white.withOpacity(0.06),
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + index), // A, B, C, D
                                style: GoogleFonts.poppins(
                                  color: isSelected ? Colors.white : Colors.white54,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              question.options[index],
                              style: GoogleFonts.poppins(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: Color(0xFF6C63FF), size: 20),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.1);
                }),
              ],
            ),
          ),
        ),
        // Navigation buttons
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              if (_currentQuestion > 0)
                Expanded(
                  child: GestureDetector(
                    onTap: _previousQuestion,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          '← Previous',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (_currentQuestion > 0) const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: _currentQuestion < _questions.length - 1
                      ? _nextQuestion
                      : _submitExam,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _currentQuestion < _questions.length - 1
                            ? [const Color(0xFF6C63FF), const Color(0xFF9C88FF)]
                            : [const Color(0xFF00E676), const Color(0xFF69F0AE)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        _currentQuestion < _questions.length - 1 ? 'Next →' : 'Submit Exam',
                        style: GoogleFonts.poppins(
                          color: _currentQuestion < _questions.length - 1
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Score circle
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: _passed
                    ? [Colors.greenAccent.withOpacity(0.3), Colors.greenAccent.withOpacity(0.05)]
                    : [Colors.redAccent.withOpacity(0.3), Colors.redAccent.withOpacity(0.05)],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_scorePercent%',
                    style: GoogleFonts.orbitron(
                      color: _passed ? Colors.greenAccent : Colors.redAccent,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$_correctCount/${_questions.length}',
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 20),
          // Result message
          Text(
            _passed ? '🎉 Level Complete!' : '😔 Not Quite',
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _passed
                ? 'You\'ve unlocked Level ${widget.levelNumber + 1}!'
                : 'You need 70% to pass. Review the lessons and try again.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 30),
          // Review answers
          ...List.generate(_questions.length, (index) {
            final question = _questions[index];
            final selected = _selectedAnswers[index] ?? -1;
            final isCorrect = selected == question.correctIndex;

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF12121F),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isCorrect
                      ? Colors.greenAccent.withOpacity(0.3)
                      : Colors.redAccent.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        color: isCorrect ? Colors.greenAccent : Colors.redAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Q${index + 1}: ${question.question}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!isCorrect) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Your answer: ${question.options[selected]}',
                      style: GoogleFonts.poppins(
                        color: Colors.redAccent.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Correct: ${question.options[question.correctIndex]}',
                      style: GoogleFonts.poppins(
                        color: Colors.greenAccent.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    question.explanation,
                    style: GoogleFonts.poppins(
                      color: Colors.white38,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 20),
          // Action buttons
          if (_passed)
            GestureDetector(
              onTap: () => Navigator.pop(context, true),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00E676), Color(0xFF69F0AE)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    'Continue to Level ${widget.levelNumber + 1} →',
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            )
          else
            GestureDetector(
              onTap: _retry,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    'Retry Exam',
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
}
