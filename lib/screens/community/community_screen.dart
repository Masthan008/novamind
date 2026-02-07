import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../services/supabase_data_service.dart';
import '../../services/student_auth_service.dart';
import 'doubt_detail_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with SingleTickerProviderStateMixin {
  final _dataService = SupabaseDataService();
  final _questionController = TextEditingController();
  final _subjectController = TextEditingController();
  late TabController _tabController;
  
  final List<String> _subjects = ['All', 'Math', 'Physics', 'Chemistry', 'Programming', 'English', 'Other'];
  String _selectedFilter = 'All';
  bool _showNewDoubtBanner = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _subjects.length, vsync: this);
  }

  @override
  void dispose() {
    _questionController.dispose();
    _subjectController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _showAskDoubtBottomSheet() {
    String selectedSubject = 'Programming';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1a1a2e), Color(0xFF0f0f1a)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white30,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.cyanAccent, Colors.blueAccent],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.help_outline, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ask the Community',
                              style: GoogleFonts.orbitron(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Get help from fellow students',
                              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Subject Selection
                    Text('Subject', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _subjects.where((s) => s != 'All').map((subject) {
                        final isSelected = selectedSubject == subject;
                        return InkWell(
                          onTap: () => setModalState(() => selectedSubject = subject),
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(colors: [Colors.cyanAccent, Colors.blueAccent])
                                  : null,
                              color: isSelected ? null : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? Colors.cyanAccent : Colors.white10,
                              ),
                            ),
                            child: Text(
                              subject,
                              style: GoogleFonts.poppins(
                                color: isSelected ? Colors.black : Colors.white54,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Question Field
                    Text('Your Question', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                      ),
                      child: TextField(
                        controller: _questionController,
                        style: GoogleFonts.poppins(color: Colors.white, height: 1.5),
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          hintText: 'Describe your doubt in detail...\n\nTip: Be specific so others can help you better!',
                          hintStyle: GoogleFonts.poppins(color: Colors.white30),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Post Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_questionController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please write your question', style: GoogleFonts.poppins()),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }

                          final success = await _dataService.postDoubt(
                            _questionController.text.trim(),
                            selectedSubject,
                          );

                          if (success && mounted) {
                            _questionController.clear();
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text('Question posted! 🎉', style: GoogleFonts.poppins()),
                                  ],
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to post. Are you logged in?', style: GoogleFonts.poppins()),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyanAccent,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.send),
                            const SizedBox(width: 8),
                            Text(
                              'Post Question',
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
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

  IconData _getSubjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'math':
        return Icons.calculate;
      case 'physics':
        return Icons.science;
      case 'chemistry':
        return Icons.biotech;
      case 'programming':
        return Icons.code;
      case 'english':
        return Icons.menu_book;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentName = StudentAuthService.currentStudent?.name ?? 'Student';
    
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a1a),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'Student Community',
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _subjects.length,
              itemBuilder: (context, index) {
                final subject = _subjects[index];
                final isSelected = _selectedFilter == subject;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => setState(() => _selectedFilter = subject),
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(colors: [_getSubjectColor(subject), _getSubjectColor(subject).withOpacity(0.7)])
                            : null,
                        color: isSelected ? null : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        subject,
                        style: GoogleFonts.poppins(
                          color: isSelected ? Colors.black : Colors.white54,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAskDoubtBottomSheet,
        backgroundColor: Colors.cyanAccent,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_comment),
        label: Text('Ask', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ).animate().scale(delay: 300.ms),
      body: Stack(
        children: [
          // Background
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.cyanAccent.withOpacity(0.15), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.blueAccent.withOpacity(0.1), Colors.transparent],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _dataService.getDoubtsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState();
                  }

                  var doubts = snapshot.data!;
                  
                  // Filter by subject
                  if (_selectedFilter != 'All') {
                    doubts = doubts.where((d) => d['subject'] == _selectedFilter).toList();
                  }

                  if (doubts.isEmpty) {
                    return Center(
                      child: Text(
                        'No questions in $_selectedFilter',
                        style: GoogleFonts.poppins(color: Colors.white38),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: doubts.length,
                    itemBuilder: (context, index) {
                      final doubt = doubts[index];
                      return _buildDoubtCard(doubt, index);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_outlined, size: 80, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 24),
          Text(
            'No questions yet',
            style: GoogleFonts.orbitron(color: Colors.white38, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to ask!',
            style: GoogleFonts.poppins(color: Colors.white24),
          ),
        ],
      ).animate().fadeIn().scale(),
    );
  }

  Widget _buildDoubtCard(Map<String, dynamic> doubt, int index) {
    final date = DateTime.parse(doubt['created_at']);
    final subject = doubt['subject'] ?? 'Other';
    final color = _getSubjectColor(subject);
    final studentName = doubt['student_name'] ?? 'Anonymous';
    final isSolved = doubt['is_solved'] ?? false;
    
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoubtDetailScreen(doubt: doubt),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 180,
        borderRadius: 20,
        blur: 20,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderGradient: LinearGradient(
          colors: [color.withOpacity(0.5), Colors.white.withOpacity(0.1)],
        ),
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Subject Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getSubjectIcon(subject), color: Colors.black, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          subject,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isSolved)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            'Solved',
                            style: GoogleFonts.poppins(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  Text(
                    timeago.format(date),
                    style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              
              // Question
              Text(
                doubt['question'] ?? '',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const Spacer(),
              const Divider(color: Colors.white10, height: 1),
              const SizedBox(height: 12),
              
              // Footer
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: color.withOpacity(0.2),
                    child: Text(
                      studentName.isNotEmpty ? studentName[0].toUpperCase() : '?',
                      style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      studentName,
                      style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.chat_bubble_outline, color: Colors.white38, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${doubt['answer_count'] ?? 0}',
                        style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.arrow_forward_ios, color: color, size: 14),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 80)).slideX(begin: 0.05);
  }
}
