import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';

import '../screens/bunk_meter/bunk_meter_screen.dart';
import '../screens/cgpa/cgpa_warroom_screen.dart';
import '../screens/exam_countdown/exam_countdown_screen.dart';
import '../screens/assignments/assignment_tracker_screen.dart';
import '../screens/tools_directory/tools_directory_screen.dart';
import '../screens/skill_gap/skill_gap_screen.dart';
import '../screens/opportunities/opportunities_screen.dart';
import '../screens/skillproof/skillproof_screen.dart';
import '../screens/community/community_screen.dart';
import '../screens/personal/daily_routine_screen.dart';
import '../screens/personal/diary_screen.dart';
import '../screens/launchpad/launchpad_screen.dart';
import '../screens/promptcraft/promptcraft_home_screen.dart';
import '../screens/quiz/quiz_topics_screen.dart';
import '../screens/leaderboard_screen.dart';
import '../screens/subscription_screen.dart';
import '../screens/shop/projects_screen.dart';
import '../screens/student_profile_screen.dart';
import '../screens/about_screen.dart';
import '../screens/settings/main_settings_screen.dart';
import '../screens/library_screen.dart';
import '../screens/video_library_screen.dart';
import '../screens/timetable_screen.dart';
import '../screens/devref/devref_hub_screen.dart';
import '../screens/login_screen.dart';
import '../modules/data_structures/data_structures_screen.dart';
import '../modules/cyber/cyber_vault_screen.dart';
import '../modules/news/news_screen.dart';
import '../modules/academic/syllabus_screen.dart';
import '../modules/academic/books_notes_screen.dart';
import '../modules/roadmaps/roadmaps_screen.dart';
import '../modules/ai/nova_chat_screen.dart';
import '../modules/study_companion/study_companion_screen.dart';
import '../modules/cybersecurity/cybersecurity_hub_screen.dart';
import '../features/code_lens/code_lens_screen.dart';
import '../features/lab_mesh/lab_mesh_screen.dart';
import '../services/student_auth_service.dart';
import '../widgets/user_badge.dart';

// Phase 2 imports
import '../screens/microdegrees/microdegrees_home_screen.dart';
import '../screens/mentors/mentor_marketplace_screen.dart';
import '../screens/skillmatch/skillmatch_screen.dart';
import '../screens/senior_connect/senior_connect_screen.dart';
import '../screens/build_public/build_public_screen.dart';
import '../screens/placement/placement_warroom_screen.dart';

// Phase 3 imports
import '../screens/admin/admin_panel_screen.dart';
import '../screens/college_dashboard/college_dashboard_screen.dart';
import '../screens/memory_wall/memory_wall_screen.dart';
import '../screens/confessions/confession_screen.dart';
import '../screens/professor_ratings/professor_rating_screen.dart';
import '../screens/lost_found/lost_found_screen.dart';
import '../screens/marketplace/student_marketplace_screen.dart';
import '../screens/pomodoro_battle/pomodoro_battle_screen.dart';
import '../screens/skill_dna/skill_dna_screen.dart';

