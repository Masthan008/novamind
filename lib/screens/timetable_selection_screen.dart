import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/timetable_preference_service.dart';
import '../services/class_notification_service.dart';

class TimetableSelectionScreen extends StatefulWidget {
  final bool isFirstTime;
  
  const TimetableSelectionScreen({
    super.key,
    this.isFirstTime = true,
  });

  @override
  State<TimetableSelectionScreen> createState() => _TimetableSelectionScreenState();
}

class _TimetableSelectionScreenState extends State<TimetableSelectionScreen> {
  String? _selectedBranch;
  String? _selectedSection;
  bool _isLoading = false;

  final Map<String, List<String>> _availableTimetables = 
      TimetablePreferenceService.getAvailableTimetables();
  final Map<String, String> _branchDisplayNames = 
      TimetablePreferenceService.getBranchDisplayNames();

  @override
  void initState() {
    super.initState();
    if (!widget.isFirstTime) {
      // Load current selection if editing
      _selectedBranch = TimetablePreferenceService.getSelectedBranch();
      _selectedSection = TimetablePreferenceService.getSelectedSection();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1A2E),
              const Color(0xFF16213E),
              const Color(0xFF0F3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard(),
                      const SizedBox(height: 24),
                      _buildBranchSelection(),
                      if (_selectedBranch != null) ...[
                        const SizedBox(height: 24),
                        _buildSectionSelection(),
                      ],
                      const SizedBox(height: 32),
                      if (_selectedBranch != null && _selectedSection != null)
                        _buildSaveButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (!widget.isFirstTime)
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.cyanAccent,
                size: 24,
              ),
              onPressed: () => Navigator.pop(context),
            ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isFirstTime ? 'Select Your Timetable' : 'Change Timetable',
                  style: GoogleFonts.orbitron(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyanAccent,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.3),
                Text(
                  widget.isFirstTime 
                      ? 'Choose your branch and section to get started'
                      : 'Update your class schedule',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.cyanAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.cyanAccent.withOpacity(0.3),
              ),
            ),
            child: Icon(
              Icons.schedule_rounded,
              color: Colors.cyanAccent,
              size: 24,
            ),
          ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.8, 0.8)),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.cyanAccent.withOpacity(0.1),
            Colors.cyanAccent.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.cyanAccent.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.cyanAccent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Available Timetables',
                style: GoogleFonts.poppins(
                  color: Colors.cyanAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'We have ${TimetablePreferenceService.getTotalTimetableCount()} timetables available across all branches. Select your branch and section to get personalized class schedules and notifications.',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3);
  }

  Widget _buildBranchSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Branch',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(delay: 600.ms),
        const SizedBox(height: 16),
        ...(_availableTimetables.keys.toList().asMap().entries.map((entry) {
          final index = entry.key;
          final branch = entry.value;
          final displayName = _branchDisplayNames[branch] ?? branch;
          final sectionCount = _availableTimetables[branch]!.length;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  setState(() {
                    _selectedBranch = branch;
                    _selectedSection = null; // Reset section when branch changes
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _selectedBranch == branch
                          ? [
                              Colors.cyanAccent.withOpacity(0.2),
                              Colors.cyanAccent.withOpacity(0.1),
                            ]
                          : [
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.05),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedBranch == branch
                          ? Colors.cyanAccent
                          : Colors.white.withOpacity(0.2),
                      width: _selectedBranch == branch ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _selectedBranch == branch
                              ? Colors.cyanAccent
                              : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.school,
                          color: _selectedBranch == branch
                              ? Colors.black
                              : Colors.white70,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              branch,
                              style: GoogleFonts.poppins(
                                color: _selectedBranch == branch
                                    ? Colors.cyanAccent
                                    : Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              displayName,
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _selectedBranch == branch
                              ? Colors.cyanAccent.withOpacity(0.2)
                              : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$sectionCount sections',
                          style: GoogleFonts.poppins(
                            color: _selectedBranch == branch
                                ? Colors.cyanAccent
                                : Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (_selectedBranch == branch)
                        Icon(
                          Icons.check_circle,
                          color: Colors.cyanAccent,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(delay: (700 + index * 100).ms).slideX(begin: -0.3);
        })),
      ],
    );
  }

  Widget _buildSectionSelection() {
    final sections = _availableTimetables[_selectedBranch!]!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Section',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(delay: 800.ms),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: sections.length,
          itemBuilder: (context, index) {
            final section = sections[index];
            
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  setState(() {
                    _selectedSection = section;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _selectedSection == section
                          ? [
                              Colors.cyanAccent.withOpacity(0.3),
                              Colors.cyanAccent.withOpacity(0.2),
                            ]
                          : [
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.05),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedSection == section
                          ? Colors.cyanAccent
                          : Colors.white.withOpacity(0.2),
                      width: _selectedSection == section ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Section',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        section,
                        style: GoogleFonts.orbitron(
                          color: _selectedSection == section
                              ? Colors.cyanAccent
                              : Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_selectedSection == section)
                        Icon(
                          Icons.check_circle,
                          color: Colors.cyanAccent,
                          size: 16,
                        ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(delay: (900 + index * 50).ms).scale(begin: const Offset(0.8, 0.8));
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.cyanAccent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: _isLoading ? null : _saveTimetable,
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.isFirstTime ? Icons.save : Icons.update,
                    color: Colors.black,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.isFirstTime ? 'Save & Continue' : 'Update Timetable',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.3);
  }

  Future<void> _saveTimetable() async {
    if (_selectedBranch == null || _selectedSection == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Save preferences
      await TimetablePreferenceService.saveSelectedTimetable(
        _selectedBranch!,
        _selectedSection!,
      );

      // Schedule notifications
      await ClassNotificationService.scheduleDailyClasses(
        _selectedBranch!,
        _selectedSection!,
      );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Timetable saved! Notifications scheduled for $_selectedBranch - Section $_selectedSection',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate back or to main screen
        if (widget.isFirstTime) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pop(context, true); // Return true to indicate update
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error saving timetable: $e',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}