import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/supabase_data_service.dart';
import '../modules/news/news_screen.dart';

/// Notification bell widget with unread badge
/// Shows red dot when there are unread notifications
class NotificationBellWidget extends StatelessWidget {
  final Color iconColor;
  final double iconSize;
  final bool showBadge;
  
  const NotificationBellWidget({
    super.key,
    this.iconColor = Colors.white,
    this.iconSize = 24,
    this.showBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    final dataService = SupabaseDataService();
    
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: dataService.getMyNotificationsStream(),
      builder: (context, snapshot) {
        final notifications = snapshot.data ?? [];
        final unreadCount = notifications.where((n) => n['is_read'] == false).length;
        
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            // Navigate to News screen and switch to Buzz tab (index 1)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NewsScreen()),
            );
          },
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: iconColor,
                  size: iconSize,
                ),
              ),
              if (showBadge && unreadCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: EdgeInsets.all(unreadCount > 9 ? 3 : 5),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ).animate().scale(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.elasticOut,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
