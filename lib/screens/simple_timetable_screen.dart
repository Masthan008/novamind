import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/timetable_data.dart';
import '../services/class_notification_service.dart';
import '../services/timetable_preference_service.dart';
import 'timetable_selection_screen.dart';

class SimpleTimetableScreen extends StatefulWidget {
  const SimpleTimetableScreen({super.key});

  @override
  State<SimpleTimetableScreen> createState() => _SimpleTimetableScreenState();
}

class _SimpleTimetableScreenState extends State<SimpleTimetableScreen> {
  String _selectedDay = "Monday";
  String? _selectedBranch;
  String? _selectedSection;
  Map<String, List<String>> _currentSchedule = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedTimetable();
  }

  Future<void> _loadSavedTimetable() async {
    setState(() {
      _isLoading = true;
    });

    // Check if user has saved timetable
    if (TimetablePreferenceService.isSetupComplete()) {
      _selectedBranch = TimetablePreferenceService.getSelectedBranch();
      _selectedSection = TimetablePreferenceService.getSelectedSection();
      _updateSchedule();
    } else {
      // First time user - navigate to selection screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToSelection(isFirstTime: true);
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _updateSchedule() {
    if (_selectedBranch != null && _selectedSection != null) {
      setState(() {
        _currentSchedule = TimetableData.getSchedule(_selectedBranch!, _selectedSection!);
      });
    }
  }

  Future<void> _navigateToSelection({bool isFirstTime = false}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimetableSelectionScreen(isFirstTime: isFirstTime),
      ),
    );

    if (result == true || isFirstTime) {
      // Reload the timetable after selection
      _loadSavedTimetable();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.cyanAccent),
              const SizedBox(height: 16),
              Text(
                'Loading your timetable...',
                style: GoogleFonts.poppins(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    if (_selectedBranch == null || _selectedSection == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.schedule_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'No Timetable Selected',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please select your branch and section',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _navigateToSelection(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  'Select Timetable',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    List<String> todaysClasses = _currentSchedule[_selectedDay] ?? ["No Classes"];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Timetable 📅",
              style: GoogleFonts.orbitron(color: Colors.white),
            ),
            Text(
              TimetablePreferenceService.getFormattedTimetableId(),
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.cyanAccent,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.grey[900],
        iconTheme: IconThemeData(color: Colors.cyanAccent),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.cyanAccent),
            onPressed: () => _navigateToSelection(),
            tooltip: 'Change Timetable',
          ),
        ],
      ),
      
      // 🚀 BIG SWITCHER BUTTON (Bottom Right)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToSelection(),
        backgroundColor: Colors.cyanAccent,
        icon: const Icon(Icons.edit, color: Colors.black),
        label: Text(
          "CHANGE CLASS",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ).animate().scale(delay: 500.ms),

      body: Column(
        children: [
          // Status Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey[900]!,
                  Colors.grey[850]!,
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Text(
                  "Viewing: ${TimetablePreferenceService.getFormattedTimetableId()}",
                  style: GoogleFonts.poppins(
                    color: Colors.cyanAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Day Selector
          Container(
            height: 60,
            color: Colors.grey[900],
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                "Monday",
                "Tuesday",
                "Wednesday",
                "Thursday",
                "Friday",
                "Saturday"
              ]
                  .map((day) => Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ChoiceChip(
                          label: Text(day.substring(0, 3)),
                          selected: _selectedDay == day,
                          selectedColor: Colors.cyanAccent,
                          backgroundColor: Colors.grey[800],
                          labelStyle: TextStyle(
                            color: _selectedDay == day
                                ? Colors.black
                                : Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (bool selected) {
                            if (selected) setState(() => _selectedDay = day);
                          },
                        ),
                      ))
                  .toList(),
            ),
          ),

          // Period Timings Info
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.cyanAccent, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Period Timings',
                      style: GoogleFonts.poppins(
                        color: Colors.cyanAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'P1: 9:00-10:40 | Break: 10:40-11:00 | P2: 11:00-11:50\nLunch: 11:50-1:00 | P3: 1:00-1:50 | P4: 1:50-2:40 | P5: 3:00-5:00',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 10,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),

          // Class List
          Expanded(
            child: todaysClasses.isEmpty || todaysClasses[0] == "No Data"
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 80, // Space for FAB
                    ),
                    itemCount: todaysClasses.length,
                    itemBuilder: (context, index) {
                      final subject = todaysClasses[index];
                      final fullName = TimetableData.subjectNames[subject] ?? subject;
                      
                      return Card(
                        color: Colors.grey[850],
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.cyanAccent.withOpacity(0.3),
                          ),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.cyanAccent.withOpacity(0.2),
                            child: Text(
                              "${index + 1}",
                              style: const TextStyle(
                                color: Colors.cyanAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            subject,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            fullName,
                            style: GoogleFonts.poppins(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            _getPeriodTime(index),
                            style: GoogleFonts.poppins(
                              color: Colors.cyanAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: -0.1);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _getPeriodTime(int index) {
    final timings = [
      '9:00-10:40',
      '11:00-11:50',
      '1:00-1:50',
      '1:50-2:40',
      '3:00-5:00',
    ];
    return index < timings.length ? timings[index] : '';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 60, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            "No Schedule Found",
            style: GoogleFonts.poppins(
              color: Colors.grey,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try changing your timetable settings",
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _navigateToSelection(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              'Change Timetable',
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }
}
