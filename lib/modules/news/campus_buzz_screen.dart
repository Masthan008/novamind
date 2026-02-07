import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/supabase_data_service.dart';
import '../../services/student_auth_service.dart';

/// Campus Buzz - Social feed showing student doubts and notifications
/// Like Instagram/YouTube activity feed
class CampusBuzzScreen extends StatefulWidget {
  const CampusBuzzScreen({super.key});

  @override
  State<CampusBuzzScreen> createState() => _CampusBuzzScreenState();
}

class _CampusBuzzScreenState extends State<CampusBuzzScreen> with TickerProviderStateMixin {
  final SupabaseDataService _dataService = SupabaseDataService();
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a12),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // Hero Header
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF0a0a12),
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeroHeader(),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: _buildTabBar(),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildBuzzFeed(),
            _buildNotificationsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purpleAccent.withOpacity(0.2),
            Colors.cyanAccent.withOpacity(0.1),
            const Color(0xFF0a0a12),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Glow effect
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.purpleAccent.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: -40,
            bottom: 20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.cyanAccent.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.purpleAccent.withOpacity(0.3),
                              Colors.cyanAccent.withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.flash_on, color: Colors.amber, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Campus Buzz',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'See what students are asking',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ].animate(interval: 100.ms).fadeIn().slideX(begin: -0.1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: const Color(0xFF0a0a12),
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.cyanAccent,
        indicatorWeight: 3,
        labelColor: Colors.cyanAccent,
        unselectedLabelColor: Colors.white38,
        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.flash_on, size: 18),
                SizedBox(width: 6),
                Text('Live Feed'),
              ],
            ),
          ),
          Tab(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _dataService.getMyNotificationsStream(),
              builder: (context, snapshot) {
                final unreadCount = snapshot.data?.where((n) => n['is_read'] == false).length ?? 0;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.notifications, size: 18),
                    const SizedBox(width: 6),
                    const Text('Alerts'),
                    if (unreadCount > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$unreadCount',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuzzFeed() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _dataService.getDoubtsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        final doubts = snapshot.data ?? [];
        if (doubts.isEmpty) {
          return _buildEmptyState('No doubts yet!', 'Be the first to ask a question');
        }

        return RefreshIndicator(
          onRefresh: () async {
            HapticFeedback.lightImpact();
            await Future.delayed(const Duration(milliseconds: 500));
          },
          color: Colors.cyanAccent,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: doubts.length,
            itemBuilder: (context, index) {
              final doubt = doubts[index];
              return _buildDoubtCard(doubt, index);
            },
          ),
        );
      },
    );
  }

  Widget _buildDoubtCard(Map<String, dynamic> doubt, int index) {
    final question = doubt['question'] ?? '';
    final subject = doubt['subject'] ?? 'General';
    final studentName = doubt['student_name'] ?? 'Anonymous';
    final createdAt = doubt['created_at'];
    final answerCount = doubt['answer_count'] ?? 0;
    final isSolved = doubt['is_solved'] ?? false;
    
    // Get first letter for avatar
    final avatarLetter = studentName.isNotEmpty ? studentName[0].toUpperCase() : '?';
    
    // Time ago
    String timeAgo = '';
    if (createdAt != null) {
      try {
        final date = DateTime.parse(createdAt);
        final diff = DateTime.now().difference(date);
        if (diff.inMinutes < 60) {
          timeAgo = '${diff.inMinutes}m';
        } else if (diff.inHours < 24) {
          timeAgo = '${diff.inHours}h';
        } else if (diff.inDays < 7) {
          timeAgo = '${diff.inDays}d';
        } else {
          timeAgo = DateFormat('MMM d').format(date);
        }
      } catch (e) {
        timeAgo = '';
      }
    }
    
    // Subject color
    final subjectColors = {
      'Mathematics': Colors.blueAccent,
      'Physics': Colors.orangeAccent,
      'Chemistry': Colors.greenAccent,
      'Computer Science': Colors.purpleAccent,
      'English': Colors.pinkAccent,
      'Biology': Colors.tealAccent,
    };
    final subjectColor = subjectColors[subject] ?? Colors.cyanAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF15151f),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSolved ? Colors.greenAccent.withOpacity(0.3) : Colors.white.withOpacity(0.05),
        ),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pushNamed(context, '/doubt-detail', arguments: doubt);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Avatar with gradient
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [subjectColor.withOpacity(0.8), subjectColor.withOpacity(0.4)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        avatarLetter,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name and time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          studentName,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          timeAgo.isNotEmpty ? '$timeAgo ago' : 'Just now',
                          style: GoogleFonts.poppins(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Subject badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: subjectColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: subjectColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      subject,
                      style: GoogleFonts.poppins(
                        color: subjectColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Question
              Text(
                question,
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Footer
              Row(
                children: [
                  // Answers count
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          color: answerCount > 0 ? Colors.cyanAccent : Colors.white38,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$answerCount ${answerCount == 1 ? 'answer' : 'answers'}',
                          style: GoogleFonts.poppins(
                            color: answerCount > 0 ? Colors.cyanAccent : Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  if (isSolved) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.greenAccent, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            'Solved',
                            style: GoogleFonts.poppins(
                              color: Colors.greenAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const Spacer(),
                  
                  // View action
                  Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: index * 50)).fadeIn().slideY(begin: 0.1);
  }

  Widget _buildNotificationsTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _dataService.getMyNotificationsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        final notifications = snapshot.data ?? [];
        if (notifications.isEmpty) {
          return _buildEmptyState('No notifications yet', 'When someone replies to you, it\'ll show here');
        }

        return Column(
          children: [
            // Mark all read button
            if (notifications.any((n) => n['is_read'] == false))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _dataService.markAllNotificationsRead();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.cyanAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.done_all, color: Colors.cyanAccent, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Mark all as read',
                          style: GoogleFonts.poppins(
                            color: Colors.cyanAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _buildNotificationCard(notification, index);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
    final senderName = notification['sender_name'] ?? 'Someone';
    final message = notification['message'] ?? '';
    final isRead = notification['is_read'] ?? false;
    final createdAt = notification['created_at'];
    final notificationType = notification['notification_type'] ?? 'general';
    
    String timeAgo = '';
    if (createdAt != null) {
      try {
        final date = DateTime.parse(createdAt);
        final diff = DateTime.now().difference(date);
        if (diff.inMinutes < 60) {
          timeAgo = '${diff.inMinutes}m ago';
        } else if (diff.inHours < 24) {
          timeAgo = '${diff.inHours}h ago';
        } else {
          timeAgo = DateFormat('MMM d').format(date);
        }
      } catch (e) {
        timeAgo = '';
      }
    }

    final iconData = notificationType == 'answer' ? Icons.reply : Icons.notifications;
    final iconColor = notificationType == 'answer' ? Colors.greenAccent : Colors.cyanAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isRead ? const Color(0xFF12121a) : const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead ? Colors.transparent : Colors.cyanAccent.withOpacity(0.2),
        ),
      ),
      child: InkWell(
        onTap: () {
          if (!isRead) {
            _dataService.markNotificationRead(notification['id']);
          }
          HapticFeedback.lightImpact();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70),
                        children: [
                          TextSpan(
                            text: senderName,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          TextSpan(text: ' $message'),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeAgo,
                      style: GoogleFonts.poppins(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Unread indicator
              if (!isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.cyanAccent,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: index * 40)).fadeIn().slideX(begin: 0.05);
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.cyanAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const CircularProgressIndicator(color: Colors.cyanAccent, strokeWidth: 2),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading...',
            style: GoogleFonts.poppins(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.poppins(color: Colors.white38, fontSize: 13),
          ),
        ],
      ).animate().fadeIn(),
    );
  }
}
