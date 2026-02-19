import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/ds_question_model.dart';
import '../../services/quiz_service.dart';
import '../../services/ai_service.dart';

/// Native channel for FLAG_SECURE (screenshot prevention).
const _secureChannel = MethodChannel('com.example.fluxflow/window_security');

/// Interactive quiz screen that loads random questions for a topic.
/// Anti-cheating: screenshot prevention (FLAG_SECURE) + app-switch detection.
class QuizScreen extends StatefulWidget {
  final String topic;
  const QuizScreen({super.key, required this.topic});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with WidgetsBindingObserver {
  List<DsQuestion> _questions = [];
  bool _isLoading = true;
  String? _error;

  int _currentIndex = 0;
  String? _selectedOption; // 'A', 'B', 'C', 'D'
  bool _answered = false;
  int _score = 0;
  bool _quizFinished = false;

  // Anti-cheating state
  bool _quizStarted = false; // true once first question is shown
  bool _showingCheatWarning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _enableSecureMode();
    _loadQuestions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disableSecureMode();
    super.dispose();
  }

  // ──────────── Screenshot Prevention ────────────

  Future<void> _enableSecureMode() async {
    try {
      await _secureChannel.invokeMethod('enableSecure');
    } catch (_) {
      // Not supported on this platform — fail silently
    }
  }

  Future<void> _disableSecureMode() async {
    try {
      await _secureChannel.invokeMethod('disableSecure');
    } catch (_) {}
  }

