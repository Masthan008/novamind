import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:intl/intl.dart';
import '../../services/supabase_data_service.dart';

class PersonalDashboardScreen extends StatefulWidget {
  final int initialIndex;
  const PersonalDashboardScreen({super.key, this.initialIndex = 0});

  @override
  State<PersonalDashboardScreen> createState() => _PersonalDashboardScreenState();
}

class _PersonalDashboardScreenState extends State<PersonalDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _dataService = SupabaseDataService();
  
  // Dialog Controllers
  final _activityController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  
  final _diaryTitleController = TextEditingController();
  final _diaryContentController = TextEditingController();
  String _selectedMood = 'Happy';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _activityController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _diaryTitleController.dispose();
    _diaryContentController.dispose();
    super.dispose();
  }

  // --- Routine Functions ---
  void _showAddRoutineDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add Routine', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _activityController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Activity Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _startTimeController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Start Time (e.g. 08:00)'),
              onTap: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                if (time != null) {
                  // Format appropriately for Time column
                  _startTimeController.text = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _endTimeController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('End Time (e.g. 09:00)'),
              onTap: () async {
                 FocusScope.of(context).requestFocus(FocusNode());
                final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                if (time != null) {
                   _endTimeController.text = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (_activityController.text.isNotEmpty) {
                await _dataService.addRoutineItem(
                  _activityController.text, 
                  _startTimeController.text, 
                  _endTimeController.text
                );
                _activityController.clear();
                _startTimeController.clear();
                _endTimeController.clear();
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // --- Diary Functions ---
  void _showAddDiaryDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E2C),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Dear Diary...', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _diaryTitleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Title'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _diaryContentController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 5,
                    decoration: _inputDecoration('What happened today?'),
                  ),
                  const SizedBox(height: 16),
                  Text('Mood:', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Happy', 'Sad', 'Stressed', 'Excited', 'Tired'].map((mood) {
                      return ChoiceChip(
                        label: Text(mood),
                        selected: _selectedMood == mood,
                        onSelected: (selected) {
                          setState(() => _selectedMood = mood);
                        },
                        selectedColor: Colors.pinkAccent,
                        backgroundColor: Colors.white10,
                        labelStyle: TextStyle(color: _selectedMood == mood ? Colors.white : Colors.white70),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  if (_diaryContentController.text.isNotEmpty) {
                    await _dataService.saveDiaryEntry(
                      _diaryTitleController.text,
                      _diaryContentController.text,
                      _selectedMood,
                    );
                    _diaryTitleController.clear();
                    _diaryContentController.clear();
                    if (mounted) Navigator.pop(context);
                  }
                },
                child: const Text('Save Entry'),
              ),
            ],
          );
        }
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      appBar: AppBar(
        title: Text('Personal Space', style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.pinkAccent,
          labelColor: Colors.pinkAccent,
          unselectedLabelColor: Colors.white54,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.schedule), text: 'Daily Routine'),
            Tab(icon: Icon(Icons.book), text: 'My Diary'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRoutineTab(),
          _buildDiaryTab(),
        ],
      ),
    );
  }

  Widget _buildRoutineTab() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _dataService.getMyRoutine(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data!.isEmpty) return _buildEmptyState('No routine set. Plan your day!', Icons.schedule);

              final routines = snapshot.data!;
              return ListView.builder(
                itemCount: routines.length,
                itemBuilder: (context, index) {
                  final item = routines[index];
                  // Parse time nicely
                  final start = item['start_time'].toString().substring(0, 5);
                  final end = item['end_time'].toString().substring(0, 5);
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                         Column(
                           children: [
                             Text(start, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                             Container(width: 2, height: 40, color: Colors.pinkAccent.withOpacity(0.5)),
                             Text(end, style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12)),
                           ],
                         ),
                         const SizedBox(width: 16),
                         Expanded(
                           child: Container(
                             padding: const EdgeInsets.all(16),
                             decoration: BoxDecoration(
                               gradient: LinearGradient(colors: [Colors.pinkAccent.withOpacity(0.2), Colors.purpleAccent.withOpacity(0.1)]),
                               borderRadius: BorderRadius.circular(16),
                               border: Border.all(color: Colors.pinkAccent.withOpacity(0.3)),
                             ),
                             child: Row(
                               children: [
                                 Expanded(child: Text(item['activity_name'], style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500))),
                                 IconButton(
                                   icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 20),
                                   onPressed: () async {
                                     await _dataService.deleteRoutineItem(item['id']);
                                     setState(() {}); // Refresh
                                   },
                                 ),
                               ],
                             ),
                           ),
                         ),
                      ],
                    ),
                  ).animate().fadeIn(delay: Duration(milliseconds: index * 100)).slideX();
                },
              );
            },
          ),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            heroTag: 'routine',
            onPressed: _showAddRoutineDialog,
            backgroundColor: Colors.pinkAccent,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildDiaryTab() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _dataService.getMyDiaries(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data!.isEmpty) return _buildEmptyState('Your diary is empty. Start writing!', Icons.book);

              final entries = snapshot.data!;
              return ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  final date = DateTime.parse(entry['created_at']);
                  final formattedDate = DateFormat('MMM dd, yyyy').format(date);

                  return GlassmorphicContainer(
                      width: double.infinity,
                      height: 180,
                      borderRadius: 16,
                      blur: 20,
                      alignment: Alignment.center,
                      border: 1,
                      linearGradient: LinearGradient(
                        colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderGradient: LinearGradient(
                        colors: [Colors.white.withOpacity(0.5), Colors.white.withOpacity(0.0)],
                      ),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(formattedDate, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(entry['mood'] ?? 'Neutral', style: const TextStyle(color: Colors.purpleAccent, fontSize: 10)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              entry['title'] ?? 'Untitled',
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Expanded(child: Text(
                              entry['content'], 
                              maxLines: 4, 
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                            )),
                          ],
                        ),
                      ),
                  ).animate().fadeIn(delay: Duration(milliseconds: index * 100)).slideY();
                },
              );
            },
          ),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            heroTag: 'diary',
            onPressed: _showAddDiaryDialog,
            backgroundColor: Colors.purpleAccent,
            child: const Icon(Icons.edit),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: Colors.white24),
          const SizedBox(height: 16),
          Text(message, style: GoogleFonts.poppins(color: Colors.white38)),
        ],
      ),
    );
  }
}
