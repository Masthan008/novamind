import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/glass_container.dart';

/// CGPA War Room — GPA calculator, what-if simulator, trend tracker
class CgpaWarroomScreen extends StatefulWidget {
  const CgpaWarroomScreen({super.key});

  @override
  State<CgpaWarroomScreen> createState() => _CgpaWarroomScreenState();
}

class _CgpaWarroomScreenState extends State<CgpaWarroomScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late Box _cgpaBox;
  bool _isLoading = true;
  bool _is10Point = true;

  // Current semester input
  final List<Map<String, dynamic>> _currentSubjects = [];
  final _targetCgpaController = TextEditingController(text: '8.0');

  // Semester history
  List<Map<String, dynamic>> _semesters = [];

  static const Map<String, double> _gradePoints10 = {
    'O': 10.0, 'A+': 9.0, 'A': 8.0, 'B+': 7.0, 'B': 6.0,
    'C': 5.0, 'D': 4.0, 'F': 0.0,
  };

  static const Map<String, double> _gradePoints4 = {
    'A': 4.0, 'A-': 3.7, 'B+': 3.3, 'B': 3.0, 'B-': 2.7,
    'C+': 2.3, 'C': 2.0, 'C-': 1.7, 'D': 1.0, 'F': 0.0,
  };

  Map<String, double> get _activeGradePoints => _is10Point ? _gradePoints10 : _gradePoints4;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _targetCgpaController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    _cgpaBox = Hive.box('cgpa_data');
    final saved = _cgpaBox.get('semesters');
    if (saved != null) {
      _semesters = List<Map<String, dynamic>>.from(
        (saved as List).map((e) => Map<String, dynamic>.from(e)),
      );
    }
    _is10Point = _cgpaBox.get('is10Point', defaultValue: true);
    setState(() => _isLoading = false);
  }

  void _saveData() {
    _cgpaBox.put('semesters', _semesters);
    _cgpaBox.put('is10Point', _is10Point);
  }

  double _calculateSGPA(List<Map<String, dynamic>> subjects) {
    double totalPoints = 0;
    int totalCredits = 0;
    for (final sub in subjects) {
      final credits = sub['credits'] as int;
      final grade = sub['grade'] as String;
      final points = _activeGradePoints[grade] ?? 0.0;
      totalPoints += points * credits;
      totalCredits += credits;
    }
    return totalCredits > 0 ? totalPoints / totalCredits : 0;
  }

  double _calculateCGPA() {
    if (_semesters.isEmpty) return 0;
    double totalPoints = 0;
    int totalCredits = 0;
    for (final sem in _semesters) {
      totalPoints += (sem['sgpa'] as double) * (sem['credits'] as int);
      totalCredits += sem['credits'] as int;
    }
    return totalCredits > 0 ? totalPoints / totalCredits : 0;
  }

  void _addSubject() {
    setState(() {
      _currentSubjects.add({
        'name': 'Subject ${_currentSubjects.length + 1}',
        'credits': 3,
        'grade': _is10Point ? 'A' : 'B+',
      });
    });
  }

  void _saveSemester() {
    if (_currentSubjects.isEmpty) return;
    HapticFeedback.mediumImpact();
    final sgpa = _calculateSGPA(_currentSubjects);
    final totalCredits = _currentSubjects.fold(0, (s, sub) => s + (sub['credits'] as int));
    setState(() {
      _semesters.add({
        'semester': 'Sem ${_semesters.length + 1}',
        'sgpa': sgpa,
        'credits': totalCredits,
        'subjects': List<Map<String, dynamic>>.from(_currentSubjects),
        'date': DateTime.now().toIso8601String(),
      });
      _currentSubjects.clear();
      _saveData();
    });
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
            colors: [Colors.purpleAccent, Colors.cyanAccent],
          ).createShader(bounds),
          child: Text('CGPA War Room', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        actions: [
          // GPA Scale Toggle
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_is10Point ? '10 Pt' : '4 Pt', style: GoogleFonts.poppins(fontSize: 11)),
              selected: true,
              selectedColor: Colors.cyanAccent.withOpacity(0.3),
              onSelected: (_) {
                setState(() { _is10Point = !_is10Point; _saveData(); });
              },
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.cyanAccent,
          labelColor: Colors.cyanAccent,
          unselectedLabelColor: Colors.white38,
          tabs: const [
            Tab(text: 'Calculator', icon: Icon(Icons.calculate, size: 18)),
            Tab(text: 'What-If', icon: Icon(Icons.science, size: 18)),
            Tab(text: 'Trend', icon: Icon(Icons.trending_up, size: 18)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCalculatorTab(),
          _buildWhatIfTab(),
          _buildTrendTab(),
        ],
      ),
    );
  }

  Widget _buildCalculatorTab() {
    final cgpa = _calculateCGPA();
    final maxGpa = _is10Point ? 10.0 : 4.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Current CGPA display
          GlassContainer(
            padding: const EdgeInsets.all(20),
            borderRadius: 16,
            child: Column(
              children: [
                Text('Current CGPA', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  cgpa > 0 ? cgpa.toStringAsFixed(2) : '--',
                  style: GoogleFonts.orbitron(
                    color: Colors.cyanAccent, fontSize: 42, fontWeight: FontWeight.bold),
                ),
                Text('/ $maxGpa', style: GoogleFonts.poppins(color: Colors.white38, fontSize: 14)),
                if (_semesters.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('${_semesters.length} semesters recorded',
                    style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Add subjects for new semester
          Row(
            children: [
              Expanded(child: Text('Add Semester Grades', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600))),
              IconButton(icon: const Icon(Icons.add_circle, color: Colors.cyanAccent), onPressed: _addSubject),
            ],
          ),
          const SizedBox(height: 8),

          // Subject entries
          ..._currentSubjects.asMap().entries.map((entry) => _buildSubjectEntry(entry.key)),

          if (_currentSubjects.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text('SGPA: ${_calculateSGPA(_currentSubjects).toStringAsFixed(2)}',
                  style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontSize: 16)),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _saveSemester,
                  icon: const Icon(Icons.save, size: 18),
                  label: Text('Save Semester'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent.withOpacity(0.2),
                    foregroundColor: Colors.cyanAccent,
                  ),
                ),
              ],
            ),
          ],

          // Saved semesters
          if (_semesters.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Semester History', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ..._semesters.asMap().entries.map((entry) {
              final sem = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(sem['semester'], style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text('SGPA: ${(sem['sgpa'] as double).toStringAsFixed(2)}',
                      style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontSize: 14)),
                    const SizedBox(width: 8),
                    Text('(${sem['credits']} cr)', style: TextStyle(color: Colors.white38, fontSize: 12)),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() { _semesters.removeAt(entry.key); _saveData(); });
                      },
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildSubjectEntry(int index) {
    final subject = _currentSubjects[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          // Subject name
          Expanded(
            flex: 3,
            child: TextField(
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Subject',
                hintStyle: TextStyle(color: Colors.white30),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (val) => _currentSubjects[index]['name'] = val,
              controller: TextEditingController(text: subject['name']),
            ),
          ),
          // Credits
          SizedBox(
            width: 50,
            child: DropdownButton<int>(
              value: subject['credits'],
              dropdownColor: const Color(0xFF1A1A2E),
              style: GoogleFonts.poppins(color: Colors.cyanAccent, fontSize: 13),
              underline: const SizedBox(),
              items: [1, 2, 3, 4, 5, 6].map((c) =>
                DropdownMenuItem(value: c, child: Text('${c}cr'))).toList(),
              onChanged: (val) => setState(() => _currentSubjects[index]['credits'] = val),
            ),
          ),
          // Grade
          SizedBox(
            width: 60,
            child: DropdownButton<String>(
              value: subject['grade'],
              dropdownColor: const Color(0xFF1A1A2E),
              style: GoogleFonts.poppins(color: Colors.greenAccent, fontSize: 13),
              underline: const SizedBox(),
              items: _activeGradePoints.keys.map((g) =>
                DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (val) => setState(() => _currentSubjects[index]['grade'] = val),
            ),
          ),
          // Delete
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => setState(() => _currentSubjects.removeAt(index)),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatIfTab() {
    final currentCgpa = _calculateCGPA();
    final targetCgpa = double.tryParse(_targetCgpaController.text) ?? 8.0;
    final maxGpa = _is10Point ? 10.0 : 4.0;
    final totalCredits = _semesters.fold(0, (s, sem) => s + (sem['credits'] as int));

    // Calculate required SGPA for next semester (assuming same credits)
    final avgCredits = totalCredits > 0 ? totalCredits ~/ _semesters.length : 20;
    double requiredSgpa = 0;
    if (_semesters.isNotEmpty && totalCredits > 0) {
      requiredSgpa = ((targetCgpa * (totalCredits + avgCredits)) - (currentCgpa * totalCredits)) / avgCredits;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GlassContainer(
            padding: const EdgeInsets.all(20),
            borderRadius: 16,
            child: Column(
              children: [
                Text('What-If Simulator', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 16)),
                const SizedBox(height: 16),
                Text('Current CGPA', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
                Text(currentCgpa > 0 ? currentCgpa.toStringAsFixed(2) : 'N/A',
                  style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text('Target CGPA', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 8),
                Slider(
                  value: targetCgpa.clamp(0, maxGpa),
                  min: 0,
                  max: maxGpa,
                  divisions: (maxGpa * 10).toInt(),
                  label: targetCgpa.toStringAsFixed(1),
                  activeColor: Colors.purpleAccent,
                  onChanged: (val) {
                    setState(() => _targetCgpaController.text = val.toStringAsFixed(1));
                  },
                ),
                Text(targetCgpa.toStringAsFixed(1),
                  style: GoogleFonts.orbitron(color: Colors.purpleAccent, fontSize: 20)),
                const SizedBox(height: 16),
                if (_semesters.isNotEmpty) ...[
                  Divider(color: Colors.white24),
                  const SizedBox(height: 8),
                  Text('Required SGPA next semester:', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(
                    requiredSgpa > maxGpa
                        ? 'Not achievable 😔'
                        : requiredSgpa <= 0
                            ? 'Already achieved! 🎉'
                            : requiredSgpa.toStringAsFixed(2),
                    style: GoogleFonts.orbitron(
                      color: requiredSgpa > maxGpa ? Colors.redAccent : Colors.greenAccent,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ] else
                  Text('Add semester data first', style: GoogleFonts.poppins(color: Colors.white38)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendTab() {
    if (_semesters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            Text('No semester data yet', style: GoogleFonts.poppins(color: Colors.white54)),
            Text('Save semesters in Calculator tab', style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GlassContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: 16,
            child: Column(
              children: [
                Text('SGPA Trend', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(color: Colors.white12, strokeWidth: 1),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, reservedSize: 40,
                            getTitlesWidget: (val, _) => Text(val.toStringAsFixed(1),
                              style: GoogleFonts.poppins(color: Colors.white38, fontSize: 10))),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, reservedSize: 30,
                            getTitlesWidget: (val, _) {
                              final idx = val.toInt();
                              if (idx >= 0 && idx < _semesters.length) {
                                return Text('S${idx + 1}',
                                  style: GoogleFonts.poppins(color: Colors.white38, fontSize: 10));
                              }
                              return const SizedBox();
                            }),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      minY: 0,
                      maxY: _is10Point ? 10 : 4,
                      lineBarsData: [
                        LineChartBarData(
                          spots: _semesters.asMap().entries.map((e) =>
                            FlSpot(e.key.toDouble(), e.value['sgpa'] as double)).toList(),
                          isCurved: true,
                          color: Colors.cyanAccent,
                          barWidth: 3,
                          dotData: FlDotData(show: true, getDotPainter: (spot, _, __, ___) =>
                            FlDotCirclePainter(radius: 5, color: Colors.cyanAccent, strokeWidth: 2, strokeColor: Colors.white)),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.cyanAccent.withOpacity(0.3), Colors.transparent],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