  // ──────────── App Switch Detection ────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Only trigger if quiz is active (not loading, not finished, not already warning)
    if (state == AppLifecycleState.paused &&
        _quizStarted &&
        !_quizFinished &&
        !_isLoading &&
        !_showingCheatWarning) {
      _onCheatDetected();
    }
  }

  void _onCheatDetected() {
    setState(() => _showingCheatWarning = true);
    HapticFeedback.heavyImpact();

    // Reset quiz state immediately
    setState(() {
      _currentIndex = 0;
      _selectedOption = null;
      _answered = false;
      _score = 0;
      _quizFinished = false;
      _quizStarted = false;
    });

    // Show warning dialog when app comes back to foreground
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
              const SizedBox(width: 10),
              Text(
                'Cheating Detected!',
                style: GoogleFonts.orbitron(
                  color: Colors.redAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'You left the quiz by switching to another app.\n\n'
            'Your progress has been reset and new questions have been loaded.',
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14, height: 1.5),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => _showingCheatWarning = false);
                _loadQuestions(); // Load fresh questions
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withOpacity(0.2),
                foregroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Restart Quiz', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
    });
  }

  // ──────────── Data Loading ────────────

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final questions = await QuizService.getRandomQuiz(widget.topic, 10);

    if (!mounted) return;

    if (questions.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'No questions found for "${widget.topic}".\n\n'
            'The admin needs to seed questions into the ds_questions table in Supabase.';
      });
      return;
    }

    setState(() {
      _questions = questions;
      _isLoading = false;
      _quizStarted = true; // Mark quiz as active — detection now armed
    });
  }

  DsQuestion get _currentQuestion => _questions[_currentIndex];

  void _selectOption(String option) {
    if (_answered) return;

    final isCorrect = option == _currentQuestion.correctOption.toUpperCase();

    setState(() {
      _selectedOption = option;
      _answered = true;
      if (isCorrect) _score++;
    });

    QuizService.submitAnswer(
      questionId: _currentQuestion.id,
      isCorrect: isCorrect,
    );
  }

  void _nextQuestion() {
    if (_currentIndex + 1 >= _questions.length) {
      setState(() => _quizFinished = true);
      return;
    }

    setState(() {
      _currentIndex++;
      _selectedOption = null;
      _answered = false;
    });
  }

  void _showAIExplanation() {
    final question = _currentQuestion;
    final selectedText = question.getOptionText(_selectedOption ?? '');
    final correctText = question.correctAnswerText;

    final prompt =
        'A student answered a Data Structures MCQ incorrectly.\n\n'
        'Question: ${question.questionText}\n'
        'Student\'s Answer: $_selectedOption) $selectedText\n'
        'Correct Answer: ${question.correctOption}) $correctText\n\n'
        'Explain briefly why the student\'s answer is wrong and why the correct '
        'answer is right. Use simple language and include a small code snippet '
        'if helpful. Keep it under 150 words.';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _AIExplanationSheet(prompt: prompt),
    );
  }

  // ──────────── BUILD ────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.topic,
          style: GoogleFonts.orbitron(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        // Anti-cheat badge in app bar
        actions: [
          if (!_isLoading && !_quizFinished)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Tooltip(
                message: 'Screenshot & app-switch protection active',
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.security, color: Colors.redAccent, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'SECURE',
                        style: GoogleFonts.sourceCodePro(
                          fontSize: 10,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? _buildLoading()
          : _error != null
              ? _buildError()
              : _quizFinished
                  ? _buildResults()
                  : _buildQuestion(),
    );
  }

  // ──────── Loading ────────
  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Colors.cyanAccent),
          const SizedBox(height: 16),
          Text('Loading questions…',
              style: GoogleFonts.poppins(color: Colors.white54)),
        ],
      ),
    );
  }

  // ──────── Error ────────
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.quiz_outlined, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadQuestions,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent.withOpacity(0.15),
                foregroundColor: Colors.cyanAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────── Question Card ────────
  Widget _buildQuestion() {
    final q = _currentQuestion;
    final progress = (_currentIndex + 1) / _questions.length;
    final isCorrectAnswer = _selectedOption == q.correctOption.toUpperCase();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress
          Row(
            children: [
              Text(
                'Question ${_currentIndex + 1}/${_questions.length}',
                style: GoogleFonts.sourceCodePro(
                  fontSize: 13,
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'Score: $_score',
                style: GoogleFonts.sourceCodePro(
                  fontSize: 13,
                  color: Colors.amber,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white10,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
            ),
          ),
          const SizedBox(height: 24),

          // Difficulty badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _difficultyColor(q.difficulty).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _difficultyColor(q.difficulty).withOpacity(0.4),
              ),
            ),
            child: Text(
              q.difficulty,
              style: GoogleFonts.sourceCodePro(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _difficultyColor(q.difficulty),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Question text
          Text(
            q.questionText,
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.5,
            ),
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 24),

          // Options
          ...['A', 'B', 'C', 'D'].map((letter) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildOptionCard(letter, q.getOptionText(letter), q),
            );
          }),

          const SizedBox(height: 12),

          // Action buttons after answer
          if (_answered) ...[
            // Feedback text
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isCorrectAnswer
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isCorrectAnswer
                      ? Colors.green.withOpacity(0.3)
                      : Colors.red.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isCorrectAnswer
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: isCorrectAnswer ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isCorrectAnswer
                          ? 'Correct! 🎯'
                          : 'Wrong — Correct: ${q.correctOption}) ${q.correctAnswerText}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isCorrectAnswer ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),

            const SizedBox(height: 14),

            // "Ask AI Tutor" button (only on wrong)
            if (!isCorrectAnswer)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showAIExplanation,
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  label: Text(
                    'Ask AI Tutor Why?',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.amber,
                    side: BorderSide(color: Colors.amber.withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

            const SizedBox(height: 10),

            // Next / Finish button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent.withOpacity(0.15),
                  foregroundColor: Colors.cyanAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _currentIndex + 1 >= _questions.length
                      ? 'Finish Quiz'
                      : 'Next Question →',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 100.ms),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildOptionCard(String letter, String text, DsQuestion q) {
    final bool isSelected = _selectedOption == letter;
    final bool isCorrect = letter == q.correctOption.toUpperCase();

    Color borderColor = Colors.white10;
    Color bgColor = Colors.white.withOpacity(0.03);

    if (_answered) {
      if (isCorrect) {
        borderColor = Colors.green.withOpacity(0.6);
        bgColor = Colors.green.withOpacity(0.08);
      } else if (isSelected && !isCorrect) {
        borderColor = Colors.red.withOpacity(0.6);
        bgColor = Colors.red.withOpacity(0.08);
      }
    }

    return GestureDetector(
      onTap: () => _selectOption(letter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            // Letter badge
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _answered && isCorrect
                    ? Colors.green.withOpacity(0.2)
                    : _answered && isSelected
                        ? Colors.red.withOpacity(0.2)
                        : Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  letter,
                  style: GoogleFonts.sourceCodePro(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _answered && isCorrect
                        ? Colors.green
                        : _answered && isSelected
                            ? Colors.red
                            : Colors.white60,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.85),
                  height: 1.4,
                ),
              ),
            ),
            if (_answered && isCorrect)
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
            if (_answered && isSelected && !isCorrect)
              const Icon(Icons.cancel, color: Colors.red, size: 20),
          ],
        ),
      ),
    );
  }

  // ──────── Results ────────
  Widget _buildResults() {
    final percentage = (_score / _questions.length * 100).round();
    final emoji = percentage >= 80
        ? '🏆'
        : percentage >= 50
            ? '👍'
            : '📚';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 64))
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 20),
            Text(
              'Quiz Complete!',
              style: GoogleFonts.orbitron(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 12),
            Text(
              '$_score / ${_questions.length} correct ($percentage%)',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.cyanAccent,
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 8),
            Text(
              'Topic: ${widget.topic}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _currentIndex = 0;
                      _selectedOption = null;
                      _answered = false;
                      _score = 0;
                      _quizFinished = false;
                      _quizStarted = false;
                    });
                    _loadQuestions();
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text('Retry',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent.withOpacity(0.15),
                    foregroundColor: Colors.cyanAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text('Back',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ],
            ).animate().fadeIn(delay: 600.ms),
          ],
        ),
      ),
    );
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// ════════════════════════════════════════════════════════════════
// AI Explanation Bottom Sheet
// ════════════════════════════════════════════════════════════════

class _AIExplanationSheet extends StatefulWidget {
  final String prompt;
  const _AIExplanationSheet({required this.prompt});

  @override
  State<_AIExplanationSheet> createState() => _AIExplanationSheetState();
}

class _AIExplanationSheetState extends State<_AIExplanationSheet> {
  String? _response;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchExplanation();
  }

  Future<void> _fetchExplanation() async {
    final response = await AIService.getResponse(widget.prompt);
    if (mounted) {
      setState(() {
        _response = response;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.amber, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'AI Tutor Explanation',
                    style: GoogleFonts.orbitron(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _loading
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Colors.amber),
                            SizedBox(height: 12),
                            Text(
                              'Thinking…',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        controller: scrollController,
                        child: Text(
                          _response ?? 'Could not get an explanation.',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.85),
                            height: 1.6,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
