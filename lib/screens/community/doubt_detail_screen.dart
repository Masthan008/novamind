import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../services/supabase_data_service.dart';
import '../../services/student_auth_service.dart';

class DoubtDetailScreen extends StatefulWidget {
  final Map<String, dynamic> doubt;

  const DoubtDetailScreen({super.key, required this.doubt});

  @override
  State<DoubtDetailScreen> createState() => _DoubtDetailScreenState();
}

class _DoubtDetailScreenState extends State<DoubtDetailScreen> {
  final _dataService = SupabaseDataService();
  final _answerController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void dispose() {
    _answerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'math':
        return Colors.blueAccent;
      case 'physics':
        return Colors.orangeAccent;
      case 'chemistry':
        return Colors.greenAccent;
      case 'programming':
        return Colors.cyanAccent;
      case 'english':
        return Colors.pinkAccent;
      default:
        return Colors.purpleAccent;
    }
  }

  void _postAnswer() async {
    if (_answerController.text.trim().isEmpty || _isSending) return;

    setState(() => _isSending = true);

    final success = await _dataService.postAnswer(
      widget.doubt['id'],
      _answerController.text.trim(),
    );

    setState(() => _isSending = false);

    if (success && mounted) {
      _answerController.clear();
      FocusScope.of(context).unfocus();
      
      // 🔔 Send notification to the question owner (Campus Buzz feature)
      final askerId = widget.doubt['student_id'];
      final questionSnippet = widget.doubt['question'] ?? 'your question';
      if (askerId != null) {
        _dataService.sendAnswerNotification(
          recipientId: askerId,
          questionSnippet: questionSnippet,
        );
      }
      
      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Answer posted! ✓', style: GoogleFonts.poppins()),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Scroll to bottom to show new answer
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to post answer. Please try again.', style: GoogleFonts.poppins()),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final subject = widget.doubt['subject'] ?? 'Other';
    final color = _getSubjectColor(subject);
    final questionDate = DateTime.parse(widget.doubt['created_at']);
    final questionerName = widget.doubt['student_name'] ?? 'Anonymous';
    final currentStudentId = StudentAuthService.currentStudent?.id;
    final isMyQuestion = widget.doubt['student_id'] == currentStudentId;

    return Scaffold(
      backgroundColor: const Color(0xFF0a0a1a),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                subject,
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          if (isMyQuestion && !(widget.doubt['is_solved'] ?? false))
            TextButton(
              onPressed: () async {
                await _dataService.markDoubtSolved(widget.doubt['id'], null);
                if (mounted) Navigator.pop(context);
              },
              child: Text(
                'Mark Solved',
                style: GoogleFonts.poppins(color: Colors.green, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Question Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: color.withOpacity(0.2),
                      child: Text(
                        questionerName.isNotEmpty ? questionerName[0].toUpperCase() : '?',
                        style: GoogleFonts.poppins(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  questionerName,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isMyQuestion)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'You',
                                    style: GoogleFonts.poppins(
                                      color: color,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Text(
                            timeago.format(questionDate),
                            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    if (widget.doubt['is_solved'] ?? false)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Question
                Text(
                  widget.doubt['question'] ?? '',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.1),

          // Answers Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.forum, color: color, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  'Answers',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _dataService.getAnswersStream(widget.doubt['id']),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.length ?? 0;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$count',
                        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Answers List
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _dataService.getAnswersStream(widget.doubt['id']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 60, color: Colors.white.withOpacity(0.1)),
                        const SizedBox(height: 16),
                        Text(
                          'No answers yet',
                          style: GoogleFonts.poppins(color: Colors.white38, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Be the first to help!',
                          style: GoogleFonts.poppins(color: Colors.white24),
                        ),
                      ],
                    ),
                  );
                }

                final answers = snapshot.data!;
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: answers.length,
                  itemBuilder: (context, index) {
                    final answer = answers[index];
                    final answerDate = DateTime.parse(answer['created_at']);
                    final answererName = answer['student_name'] ?? 'Anonymous';
                    final isMyAnswer = answer['student_id'] == currentStudentId;
                    final isAccepted = answer['is_accepted'] ?? false;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isMyAnswer) const Spacer(flex: 1),
                          Flexible(
                            flex: 4,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isMyAnswer
                                      ? [color.withOpacity(0.2), color.withOpacity(0.1)]
                                      : [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.03)],
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(20),
                                  topRight: const Radius.circular(20),
                                  bottomLeft: isMyAnswer ? const Radius.circular(20) : const Radius.circular(4),
                                  bottomRight: isMyAnswer ? const Radius.circular(4) : const Radius.circular(20),
                                ),
                                border: Border.all(
                                  color: isAccepted
                                      ? Colors.green.withOpacity(0.5)
                                      : (isMyAnswer ? color.withOpacity(0.3) : Colors.white.withOpacity(0.1)),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 14,
                                        backgroundColor: isMyAnswer
                                            ? color.withOpacity(0.3)
                                            : Colors.purple.withOpacity(0.2),
                                        child: Text(
                                          answererName.isNotEmpty ? answererName[0].toUpperCase() : '?',
                                          style: GoogleFonts.poppins(
                                            color: isMyAnswer ? color : Colors.purpleAccent,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          isMyAnswer ? 'You' : answererName,
                                          style: GoogleFonts.poppins(
                                            color: isMyAnswer ? color : Colors.white70,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (isAccepted)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.check, color: Colors.green, size: 12),
                                              const SizedBox(width: 2),
                                              Text(
                                                'Best',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.green,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      const SizedBox(width: 4),
                                      Text(
                                        timeago.format(answerDate),
                                        style: GoogleFonts.poppins(color: Colors.white38, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    answer['answer_text'] ?? '',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (!isMyAnswer) const Spacer(flex: 1),
                        ],
                      ),
                    ).animate().fadeIn(delay: Duration(milliseconds: index * 80)).slideX(
                      begin: isMyAnswer ? 0.1 : -0.1,
                    );
                  },
                );
              },
            ),
          ),

          // Input Field
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1a1a2e),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: TextField(
                        controller: _answerController,
                        style: GoogleFonts.poppins(color: Colors.white),
                        maxLines: 3,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: 'Share your answer...',
                          hintStyle: GoogleFonts.poppins(color: Colors.white30),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _isSending ? null : _postAnswer,
                      icon: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.send_rounded),
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
