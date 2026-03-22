import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import '../../widgets/glass_container.dart';

/// Bunk Meter — Attendance tracking with traffic light indicators
class BunkMeterScreen extends StatefulWidget {
  const BunkMeterScreen({super.key});

  @override
  State<BunkMeterScreen> createState() => _BunkMeterScreenState();
}

class _BunkMeterScreenState extends State<BunkMeterScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late Box _bunkBox;
  List<Map<String, dynamic>> _subjects = [];
  bool _isLoading = true;

  // Default subjects
  static const List<String> _defaultSubjects = [
    'Mathematics', 'Physics', 'Chemistry', 'Computer Science',
    'English', 'Data Structures', 'Electronics', 'Engineering Graphics',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    _bunkBox = Hive.box('bunk_meter_data');
    final saved = _bunkBox.get('subjects');
    if (saved != null) {
      _subjects = List<Map<String, dynamic>>.from(
        (saved as List).map((e) => Map<String, dynamic>.from(e)),
      );
    } else {
      _subjects = _defaultSubjects.map((name) => {
        'name': name,
        'present': 0,
        'absent': 0,
        'holiday': 0,
        'history': <Map<String, dynamic>>[],
      }).toList();
      _saveData();
    }
    setState(() => _isLoading = false);
  }

  void _saveData() {
    _bunkBox.put('subjects', _subjects);
  }

  int _totalClasses(Map<String, dynamic> subject) =>
      (subject['present'] as int) + (subject['absent'] as int);

  double _attendancePercent(Map<String, dynamic> subject) {
    final total = _totalClasses(subject);
    if (total == 0) return 100.0;
    return (subject['present'] as int) / total * 100;
  }

  Color _trafficColor(double percent) {
    if (percent >= 75) return Colors.greenAccent;
    if (percent >= 60) return Colors.amberAccent;
    return Colors.redAccent;
  }

  String _statusText(double percent) {
    if (percent >= 75) return 'Safe ✅';
    if (percent >= 60) return 'Warning ⚠️';
    return 'Danger 🚨';
  }

  int _bunkableClasses(Map<String, dynamic> subject) {
    final present = subject['present'] as int;
    final absent = subject['absent'] as int;
    final total = present + absent;
    if (total == 0) return 0;
    // How many more can be bunked while staying >= 75%
    // present / (total + x) >= 0.75
    // present >= 0.75 * (total + x)
    // x <= (present / 0.75) - total
    final maxBunkable = (present / 0.75) - total;
    return maxBunkable.floor().clamp(0, 999);
  }

  int _classesNeeded(Map<String, dynamic> subject) {
    final present = subject['present'] as int;
    final absent = subject['absent'] as int;
    final total = present + absent;
    final percent = _attendancePercent(subject);
    if (percent >= 75) return 0;
    // (present + x) / (total + x) >= 0.75
    // present + x >= 0.75 * total + 0.75x
    // 0.25x >= 0.75 * total - present
    // x >= (0.75 * total - present) / 0.25
    final needed = ((0.75 * total - present) / 0.25).ceil();
    return needed.clamp(0, 999);
  }

  void _markAttendance(int index, String type) {
    HapticFeedback.lightImpact();
    setState(() {
      _subjects[index][type] = (_subjects[index][type] as int) + 1;
      // Add to history
      final history = List<Map<String, dynamic>>.from(_subjects[index]['history'] ?? []);
      history.insert(0, {
        'type': type,
        'date': DateTime.now().toIso8601String(),
      });
      if (history.length > 30) history.removeLast();
      _subjects[index]['history'] = history;
      _saveData();
    });
  }

  void _resetSubject(int index) {
    HapticFeedback.mediumImpact();
    setState(() {
      _subjects[index]['present'] = 0;
      _subjects[index]['absent'] = 0;
      _subjects[index]['holiday'] = 0;
      _subjects[index]['history'] = <Map<String, dynamic>>[];
      _saveData();
    });
  }

  void _addSubject() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text('Add Subject', style: GoogleFonts.poppins(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Subject name',
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _subjects.add({
                    'name': controller.text.trim(),
                    'present': 0,
                    'absent': 0,
                    'holiday': 0,
                    'history': <Map<String, dynamic>>[],
                  });
                  _saveData();
                });
                Navigator.pop(ctx);
              }
            },
            child: Text('Add', style: TextStyle(color: Colors.cyanAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0A0F),
        body: const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
      );
    }

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
            colors: [Colors.greenAccent, Colors.cyanAccent],
          ).createShader(bounds),
          child: Text(
            'Bunk Meter',
            style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.cyanAccent),
            onPressed: _addSubject,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.cyanAccent,
          labelColor: Colors.cyanAccent,
          unselectedLabelColor: Colors.white38,
          tabs: const [
            Tab(text: 'Subjects', icon: Icon(Icons.how_to_reg, size: 18)),
            Tab(text: 'Summary', icon: Icon(Icons.analytics, size: 18)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSubjectsTab(),
          _buildSummaryTab(),
        ],
      ),
    );
  }

  Widget _buildSubjectsTab() {
    if (_subjects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            Text('No subjects added', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 16)),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _addSubject,
              icon: const Icon(Icons.add, color: Colors.cyanAccent),
              label: Text('Add Subject', style: TextStyle(color: Colors.cyanAccent)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _subjects.length,
      itemBuilder: (context, index) => _buildSubjectCard(index),
    );
  }

  Widget _buildSubjectCard(int index) {
    final subject = _subjects[index];
    final percent = _attendancePercent(subject);
    final color = _trafficColor(percent);
    final bunkable = _bunkableClasses(subject);
    final needed = _classesNeeded(subject);

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 12, height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(subject['name'], style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white38, size: 20),
                color: const Color(0xFF1A1A2E),
                onSelected: (val) {
                  if (val == 'reset') _resetSubject(index);
                  if (val == 'delete') {
                    setState(() { _subjects.removeAt(index); _saveData(); });
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'reset', child: Text('Reset', style: TextStyle(color: Colors.white70))),
                  PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.redAccent))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Attendance bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percent / 100,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),

          // Stats row
          Row(
            children: [
              Text('${percent.toStringAsFixed(1)}%',
                style: GoogleFonts.orbitron(color: color, fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(width: 8),
              Text(_statusText(percent), style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
              const Spacer(),
              _buildStatChip('P', '${subject['present']}', Colors.greenAccent),
              const SizedBox(width: 6),
              _buildStatChip('A', '${subject['absent']}', Colors.redAccent),
            ],
          ),
          const SizedBox(height: 8),

          // Bunk info
          if (percent >= 75)
            Text('Can bunk $bunkable more classes', style: GoogleFonts.poppins(color: Colors.greenAccent, fontSize: 12))
          else
            Text('Need $needed more classes for 75%', style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 12)),

          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              Expanded(child: _buildActionButton('Present', Colors.greenAccent, Icons.check, () => _markAttendance(index, 'present'))),
              const SizedBox(width: 8),
              Expanded(child: _buildActionButton('Absent', Colors.redAccent, Icons.close, () => _markAttendance(index, 'absent'))),
              const SizedBox(width: 8),
              Expanded(child: _buildActionButton('Holiday', Colors.amberAccent, Icons.wb_sunny, () => _markAttendance(index, 'holiday'))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('$label: $value', style: GoogleFonts.poppins(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildActionButton(String label, Color color, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 2),
            Text(label, style: GoogleFonts.poppins(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTab() {
    if (_subjects.isEmpty) {
      return Center(
        child: Text('No data yet', style: GoogleFonts.poppins(color: Colors.white54)),
      );
    }

    final totalPresent = _subjects.fold(0, (s, sub) => s + (sub['present'] as int));
    final totalAbsent = _subjects.fold(0, (s, sub) => s + (sub['absent'] as int));
    final totalClasses = totalPresent + totalAbsent;
    final overallPercent = totalClasses > 0 ? totalPresent / totalClasses * 100 : 100.0;

    // Sort subjects by attendance (worst first)
    final sorted = List<Map<String, dynamic>>.from(_subjects)
      ..sort((a, b) => _attendancePercent(a).compareTo(_attendancePercent(b)));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Overall card
          GlassContainer(
            padding: const EdgeInsets.all(20),
            borderRadius: 16,
            child: Column(
              children: [
                Text('Overall Attendance', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                Text('${overallPercent.toStringAsFixed(1)}%',
                  style: GoogleFonts.orbitron(color: _trafficColor(overallPercent), fontSize: 36, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatChip('Total', '$totalClasses', Colors.cyanAccent),
                    const SizedBox(width: 8),
                    _buildStatChip('Present', '$totalPresent', Colors.greenAccent),
                    const SizedBox(width: 8),
                    _buildStatChip('Absent', '$totalAbsent', Colors.redAccent),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Subject ranking
          Text('Subject Ranking (Lowest First)', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 12),
          ...sorted.map((sub) {
            final p = _attendancePercent(sub);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _trafficColor(p).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(color: _trafficColor(p), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(sub['name'], style: GoogleFonts.poppins(color: Colors.white, fontSize: 14))),
                  Text('${p.toStringAsFixed(1)}%', style: GoogleFonts.orbitron(color: _trafficColor(p), fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
