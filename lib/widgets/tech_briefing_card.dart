import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/tech_news_service.dart';

/// A beautiful card that shows Morning/Evening Tech Briefing
/// Only fetches news during briefing hours to save API credits
class TechBriefingCard extends StatefulWidget {
  const TechBriefingCard({super.key});

  @override
  State<TechBriefingCard> createState() => _TechBriefingCardState();
}

class _TechBriefingCardState extends State<TechBriefingCard> {
  final TechNewsService _newsService = TechNewsService();
  List<Map<String, dynamic>> _articles = [];
  bool _isLoading = true;
  late BriefingTimeInfo _timeInfo;

  @override
  void initState() {
    super.initState();
    _timeInfo = TechNewsService.getBriefingTimeInfo();
    _checkTimeAndFetch();
  }

  void _checkTimeAndFetch() {
    if (_timeInfo.isBriefingTime) {
      _fetchNews();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchNews() async {
    final news = await _newsService.getDailyTechNews(limit: 5);
    if (mounted) {
      setState(() {
        _articles = news;
        _isLoading = false;
      });
    }
  }

  Future<void> _launchURL(String? url) async {
    if (url != null) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hide completely if it's not briefing time and no articles
    if (!_timeInfo.isBriefingTime && _articles.isEmpty && !_isLoading) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1a1a2e).withOpacity(0.9),
            const Color(0xFF16213e).withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.cyanAccent.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.cyanAccent.withOpacity(0.3), Colors.blueAccent.withOpacity(0.3)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.newspaper, color: Colors.cyanAccent, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _timeInfo.greeting,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _timeInfo.description,
                            style: GoogleFonts.poppins(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_isLoading)
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.cyanAccent,
                        ),
                      ),
                  ],
                ),
                
                if (_articles.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 12),
                  
                  // News items
                  ...List.generate(_articles.length, (index) {
                    final article = _articles[index];
                    return _buildNewsItem(article, index);
                  }),
                ] else if (!_isLoading && _timeInfo.isBriefingTime) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'No tech news available right now',
                      style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildNewsItem(Map<String, dynamic> article, int index) {
    return InkWell(
      onTap: () => _launchURL(article['url']),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            if (article['urlToImage'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  article['urlToImage'],
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.article, color: Colors.white24, size: 24),
                  ),
                ),
              )
            else
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.article, color: Colors.white24, size: 24),
              ),
            
            const SizedBox(width: 12),
            
            // Title and source
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article['title'] ?? 'No Title',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article['source']?['name'] ?? '',
                    style: GoogleFonts.poppins(
                      color: Colors.cyanAccent.withOpacity(0.7),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            
            const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: 100 * index)).fadeIn().slideX(begin: 0.1);
  }
}
