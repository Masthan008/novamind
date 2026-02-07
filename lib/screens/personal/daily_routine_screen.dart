import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../services/supabase_data_service.dart';
import '../../services/student_auth_service.dart';

class DailyRoutineScreen extends StatefulWidget {
  const DailyRoutineScreen({super.key});

  @override
  State<DailyRoutineScreen> createState() => _DailyRoutineScreenState();
}

class _DailyRoutineScreenState extends State<DailyRoutineScreen> with SingleTickerProviderStateMixin {
  final _dataService = SupabaseDataService();
  List<Map<String, dynamic>> _routines = [];
  bool _isLoading = true;
  late AnimationController _fabController;
  
  final List<String> _days = ['Everyday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  String _selectedDay = 'Everyday';
  
  // Category colors
  final Map<String, Color> _categoryColors = {
    'Study': Colors.blueAccent,
    'Exercise': Colors.greenAccent,
    'Break': Colors.orangeAccent,
    'Meal': Colors.pinkAccent,
    'Sleep': Colors.purpleAccent,
    'Other': Colors.cyanAccent,
  };

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _loadRoutines();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  Future<void> _loadRoutines() async {
    setState(() => _isLoading = true);
    final routines = await _dataService.getMyRoutine();
    if (mounted) {
      setState(() {
        _routines = routines;
        _isLoading = false;
      });
    }
  }

  void _showAddRoutineDialog() {
    final activityController = TextEditingController();
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    String selectedCategory = 'Study';
    String selectedDay = 'Everyday';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
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
                    Text(
                      '✨ Add New Routine',
                      style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Plan your perfect day',
                      style: GoogleFonts.poppins(color: Colors.white54),
                    ),
                    const SizedBox(height: 32),

                    // Activity Name
                    _buildInputField(
                      controller: activityController,
                      label: 'Activity Name',
                      hint: 'e.g., Morning Study Session',
                      icon: Icons.edit_note_rounded,
                    ),
                    const SizedBox(height: 20),

                    // Time Selection Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimeButton(
                            label: 'Start Time',
                            time: startTime,
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: ThemeData.dark().copyWith(
                                      colorScheme: const ColorScheme.dark(
                                        primary: Colors.cyanAccent,
                                        surface: Color(0xFF1a1a2e),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (time != null) {
                                setModalState(() => startTime = time);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTimeButton(
                            label: 'End Time',
                            time: endTime,
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: startTime ?? TimeOfDay.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: ThemeData.dark().copyWith(
                                      colorScheme: const ColorScheme.dark(
                                        primary: Colors.cyanAccent,
                                        surface: Color(0xFF1a1a2e),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (time != null) {
                                setModalState(() => endTime = time);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Category Selection
                    Text('Category', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _categoryColors.entries.map((entry) {
                        final isSelected = selectedCategory == entry.key;
                        return InkWell(
                          onTap: () => setModalState(() => selectedCategory = entry.key),
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? entry.value.withOpacity(0.3) : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? entry.value : Colors.white10,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Text(
                              entry.key,
                              style: GoogleFonts.poppins(
                                color: isSelected ? entry.value : Colors.white54,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Day Selection
                    Text('Day', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _days.length,
                        itemBuilder: (context, index) {
                          final day = _days[index];
                          final isSelected = selectedDay == day;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () => setModalState(() => selectedDay = day),
                              borderRadius: BorderRadius.circular(20),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.cyanAccent.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? Colors.cyanAccent : Colors.white10,
                                  ),
                                ),
                                child: Text(
                                  day.substring(0, 3),
                                  style: GoogleFonts.poppins(
                                    color: isSelected ? Colors.cyanAccent : Colors.white54,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Add Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (activityController.text.isEmpty || startTime == null || endTime == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please fill all fields', style: GoogleFonts.poppins()),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }

                          final startTimeStr = '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}:00';
                          final endTimeStr = '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}:00';
                          
                          final success = await _dataService.addRoutineItem(
                            '$selectedCategory: ${activityController.text}',
                            startTimeStr,
                            endTimeStr,
                            dayOfWeek: selectedDay,
                          );

                          if (success && mounted) {
                            Navigator.pop(context);
                            _loadRoutines();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('✅ Routine added!', style: GoogleFonts.poppins()),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('❌ Failed to add routine', style: GoogleFonts.poppins()),
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
                        child: Text(
                          'Add to Routine',
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: TextField(
            controller: controller,
            style: GoogleFonts.poppins(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(color: Colors.white30),
              prefixIcon: Icon(icon, color: Colors.cyanAccent),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeButton({
    required String label,
    required TimeOfDay? time,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: time != null ? Colors.cyanAccent.withOpacity(0.5) : Colors.white10),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: time != null ? Colors.cyanAccent : Colors.white30, size: 20),
                const SizedBox(width: 8),
                Text(
                  time != null ? time.format(context) : 'Select',
                  style: GoogleFonts.poppins(color: time != null ? Colors.white : Colors.white30),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String activityName) {
    for (final category in _categoryColors.keys) {
      if (activityName.toLowerCase().contains(category.toLowerCase())) {
        return _categoryColors[category]!;
      }
    }
    return Colors.cyanAccent;
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          'Daily Routine',
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: _loadRoutines,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddRoutineDialog,
        backgroundColor: Colors.cyanAccent,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: Text('Add', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ).animate().scale(delay: 300.ms),
      body: Stack(
        children: [
          // Background gradients
          Positioned(
            top: -150,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.blueAccent.withOpacity(0.3), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.purpleAccent.withOpacity(0.2), Colors.transparent],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Day filter
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _days.length,
                    itemBuilder: (context, index) {
                      final day = _days[index];
                      final isSelected = _selectedDay == day;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () => setState(() => _selectedDay = day),
                          borderRadius: BorderRadius.circular(25),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(colors: [Colors.cyanAccent, Colors.blueAccent])
                                  : null,
                              color: isSelected ? null : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: isSelected
                                  ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.3), blurRadius: 10)]
                                  : null,
                            ),
                            child: Text(
                              day.length > 3 ? day.substring(0, 3) : day,
                              style: GoogleFonts.poppins(
                                color: isSelected ? Colors.black : Colors.white54,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: index * 50));
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Routine list
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
                      : _routines.isEmpty
                          ? _buildEmptyState()
                          : _buildRoutineList(),
                ),
              ],
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
          Icon(Icons.schedule, size: 80, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 24),
          Text(
            'No routine set yet',
            style: GoogleFonts.orbitron(color: Colors.white38, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to plan your day',
            style: GoogleFonts.poppins(color: Colors.white24),
          ),
        ],
      ).animate().fadeIn().scale(),
    );
  }

  Widget _buildRoutineList() {
    // Filter by selected day
    final filtered = _routines.where((r) {
      final day = r['day_of_week'] ?? 'Everyday';
      return _selectedDay == 'Everyday' || day == 'Everyday' || day == _selectedDay;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'No activities for $_selectedDay',
          style: GoogleFonts.poppins(color: Colors.white38),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        final activityName = item['activity_name'] ?? 'Activity';
        final startTime = (item['start_time'] ?? '00:00:00').toString().substring(0, 5);
        final endTime = (item['end_time'] ?? '00:00:00').toString().substring(0, 5);
        final color = _getCategoryColor(activityName);

        return Dismissible(
          key: Key(item['id']),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.delete, color: Colors.redAccent),
          ),
          onDismissed: (direction) async {
            await _dataService.deleteRoutineItem(item['id']);
            _loadRoutines();
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time column
                SizedBox(
                  width: 60,
                  child: Column(
                    children: [
                      Text(
                        startTime,
                        style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Container(
                        width: 2,
                        height: 40,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [color, color.withOpacity(0.2)],
                          ),
                        ),
                      ),
                      Text(
                        endTime,
                        style: GoogleFonts.orbitron(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                
                // Activity card
                Expanded(
                  child: GlassmorphicContainer(
                    width: double.infinity,
                    height: 90,
                    borderRadius: 20,
                    blur: 20,
                    alignment: Alignment.center,
                    border: 1,
                    linearGradient: LinearGradient(
                      colors: [color.withOpacity(0.15), Colors.white.withOpacity(0.05)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderGradient: LinearGradient(
                      colors: [color.withOpacity(0.5), Colors.white.withOpacity(0.1)],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 50,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  activityName,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item['day_of_week'] ?? 'Everyday'}',
                                  style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.drag_indicator, color: Colors.white24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: index * 100)).slideX(begin: 0.1),
        );
      },
    );
  }
}
