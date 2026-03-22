import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import '../../widgets/glass_container.dart';

/// Exam Countdown Hub — Track exams with urgency colors and study planner
class ExamCountdownScreen extends StatefulWidget {
  const ExamCountdownScreen({super.key});

  @override
  State<ExamCountdownScreen> createState() => _ExamCountdownScreenState();
}

class _ExamCountdownScreenState extends State<ExamCountdownScreen> {
  late Box _examBox;
  List<Map<String, dynamic>> _exams = [];
  bool _isLoading = true;
  String _sortBy = 'date'; // date, subject, type

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _examBox = Hive.box('exam_countdown_data');
    final saved = _examBox.get('exams');
    if (saved != null) {
      _exams = List<Map<String, dynamic>>.from(
        (saved as List).map((e) => Map<String, dynamic>.from(e)),
      );
    }
    // Auto-archive past exams
    _autoArchive();
    setState(() => _isLoading = false);
  }

  void _saveData() {
    _examBox.put('exams', _exams);
  }

  void _autoArchive() {
    final now = DateTime.now();
    for (final exam in _exams) {
      final date = DateTime.tryParse(exam['date'] ?? '');
      if (date != null && date.isBefore(now)) {
        exam['archived'] = true;
      }
    }
    _saveData();
  }

  List<Map<String, dynamic>> get _activeExams =>
      _exams.where((e) => e['archived'] != true).toList()
        ..sort((a, b) {
          if (_sortBy == 'subject') return (a['subject'] ?? '').compareTo(b['subject'] ?? '');
          if (_sortBy == 'type') return (a['type'] ?? '').compareTo(b['type'] ?? '');
          return (a['date'] ?? '').compareTo(b['date'] ?? '');
        });

  List<Map<String, dynamic>> get _archivedExams =>
      _exams.where((e) => e['archived'] == true).toList();

  int _daysUntil(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return 999;
    return date.difference(DateTime.now()).inDays;
  }

  Color _urgencyColor(int days) {
    if (days <= 1) return Colors.redAccent;
    if (days <= 3) return Colors.orangeAccent;
    if (days <= 7) return Colors.amberAccent;
    return Colors.greenAccent;
  }

  String _urgencyLabel(int days) {
    if (days < 0) return 'Past';
    if (days == 0) return 'TODAY!';
    if (days == 1) return 'Tomorrow';
    if (days <= 3) return '$days days — Critical!';
    if (days <= 7) return '$days days — Study Now';
    return '$days days';
  }

  double _studyHoursPerDay(int daysLeft, int totalHours) {
    if (daysLeft <= 0) return totalHours.toDouble();
    return totalHours / daysLeft;
  }

  void _addExam() {
    final nameCtrl = TextEditingController();
    final subjectCtrl = TextEditingController();
    final hoursCtrl = TextEditingController(text: '20');
    String type = 'Mid';
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Exam', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Exam Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subjectCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Subject'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: hoursCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Study Hours Needed'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: type,
                    dropdownColor: const Color(0xFF1A1A2E),
                    style: GoogleFonts.poppins(color: Colors.cyanAccent),
                    items: ['Mid', 'Final', 'Quiz', 'Viva', 'Lab', 'Other'].map((t) =>
                      DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) => setModalState(() => type = val!),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) setModalState(() => selectedDate = date);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.cyanAccent, size: 18),
                      const SizedBox(width: 12),
                      Text(
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty) return;
                    setState(() {
                      _exams.add({
                        'name': nameCtrl.text.trim(),
                        'subject': subjectCtrl.text.trim(),
                        'date': selectedDate.toIso8601String(),
                        'type': type,
                        'studyHours': int.tryParse(hoursCtrl.text) ?? 20,
                        'archived': false,
                      });
                      _saveData();
                    });
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent.withOpacity(0.2),
                    foregroundColor: Colors.cyanAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('Add Exam', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.white30),
    filled: true,
    fillColor: Colors.white.withOpacity(0.05),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0A0F),
        body: const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
      );
    }

    final active = _activeExams;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.orangeAccent, Colors.redAccent],
          ).createShader(bounds),
          child: Text('Exam Countdown', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.white54),
            color: const Color(0xFF1A1A2E),
            onSelected: (val) => setState(() => _sortBy = val),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'date', child: Text('Sort by Date', style: TextStyle(color: Colors.white70))),
              PopupMenuItem(value: 'subject', child: Text('Sort by Subject', style: TextStyle(color: Colors.white70))),
              PopupMenuItem(value: 'type', child: Text('Sort by Type', style: TextStyle(color: Colors.white70))),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExam,
        backgroundColor: Colors.cyanAccent.withOpacity(0.9),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: active.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer_off_outlined, size: 64, color: Colors.white24),
                const SizedBox(height: 16),
                Text('No upcoming exams', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 16)),
                const SizedBox(height: 4),
                Text('Tap + to add an exam', style: GoogleFonts.poppins(color: Colors.white38, fontSize: 13)),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: active.length + 1, // +1 for dashboard widget
            itemBuilder: (context, index) {
              if (index == 0) return _buildDashboardWidget(active);
              return _buildExamCard(active[index - 1], _exams.indexOf(active[index - 1]));
            },
          ),
    );
  }

  Widget _buildDashboardWidget(List<Map<String, dynamic>> active) {
    final next3 = active.take(3).toList();
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Next Up', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...next3.map((exam) {
            final days = _daysUntil(exam['date'] ?? '');
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(color: _urgencyColor(days), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(exam['name'] ?? '', style: GoogleFonts.poppins(color: Colors.white, fontSize: 13))),
                  Text(_urgencyLabel(days), style: GoogleFonts.poppins(color: _urgencyColor(days), fontSize: 11)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildExamCard(Map<String, dynamic> exam, int globalIndex) {
    final days = _daysUntil(exam['date'] ?? '');
    final color = _urgencyColor(days);
    final studyHours = exam['studyHours'] as int? ?? 20;
    final hoursPerDay = _studyHoursPerDay(days, studyHours);

    return Dismissible(
      key: Key('exam_$globalIndex'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.3), borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete, color: Colors.redAccent),
      ),
      onDismissed: (_) {
        setState(() { _exams.removeAt(globalIndex); _saveData(); });
      },
      child: GlassContainer(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        borderRadius: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withOpacity(0.5)),
                  ),
                  child: Text(exam['type'] ?? 'Exam', style: GoogleFonts.poppins(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(exam['name'] ?? '', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15))),
              ],
            ),
            if ((exam['subject'] ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(exam['subject'], style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.timer, color: color, size: 20),
                const SizedBox(width: 6),
                Text(
                  _urgencyLabel(days),
                  style: GoogleFonts.orbitron(color: color, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (days > 0)
                  Text(
                    '${hoursPerDay.toStringAsFixed(1)} hrs/day',
                    style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