/// Animated side menu widget inspired by the Rive App sample.
/// Displays user profile, navigation items, and settings in a
/// glassmorphic dark sidebar with scrollable content.
class AnimatedSideMenu extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onLogout;

  const AnimatedSideMenu({
    super.key,
    required this.onClose,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 288),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0D0D1A),
              const Color(0xFF141428),
              const Color(0xFF0A0A14),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.cyanAccent.withOpacity(0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(0.1),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        margin: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _buildMenuItems(context),
              ),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final box = Hive.box('user_prefs');

    String userName = 'Student';
    String? imageUrl;
    try {
      userName = box.get('user_name', defaultValue: 'Student') ?? 'Student';
      final student = StudentAuthService.currentStudent;
      if (student != null) {
        userName = student.name;
        imageUrl = student.imageUrl;
      }
    } catch (_) {}

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.cyanAccent.withOpacity(0.15),
            Colors.purple.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              GestureDetector(
                onTap: () {
                  onClose();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StudentProfileScreen(),
                    ),
                  );
                },
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.cyanAccent.withOpacity(0.4),
                        Colors.purple.withOpacity(0.3),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.cyanAccent.withOpacity(0.6),
                      width: 2,
                    ),
                  ),
                  child: imageUrl != null
                      ? ClipOval(
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person,
                              color: Colors.white70,
                              size: 24,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          color: Colors.white70,
                          size: 24,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'From Zero Skills to Real Opportunities',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Zerno branding
          ShaderMask(
            shaderCallback: (bounds) {
              if (bounds.isEmpty || bounds.width <= 0 || bounds.height <= 0) {
                return const LinearGradient(
                  colors: [Colors.white, Colors.white],
                ).createShader(const Rect.fromLTWH(0, 0, 1, 1));
              }
              return const LinearGradient(
                colors: [Colors.cyanAccent, Colors.white, Colors.cyanAccent],
              ).createShader(bounds);
            },
            child: Text(
              'ZERNO',
              style: GoogleFonts.orbitron(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── ACADEMIC ────────────────
          _sectionTitle('ACADEMIC'),
          _menuItem(Icons.auto_stories_outlined, 'Academic Syllabus', Colors.amber, context, const SyllabusScreen()),
          _menuItem(Icons.schedule, 'Timetable', Colors.teal, context, const TimetableScreen()),
          _menuItem(Icons.menu_book_outlined, 'Books & Notes', Colors.purple, context, const BooksNotesScreen()),
          _menuItem(Icons.how_to_reg, 'Bunk Meter', Colors.greenAccent, context, const BunkMeterScreen(), subtitle: 'Track attendance'),
          _menuItem(Icons.calculate, 'CGPA War Room', Colors.purpleAccent, context, const CgpaWarroomScreen(), subtitle: 'GPA & trends'),
          _menuItem(Icons.timer, 'Exam Countdown', Colors.orangeAccent, context, const ExamCountdownScreen(), subtitle: 'Track deadlines'),
          _menuItem(Icons.assignment, 'Assignments', Colors.amberAccent, context, const AssignmentTrackerScreen(), subtitle: 'Track tasks'),

          // ─── LEARNING ────────────────
          _sectionTitle('LEARNING'),
          _menuItem(Icons.code, 'Data Structures', Colors.cyan, context, const DataStructuresScreen()),
          _menuItem(Icons.security, 'Cyber Vault', Colors.red, context, const CyberVaultScreen()),
          _menuItem(Icons.shield, 'CyberSecurity Hub', Colors.deepOrange, context, const CybersecurityHubScreen()),
          _menuItem(Icons.integration_instructions, 'Code Lens', Colors.lightGreenAccent, context, const CodeLensScreen()),
          _menuItem(Icons.code_off, 'DevRef Hub', Colors.teal, context, const DevRefHubScreen()),
          _menuItem(Icons.quiz_outlined, 'Quiz Arena', Colors.amber, context, const QuizTopicsScreen()),
          _menuItem(Icons.auto_awesome, 'PromptCraft', const Color(0xFFFF6B6B), context, const PromptcraftHomeScreen(), subtitle: 'Prompt Engineering'),
          _menuItem(Icons.school, 'Study Companion', Colors.indigo, context, const StudyCompanionScreen()),

          // ─── TOOLS ──────────────────
          _sectionTitle('ZERNO TOOLS'),
          _menuItem(Icons.apps, 'Free Tools', Colors.tealAccent, context, const ToolsDirectoryScreen(), subtitle: '60+ tools'),
          _menuItem(Icons.psychology, 'Skill Gap Analyzer', Colors.deepPurpleAccent, context, const SkillGapScreen(), subtitle: 'Find skill gaps'),
          _menuItem(Icons.emoji_events, 'Opportunities', Colors.amber, context, const OpportunitiesScreen(), subtitle: 'Hackathons & more'),
          _menuItem(Icons.verified, 'SkillProof', Colors.amber, context, const SkillProofScreen(), subtitle: 'Certificates'),

          // ─── COMMUNITY ──────────────
          _sectionTitle('HUB'),
          _menuItem(Icons.auto_awesome, 'Zerno AI', const Color(0xFFFF6B6B), context, const NovaChatScreen(), subtitle: 'AI assistant'),
          _menuItem(Icons.newspaper, 'News & Buzz', Colors.deepPurple, context, const NewsScreen()),
          _menuItem(Icons.wifi_tethering_rounded, 'LabMesh', Colors.greenAccent, context, const LabMeshScreen(), subtitle: 'Offline P2P'),
          _menuItem(Icons.rocket_launch, 'LaunchPad', const Color(0xFF6C63FF), context, const LaunchpadScreen(), subtitle: 'Jobs & Internships'),
          _menuItem(Icons.leaderboard_outlined, 'Leaderboard', Colors.amber, context, const LeaderboardScreen()),
          _menuItem(Icons.folder_special, 'Projects Store', Colors.purple, context, const ProjectsScreen()),
          _menuItem(Icons.menu_book_outlined, 'Student Library', Colors.green, context, const LibraryScreen()),
          _menuItem(Icons.play_circle_outlined, 'Video Library', Colors.blue, context, const VideoLibraryScreen()),
          _menuItem(Icons.route_outlined, 'Tech Roadmaps', Colors.blue, context, const RoadmapsScreen()),
          _menuItem(Icons.star, 'Subscription Plans', Colors.green, context, const SubscriptionScreen(), subtitle: 'Upgrade to Pro/Ultra'),

          // ─── PHASE 2 ────────────────
          _sectionTitle('PHASE 2'),
          _menuItem(Icons.workspace_premium, 'Zerno Pro', const Color(0xFFFF6B6B), context, const SubscriptionScreen(), subtitle: 'Subscription & Plans'),
          _menuItem(Icons.school, 'MicroDegrees', Colors.tealAccent, context, const MicrodegreesHomeScreen(), subtitle: 'Learn & Certify'),
          _menuItem(Icons.people, 'Mentors', Colors.orangeAccent, context, const MentorMarketplaceScreen(), subtitle: 'Book sessions'),
          _menuItem(Icons.handshake, 'SkillMatch', Colors.lightGreenAccent, context, const SkillmatchScreen(), subtitle: 'Jobs & Internships'),
          _menuItem(Icons.connect_without_contact, 'Senior Connect', Colors.pinkAccent, context, const SeniorConnectScreen(), subtitle: 'Alumni network'),
          _menuItem(Icons.rocket_launch, 'Build Public', Colors.deepPurpleAccent, context, const BuildPublicScreen(), subtitle: 'Ship & Share'),
          _menuItem(Icons.business_center, 'Placement', Colors.indigoAccent, context, const PlacementWarroomScreen(), subtitle: 'Companies & Prep'),

          // ─── PHASE 3 ────────────────
          _sectionTitle('CAMPUS LIFE'),
          _menuItem(Icons.admin_panel_settings, 'Admin Panel', Colors.redAccent, context, const AdminPanelScreen(), subtitle: 'Platform admin'),
          _menuItem(Icons.account_balance, 'College Hub', Colors.greenAccent, context, const CollegeDashboardScreen(), subtitle: 'TPO & Batch'),
          _menuItem(Icons.photo_library, 'Memory Wall', Colors.pinkAccent, context, const MemoryWallScreen(), subtitle: 'Campus photos'),
          _menuItem(Icons.lock, 'Confessions', Colors.deepPurpleAccent, context, const ConfessionScreen(), subtitle: 'Anonymous'),
          _menuItem(Icons.star_half, 'Prof Ratings', Colors.amber, context, const ProfessorRatingScreen(), subtitle: 'Rate teachers'),
          _menuItem(Icons.search, 'Lost & Found', Colors.tealAccent, context, const LostFoundScreen(), subtitle: 'Find items'),
          _menuItem(Icons.storefront, 'Marketplace', Colors.cyanAccent, context, const StudentMarketplaceScreen(), subtitle: 'Buy & Sell'),
          _menuItem(Icons.timer, 'Pomodoro Battle', Colors.amberAccent, context, const PomodoroBattleScreen(), subtitle: 'Focus wars'),
          _menuItem(Icons.fingerprint, 'Skill DNA', const Color(0xFF6C63FF), context, const SkillDnaScreen(), subtitle: 'Your profile'),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 6),
      child: Text(
        title,
        style: GoogleFonts.orbitron(
          color: Colors.cyanAccent.withOpacity(0.5),
          fontSize: 10,
          letterSpacing: 2,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _menuItem(
    IconData icon,
    String title,
    Color color,
    BuildContext context,
    Widget screen, {
    String? subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: color.withOpacity(0.15),
          highlightColor: color.withOpacity(0.08),
          onTap: () {
            onClose();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => screen),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        color.withOpacity(0.25),
                        color.withOpacity(0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            color: Colors.white38,
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
      ),
      child: Column(
        children: [
          // Settings
          _footerItem(Icons.settings_outlined, 'Settings', Colors.grey, () {
            onClose();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MainSettingsScreen()),
            );
          }),
          // Profile
          _footerItem(Icons.person_outline, 'Profile', Colors.teal, () {
            onClose();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const StudentProfileScreen(),
              ),
            );
          }),
          // About
          _footerItem(Icons.info_outline, 'About Zerno', Colors.cyanAccent, () {
            onClose();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            );
          }),
          // Logout
          _footerItem(Icons.logout, 'Logout', Colors.redAccent, onLogout),
        ],
      ),
    );
  }

  Widget _footerItem(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        splashColor: color.withOpacity(0.15),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              Icon(icon, color: color.withOpacity(0.7), size: 18),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
