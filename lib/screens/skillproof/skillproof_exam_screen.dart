import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'skillproof_badge_screen.dart';

class SkillProofExamScreen extends StatefulWidget {
  final String skillName;

  const SkillProofExamScreen({super.key, required this.skillName});

  @override
  State<SkillProofExamScreen> createState() => _SkillProofExamScreenState();
}

class _SkillProofExamScreenState extends State<SkillProofExamScreen> {
  int _currentIndex = 0;
  int _score = 0;
  Timer? _timer;
  int _secondsRemaining = 15 * 60; // 15 minutes
  late List<Map<String, dynamic>> _questions;
  int? _selectedAnswerIndex;
  bool _isAnswerSubmitted = false;

  @override
  void initState() {
    super.initState();
    _generateMockQuestions();
    _startTimer();
  }

  void _generateMockQuestions() {
    // Generate 20 generic questions just for the demo
    _questions = List.generate(20, (index) {
      return {
        'question': 'Sample Question ${index + 1} for ${widget.skillName}. Which of the following is correct?',
        'options': [
          'Option A - This might be the answer.',
          'Option B - This is definitively wrong.',
          'Option C - The correct technical implementation.',
          'Option D - None of the above.'
        ],
        'correctIndex': 2, // Always Option C for simplicity in this mock
      };
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
        _finishExam();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _submitAnswer() {
    if (_selectedAnswerIndex == null) return;
    
    setState(() {
      _isAnswerSubmitted = true;
      if (_selectedAnswerIndex == _questions[_currentIndex]['correctIndex']) {
        _score += 5; // 20 questions * 5 points = 100 max
      }
    });

    // Short delay before moving to next question
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      if (_currentIndex < _questions.length - 1) {
        setState(() {
          _currentIndex++;
          _selectedAnswerIndex = null;
          _isAnswerSubmitted = false;
        });
      } else {
        _finishExam();
      }
    });
  }

  void _finishExam() {
    _timer?.cancel();
    // Calculate final percentage 
    int finalScore = _score;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SkillProofBadgeScreen(
          skillName: widget.skillName,
          score: finalScore,
          timeTakenSeconds: (15 * 60) - _secondsRemaining,
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) return const Scaffold();
    
    final question = _questions[_currentIndex];
    final options = question['options'] as List<String>;
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Prevent back navigation mid-exam
        title: Row(
          children: [
            Icon(Icons.timer, color: _secondsRemaining < 60 ? Colors.redAccent : Colors.amber, size: 20),
            const SizedBox(width: 8),
            Text(_formatTime(_secondsRemaining), style: GoogleFonts.orbitron(
              color: _secondsRemaining < 60 ? Colors.redAccent : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            )),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 20),
            child: Text('${_currentIndex + 1}/${_questions.length}', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 14)),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
            minHeight: 4,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question ${_currentIndex + 1}',
                    style: GoogleFonts.poppins(color: Colors.cyanAccent, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    question['question'],
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  ...List.generate(options.length, (i) {
                    final isSelected = _selectedAnswerIndex == i;
                    final isCorrect = i == question['correctIndex'];
                    
                    Color bgColor = Colors.white.withOpacity(0.05);
                    Color borderColor = Colors.white12;
                    
                    if (_isAnswerSubmitted) {
                      if (isCorrect) {
                        bgColor = Colors.greenAccent.withOpacity(0.2);
                        borderColor = Colors.greenAccent;
                      } else if (isSelected && !isCorrect) {
                        bgColor = Colors.redAccent.withOpacity(0.2);
                        borderColor = Colors.redAccent;
                      }
                    } else if (isSelected) {
                      bgColor = Colors.cyanAccent.withOpacity(0.15);
                      borderColor = Colors.cyanAccent;
                    }

                    return GestureDetector(
                      onTap: _isAnswerSubmitted ? null : () => setState(() => _selectedAnswerIndex = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24, height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: isSelected || (_isAnswerSubmitted && isCorrect) ? Colors.transparent : Colors.white38),
                                color: isSelected || (_isAnswerSubmitted && isCorrect) ? borderColor : Colors.transparent,
                              ),
                              child: _isAnswerSubmitted && (isCorrect || (isSelected && !isCorrect))
                                ? Icon(isCorrect ? Icons.check : Icons.close, size: 16, color: Colors.black)
                                : isSelected ? const Icon(Icons.circle, size: 10, color: Colors.black) : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(options[i], style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),

                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedAnswerIndex == null || _isAnswerSubmitted ? null : _submitAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: Colors.white12,
                  disabledForegroundColor: Colors.white38,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  _currentIndex == _questions.length - 1 ? 'Finish Exam' : 'Next Question',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
