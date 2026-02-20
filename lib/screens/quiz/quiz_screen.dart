import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/ds_question_model.dart';
import '../../services/quiz_service.dart';
import '../../services/ai_service.dart';

/// Native channel for FLAG_SECURE (screenshot prevention).
const _secureChannel = MethodChannel('com.example.fluxflow/window_security');

/// Interactive quiz screen – attempt-first, reveal-after.
/// Students answer all 20 questions first. Answers & explanations
/// are only shown after the last question is submitted.
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
  bool _quizFinished = false;

  /// Stores the user's answer for each question index.
  /// Key = question index, Value = selected option letter ('A','B','C','D').
  final Map<int, String> _answers = {};

  // Anti-cheating state
  bool _quizStarted = false;
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
    } catch (_) {}
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

    setState(() {
      _currentIndex = 0;
      _answers.clear();
      _quizFinished = false;
      _quizStarted = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.redAccent, size: 28),
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
            style: GoogleFonts.poppins(
                color: Colors.white70, fontSize: 14, height: 1.5),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => _showingCheatWarning = false);
                _loadQuestions();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withOpacity(0.2),
                foregroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Restart Quiz',
                  style:
                      GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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

    final questions = await QuizService.getRandomQuiz(widget.topic, 20);

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
      _quizStarted = true;
    });
  }

  DsQuestion get _currentQuestion => _questions[_currentIndex];

  // ──────────── Answer Selection ────────────

  void _selectOption(String option) {
    // Allow changing selection on current question
    setState(() {
      _answers[_currentIndex] = option;
    });

    HapticFeedback.lightImpact();
  }

  void _nextQuestion() {
    if (_currentIndex + 1 >= _questions.length) {
      // Last question — finish the quiz
      _finishQuiz();
      return;
    }

    setState(() {
      _currentIndex++;
    });
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  void _finishQuiz() {
    // Calculate score
    int score = 0;
    for (int i = 0; i < _questions.length; i++) {
      final userAnswer = _answers[i];
      if (userAnswer != null &&
          userAnswer == _questions[i].correctOption.toUpperCase()) {
        score++;
      }
    }

    // Batch submit all answers
    QuizService.submitBatchAnswers(
      questions: _questions,
      answers: _answers,
    );

    setState(() {
      _quizFinished = true;
    });
  }

  int get _score {
    int s = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_answers[i] == _questions[i].correctOption.toUpperCase()) s++;
    }
    return s;
  }

  int get _answeredCount => _answers.length;

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
          onPressed: () {
            if (_quizStarted && !_quizFinished) {
              _showExitConfirmation();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          if (!_isLoading && !_quizFinished)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Tooltip(
                message: 'Screenshot & app-switch protection active',
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: Colors.redAccent.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.security,
                          color: Colors.redAccent, size: 14),
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

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Leave Quiz?',
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'You have answered $_answeredCount of ${_questions.length} questions.\n\n'
          'Your progress will be lost if you leave.',
          style: GoogleFonts.poppins(
              color: Colors.white70, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                Text('Continue Quiz', style: GoogleFonts.poppins(color: Colors.cyanAccent)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.withOpacity(0.2),
              foregroundColor: Colors.redAccent,
            ),
            child: Text('Leave', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
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

  // ════════════════════════════════════════════════════════════════
  // QUESTION VIEW (No answer reveal)
  // ════════════════════════════════════════════════════════════════

  Widget _buildQuestion() {
    final q = _currentQuestion;
    final progress = (_currentIndex + 1) / _questions.length;
    final selectedForThis = _answers[_currentIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar + counter
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
                '$_answeredCount answered',
                style: GoogleFonts.sourceCodePro(
                  fontSize: 13,
                  color: Colors.white54,
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

          // Dot navigator
          const SizedBox(height: 12),
          _buildDotNavigator(),

          const SizedBox(height: 20),

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

          // Options — neutral colors only
          ...['A', 'B', 'C', 'D'].map((letter) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child:
                  _buildOptionCard(letter, q.getOptionText(letter), selectedForThis),
            );
          }),

          const SizedBox(height: 16),

          // Navigation buttons
          Row(
            children: [
              // Previous button
              if (_currentIndex > 0)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _previousQuestion,
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: Text('Previous',
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              if (_currentIndex > 0) const SizedBox(width: 12),

              // Next / Submit button
              Expanded(
                child: ElevatedButton(
                  onPressed: selectedForThis != null ? _nextQuestion : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentIndex + 1 >= _questions.length
                        ? Colors.green.withOpacity(0.2)
                        : Colors.cyanAccent.withOpacity(0.15),
                    foregroundColor: _currentIndex + 1 >= _questions.length
                        ? Colors.green
                        : Colors.cyanAccent,
                    disabledBackgroundColor: Colors.white.withOpacity(0.05),
                    disabledForegroundColor: Colors.white24,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_currentIndex + 1 >= _questions.length)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(Icons.check_circle_outline, size: 18),
                        ),
                      Text(
                        _currentIndex + 1 >= _questions.length
                            ? 'Submit Quiz'
                            : 'Next',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      if (_currentIndex + 1 < _questions.length)
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(Icons.arrow_forward_rounded, size: 18),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Skip hint
          if (selectedForThis == null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: Text(
                  'Select an option to continue',
                  style: GoogleFonts.poppins(
                      color: Colors.white30, fontSize: 12),
                ),
              ),
            ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// Dot navigator showing progress across all questions
  Widget _buildDotNavigator() {
    return SizedBox(
      height: 22,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _questions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (ctx, i) {
          final isAnswered = _answers.containsKey(i);
          final isCurrent = i == _currentIndex;

          return GestureDetector(
            onTap: () => setState(() => _currentIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isCurrent ? 22 : 14,
              height: 14,
              decoration: BoxDecoration(
                color: isCurrent
                    ? Colors.cyanAccent
                    : isAnswered
                        ? Colors.cyanAccent.withOpacity(0.4)
                        : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(7),
                border: isCurrent
                    ? Border.all(color: Colors.cyanAccent, width: 2)
                    : null,
              ),
              child: isCurrent
                  ? Center(
                      child: Text(
                        '${i + 1}',
                        style: GoogleFonts.sourceCodePro(
                          fontSize: 8,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  /// Option card — neutral styling only, no correct/wrong colors
  Widget _buildOptionCard(
      String letter, String text, String? selectedForThis) {
    final bool isSelected = selectedForThis == letter;

    return GestureDetector(
      onTap: () => _selectOption(letter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.cyanAccent.withOpacity(0.1)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? Colors.cyanAccent.withOpacity(0.6)
                : Colors.white10,
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            // Letter badge
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.cyanAccent.withOpacity(0.2)
                    : Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  letter,
                  style: GoogleFonts.sourceCodePro(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.cyanAccent : Colors.white60,
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
            if (isSelected)
              const Icon(Icons.check_circle_outline,
                  color: Colors.cyanAccent, size: 20),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // RESULTS PAGE (shown after all questions answered)
  // ════════════════════════════════════════════════════════════════

  Widget _buildResults() {
    final percentage = (_score / _questions.length * 100).round();
    final IconData scoreIcon = percentage >= 80
        ? Icons.emoji_events_rounded
        : percentage >= 50
            ? Icons.thumb_up_alt_rounded
            : Icons.menu_book_rounded;
    final Color scoreColor = percentage >= 80
        ? Colors.amber
        : percentage >= 50
            ? Colors.orange
            : Colors.blueGrey;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // ── Score Summary ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: percentage >= 80
                    ? [Colors.green.withOpacity(0.15), Colors.green.withOpacity(0.05)]
                    : percentage >= 50
                        ? [Colors.orange.withOpacity(0.15), Colors.orange.withOpacity(0.05)]
                        : [Colors.red.withOpacity(0.15), Colors.red.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: percentage >= 80
                    ? Colors.green.withOpacity(0.3)
                    : percentage >= 50
                        ? Colors.orange.withOpacity(0.3)
                        : Colors.red.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(scoreIcon, size: 56, color: scoreColor)
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut),
                const SizedBox(height: 12),
                Text(
                  'Quiz Complete!',
                  style: GoogleFonts.orbitron(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 8),
                Text(
                  '$_score / ${_questions.length} correct ($percentage%)',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 4),
                Text(
                  'Topic: ${widget.topic}',
                  style:
                      GoogleFonts.poppins(fontSize: 14, color: Colors.white54),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.1),

          const SizedBox(height: 24),

          // Section header
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Question Breakdown',
              style: GoogleFonts.orbitron(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Per-question breakdown ──
          ...List.generate(_questions.length, (i) {
            return _buildQuestionResult(i)
                .animate()
                .fadeIn(delay: (100 + i * 50).ms)
                .slideX(begin: 0.05);
          }),

          const SizedBox(height: 24),

          // ── Action buttons ──
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _currentIndex = 0;
                      _answers.clear();
                      _quizFinished = false;
                      _quizStarted = false;
                    });
                    _loadQuestions();
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text('Retry',
                      style:
                          GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent.withOpacity(0.15),
                    foregroundColor: Colors.cyanAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text('Back',
                      style:
                          GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 600.ms),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// Single question result card for the breakdown
  Widget _buildQuestionResult(int index) {
    final q = _questions[index];
    final userAnswer = _answers[index];
    final correctOption = q.correctOption.toUpperCase();
    final isCorrect = userAnswer == correctOption;
    final isSkipped = userAnswer == null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSkipped
              ? Colors.grey.withOpacity(0.3)
              : isCorrect
                  ? Colors.green.withOpacity(0.3)
                  : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding:
              const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isSkipped
                  ? Colors.grey.withOpacity(0.15)
                  : isCorrect
                      ? Colors.green.withOpacity(0.15)
                      : Colors.red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: isSkipped
                  ? const Icon(Icons.remove_circle_outline,
                      color: Colors.grey, size: 20)
                  : isCorrect
                      ? const Icon(Icons.check_circle,
                          color: Colors.green, size: 20)
                      : const Icon(Icons.cancel,
                          color: Colors.red, size: 20),
            ),
          ),
          title: Text(
            'Q${index + 1}. ${q.questionText}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              isSkipped
                  ? 'Skipped'
                  : isCorrect
                      ? 'Correct ✓'
                      : 'Wrong — You: $userAnswer, Correct: $correctOption',
              style: GoogleFonts.sourceCodePro(
                fontSize: 11,
                color: isSkipped
                    ? Colors.grey
                    : isCorrect
                        ? Colors.green
                        : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          iconColor: Colors.white38,
          collapsedIconColor: Colors.white38,
          children: [
            // Show all options with correct/wrong highlighting
            ...['A', 'B', 'C', 'D'].map((letter) {
              final isThisCorrect = letter == correctOption;
              final isThisSelected = letter == userAnswer;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isThisCorrect
                        ? Colors.green.withOpacity(0.08)
                        : isThisSelected
                            ? Colors.red.withOpacity(0.08)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isThisCorrect
                          ? Colors.green.withOpacity(0.4)
                          : isThisSelected
                              ? Colors.red.withOpacity(0.4)
                              : Colors.white.withOpacity(0.06),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '$letter)',
                        style: GoogleFonts.sourceCodePro(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isThisCorrect
                              ? Colors.green
                              : isThisSelected
                                  ? Colors.red
                                  : Colors.white54,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          q.getOptionText(letter),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                      if (isThisCorrect)
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 16),
                      if (isThisSelected && !isThisCorrect)
                        const Icon(Icons.cancel, color: Colors.red, size: 16),
                    ],
                  ),
                ),
              );
            }),

            // AI Explanation button (only for wrong answers)
            if (!isCorrect)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showAIExplanation(q, userAnswer),
                    icon: const Icon(Icons.auto_awesome, size: 16),
                    label: Text(
                      'AI Explanation',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.amber,
                      side:
                          BorderSide(color: Colors.amber.withOpacity(0.4)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAIExplanation(DsQuestion question, String? userAnswer) {
    final selectedText =
        userAnswer != null ? question.getOptionText(userAnswer) : 'Skipped';
    final correctText = question.correctAnswerText;

    final prompt =
        'A student answered a Data Structures MCQ incorrectly.\n\n'
        'Question: ${question.questionText}\n'
        'Student\'s Answer: ${userAnswer ?? "Skipped"}) $selectedText\n'
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
                  const Icon(Icons.auto_awesome,
                      color: Colors.amber, size: 22),
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
                          _response ?? 'Could not get explanation.',
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
