import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/tech_news_service.dart';

/// Dedicated Tech News Screen with premium UI
/// Shows daily tech news from NewsAPI.org
/// Set [showAppBar] to false when using inside a TabBarView
class TechNewsScreen extends StatefulWidget {
  final bool showAppBar;
  
  const TechNewsScreen({super.key, this.showAppBar = false});

  @override
  State<TechNewsScreen> createState() => _TechNewsScreenState();
}

class _TechNewsScreenState extends State<TechNewsScreen> with TickerProviderStateMixin {
  final TechNewsService _newsService = TechNewsService();
  List<Map<String, dynamic>> _articles = [];
  bool _isLoading = true;
  bool _hasError = false;
  late AnimationController _refreshController;
  
  // Category filters
  String _selectedCategory = 'All';
  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.apps, 'color': Colors.cyanAccent},
    {'name': 'AI', 'icon': Icons.psychology, 'color': Colors.purpleAccent},
    {'name': 'Blockchain', 'icon': Icons.link, 'color': Colors.orangeAccent},
    {'name': 'Cybersecurity', 'icon': Icons.security, 'color': Colors.redAccent},
    {'name': 'Gadgets', 'icon': Icons.devices, 'color': Colors.greenAccent},
    {'name': 'Startups', 'icon': Icons.rocket_launch, 'color': Colors.pinkAccent},
  ];

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _loadNews();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadNews() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final articles = await _newsService.getComprehensiveTechNews(limit: 25);
      if (mounted) {
        setState(() {
          _articles = articles;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.lightImpact();
    _refreshController.repeat();
    await _loadNews();
    _refreshController.stop();
    _refreshController.reset();
  }

  List<Map<String, dynamic>> get _filteredArticles {
    if (_selectedCategory == 'All') return _articles;
    
    // Filter by category keywords in title or description
    final keywords = {
      'AI': ['ai', 'artificial intelligence', 'machine learning', 'openai', 'chatgpt', 'neural', 'deep learning'],
      'Blockchain': ['blockchain', 'crypto', 'bitcoin', 'ethereum', 'nft', 'web3', 'defi'],
      'Cybersecurity': ['cyber', 'security', 'hack', 'breach', 'malware', 'ransomware', 'privacy'],
      'Gadgets': ['gadget', 'device', 'smartphone', 'iphone', 'samsung', 'laptop', 'wearable'],
      'Startups': ['startup', 'funding', 'venture', 'unicorn', 'ipo', 'investment'],
    };
    
    final categoryKeywords = keywords[_selectedCategory] ?? [];
    
    return _articles.where((article) {
      final title = (article['title'] ?? '').toString().toLowerCase();
      final description = (article['description'] ?? '').toString().toLowerCase();
      final combined = '$title $description';
      
      return categoryKeywords.any((keyword) => combined.contains(keyword));
    }).toList();
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
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a12),
      body: CustomScrollView(
        slivers: [
          // Only show app bar when used standalone
          if (widget.showAppBar)
            SliverAppBar(
              expandedHeight: 140,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFF0a0a12),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                AnimatedBuilder(
                  animation: _refreshController,
                  builder: (context, child) => Transform.rotate(
                    angle: _refreshController.value * 2 * 3.14159,
                    child: IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.cyanAccent),
                      onPressed: _handleRefresh,
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.cyanAccent.withOpacity(0.3), Colors.blueAccent.withOpacity(0.3)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.trending_up, color: Colors.cyanAccent, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Tech News',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.cyanAccent.withOpacity(0.15),
                        Colors.blueAccent.withOpacity(0.1),
                        const Color(0xFF0a0a12),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -50,
                        top: -20,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.cyanAccent.withOpacity(0.15),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Category Filter Chips
          SliverToBoxAdapter(
            child: Container(
              height: 50,
              margin: const EdgeInsets.only(top: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category['name'];
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedCategory = category['name']);
                      },
                      borderRadius: BorderRadius.circular(25),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (category['color'] as Color).withOpacity(0.25)
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isSelected ? category['color'] as Color : Colors.white10,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              category['icon'] as IconData,
                              color: category['color'] as Color,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              category['name'] as String,
                              style: GoogleFonts.poppins(
                                color: isSelected ? category['color'] as Color : Colors.white54,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: Duration(milliseconds: index * 50));
                },
              ),
            ),
          ),

          // Content
          if (_isLoading)
            SliverFillRemaining(child: _buildLoadingState())
          else if (_hasError)
            SliverFillRemaining(child: _buildErrorState())
          else if (_filteredArticles.isEmpty)
            SliverFillRemaining(child: _buildEmptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final article = _filteredArticles[index];
                    return _buildNewsCard(article, index);
                  },
                  childCount: _filteredArticles.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.cyanAccent.withOpacity(0.2), Colors.blueAccent.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const CircularProgressIndicator(color: Colors.cyanAccent, strokeWidth: 3),
          ),
          const SizedBox(height: 20),
          Text(
            'Fetching latest tech news...',
            style: GoogleFonts.poppins(color: Colors.white54),
          ),
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: 64, color: Colors.redAccent.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'Unable to load news',
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _loadNews,
            icon: const Icon(Icons.refresh, color: Colors.cyanAccent),
            label: Text('Try Again', style: GoogleFonts.poppins(color: Colors.cyanAccent)),
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
          Icon(Icons.search_off, size: 64, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            'No articles found for $_selectedCategory',
            style: GoogleFonts.poppins(color: Colors.white54),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => setState(() => _selectedCategory = 'All'),
            child: Text('Show All News', style: GoogleFonts.poppins(color: Colors.cyanAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(Map<String, dynamic> article, int index) {
    final title = article['title'] ?? 'No Title';
    final description = article['description'] ?? '';
    final imageUrl = article['urlToImage'];
    final source = article['source']?['name'] ?? 'Unknown';
    final publishedAt = article['publishedAt'];
    
    String timeAgo = '';
    if (publishedAt != null) {
      try {
        final date = DateTime.parse(publishedAt);
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

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF15151f),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: InkWell(
        onTap: () => _launchURL(article['url']),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  children: [
                    Image.network(
                      imageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.cyanAccent.withOpacity(0.1), Colors.purpleAccent.withOpacity(0.1)],
                          ),
                        ),
                        child: const Center(child: Icon(Icons.article, color: Colors.white24, size: 40)),
                      ),
                    ),
                    // Gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                          ),
                        ),
                      ),
                    ),
                    // Source badge
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.source, color: Colors.cyanAccent, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              source,
                              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 12,
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (timeAgo.isNotEmpty) ...[
                        Icon(Icons.access_time, color: Colors.cyanAccent.withOpacity(0.7), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          timeAgo,
                          style: GoogleFonts.poppins(color: Colors.cyanAccent.withOpacity(0.7), fontSize: 11),
                        ),
                      ],
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.cyanAccent.withOpacity(0.2), Colors.blueAccent.withOpacity(0.2)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Read More',
                              style: GoogleFonts.poppins(
                                color: Colors.cyanAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward, color: Colors.cyanAccent, size: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: index * 80)).fadeIn().slideY(begin: 0.1);
  }
}
