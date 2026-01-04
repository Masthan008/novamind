import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/class_session.dart';
import '../services/timetable_service.dart';
import '../services/timetable_manager.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  // Default values (will be overwritten by Hive)
  String _currentBranch = "CSE-CS"; 
  String _currentSection = "A";

  @override
  void initState() {
    super.initState();
    _loadSavedPreferences();
  }

  // 📥 Load saved Branch/Section so the header is correct
  void _loadSavedPreferences() {
    final box = Hive.box('user_prefs'); // Ensure you open this box in main.dart
    setState(() {
      _currentBranch = box.get('branch', defaultValue: 'CSE-CS');
      _currentSection = box.get('section', defaultValue: 'A');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      
      // 🚀 1. THE MISSING FLOATING BUTTON
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.cyanAccent,
        icon: const Icon(Icons.swap_horiz, color: Colors.black),
        label: const Text("CHANGE CLASS", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        onPressed: _showSelectionModal,
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 🏷️ HEADER SECTION
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.cyanAccent, size: 24),
                      onPressed: () {
                        // 🛡️ SAFETY CHECK
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          // If no history, force go to Home
                          Navigator.pushReplacementNamed(context, '/home'); 
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Timetable', style: GoogleFonts.orbitron(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
                          // 🔍 DYNAMIC HEADER (Shows current class)
                          Text('$_currentBranch - $_currentSection', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 📅 THE LIST (Listening to Hive)
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: Hive.box<ClassSession>('class_sessions').listenable(),
                  builder: (context, Box<ClassSession> box, _) {
                    final sessions = box.values.toList();
                    
                    if (sessions.isEmpty) {
                      return _buildEmptyState();
                    }

                    // Sort and Group logic...
                    final now = DateTime.now();
                    final today = now.weekday;
                    final sessionsByDay = <int, List<ClassSession>>{};
                    
                    for (var session in sessions) {
                      sessionsByDay.putIfAbsent(session.dayOfWeek, () => []);
                      sessionsByDay[session.dayOfWeek]!.add(session);
                    }

                    // Sort logic
                    for (var list in sessionsByDay.values) {
                      list.sort((a, b) => a.startTime.compareTo(b.startTime));
                    }

                    // Day Names
                    final dayNames = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 80), // Padding for FAB
                      itemCount: sessionsByDay.length,
                      itemBuilder: (context, index) {
                        final dayKeys = sessionsByDay.keys.toList()..sort();
                        final day = dayKeys[index];
                        final daySessions = sessionsByDay[day]!;
                        
                        // Highlight Today
                        final isToday = day == today;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                dayNames[day],
                                style: GoogleFonts.orbitron(
                                  color: isToday ? Colors.cyanAccent : Colors.white60,
                                  fontSize: 18,
                                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                            ...daySessions.map((s) => _buildClassCard(s)),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🛠️ 2. THE SELECTION MODAL (This fixes the data not saving)
  void _showSelectionModal() {
    // 🟢 FIX 1: Initialize with CURRENT saved values, not defaults!
    String selectedBranch = _currentBranch; 
    String selectedSection = _currentSection;
    
    // ⚠️ Ensure these match your Data Keys EXACTLY
    // "ME" must match the key "ME_A" in TimetableData
    final branches = ["CSE", "CSE-CS", "CSE-DS", "CSE-AIML", "ECE", "EEE", "ME"];
    final sections = ["A", "B", "C", "D", "E", "F"];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              height: 350,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Select Class", style: GoogleFonts.orbitron(color: Colors.white, fontSize: 20)),
                  const SizedBox(height: 20),
                  
                  // BRANCH DROPDOWN
                  _buildDropdown("Branch", selectedBranch, branches, (val) {
                    setModalState(() => selectedBranch = val!);
                  }),
                  
                  const SizedBox(height: 16),
                  
                  // SECTION DROPDOWN
                  _buildDropdown("Section", selectedSection, sections, (val) {
                    setModalState(() => selectedSection = val!);
                  }),

                  const Spacer(),
                  
                  // SAVE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
                      child: const Text("UPDATE TIMETABLE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        Navigator.pop(context); // Close modal first
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Updating to $selectedBranch - $selectedSection..."),
                            backgroundColor: Colors.blueAccent,
                          )
                        );

                        // 🟢 FIX 2: Wait for the update to finish
                        await TimetableManager.updateTimetable(selectedBranch, selectedSection);
                        
                        // 🟢 FIX 3: Update the local state so the Header changes immediately
                        // Save to Hive preference
                        var box = await Hive.openBox('user_prefs');
                        await box.put('branch', selectedBranch);
                        await box.put('section', selectedSection);

                        if (mounted) {
                          setState(() {
                            _currentBranch = selectedBranch;
                            _currentSection = selectedSection;
                          });

                          // Success Message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("✅ Done! Timetable Updated."), backgroundColor: Colors.green)
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildDropdown(String label, String val, List<String> items, Function(String?) changed) {
    return DropdownButtonFormField<String>(
      value: val,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white)))).toList(),
      onChanged: changed,
      dropdownColor: const Color(0xFF2E2E4E),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.cyanAccent),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_busy, size: 60, color: Colors.white24),
          const SizedBox(height: 20),
          Text("No Classes Found", style: GoogleFonts.orbitron(color: Colors.white70, fontSize: 18)),
          const Text("Tap 'CHANGE CLASS' below", style: TextStyle(color: Colors.white38)),
        ],
      ),
    );
  }

  Widget _buildClassCard(ClassSession s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(width: 4, height: 40, color: _getSubjectColor(s.subjectName)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.subjectName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text("${DateFormat('h:mm a').format(s.startTime)} - ${DateFormat('h:mm a').format(s.endTime)}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.notifications_active, color: Colors.white24, size: 18),
        ],
      ),
    );
  }

  Color _getSubjectColor(String sub) {
    if (sub.contains("LAB")) return Colors.pinkAccent;
    if (sub.contains("BCE")) return Colors.blueAccent;
    return Colors.cyanAccent;
  }
}
