import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/job_listing_model.dart';
import 'launchpad_service.dart';
import 'launchpad_job_card.dart';

class LaunchpadScreen extends StatefulWidget {
  const LaunchpadScreen({super.key});

  @override
  State<LaunchpadScreen> createState() => _LaunchpadScreenState();
}

class _LaunchpadScreenState extends State<LaunchpadScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<JobListing> _jobs = [];
  List<JobListing> _savedJobs = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _activeFilter = '';
  bool _showSaved = false;

  // Tab queries
  static const _tabQueries = [
    {'what': '', 'label': 'All'},
    {'what': 'internship', 'label': 'Internships'},
    {'what': 'software+engineer', 'label': 'Tech Jobs'},
    {'what': 'remote', 'where': 'remote', 'label': 'Remote'},
  ];

  static const _filterChips = [
    'Python',
    'Java',
    'Flutter',
    'Web',
    'ML',
    'Remote',
    'Fresher',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabQueries.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _fetchJobs();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    _activeFilter = '';
    _searchController.clear();
    _fetchJobs();
  }

  Future<void> _fetchJobs() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final tab = _tabQueries[_tabController.index];
      String query = tab['what'] ?? '';
      String where = tab['where'] ?? '';

      // Append search text
      final searchText = _searchController.text.trim();
      if (searchText.isNotEmpty) {
        query = query.isEmpty ? searchText : '$query $searchText';
      }

      // Append active filter chip
      if (_activeFilter.isNotEmpty) {
        query = query.isEmpty ? _activeFilter : '$query $_activeFilter';
      }

      final jobs = await LaunchpadService.getAllJobs(
        query: query,
        where: where,
      );

      if (mounted) {
        setState(() {
          _jobs = jobs;
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

  Future<void> _fetchSavedJobs() async {
    final saved = await LaunchpadService.getSavedJobs();
    if (mounted) {
      setState(() => _savedJobs = saved);
    }
  }

  Future<void> _toggleSave(JobListing job) async {
    if (job.isSaved) {
      await LaunchpadService.unsaveJob(job.id);
    } else {
      await LaunchpadService.saveJob(job);
    }

    if (mounted) {
      setState(() => job.isSaved = !job.isSaved);
      if (_showSaved) _fetchSavedJobs();
    }
  }

  void _onFilterTapped(String chip) {
    setState(() {
      _activeFilter = _activeFilter == chip ? '' : chip;
    });
    _fetchJobs();
  }

  void _toggleSavedView() {
    setState(() => _showSaved = !_showSaved);
    if (_showSaved) _fetchSavedJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0A0A1A),
                    Color(0xFF1A1A3E),
                    Color(0xFF0D0D2B),
                  ],
                ),
              ),
            ),
          ),

          // Accent orbs
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6C63FF).withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFF6B6B).withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                if (!_showSaved) ...[
                  _buildSearchBar(),
                  _buildFilterChips(),
                  _buildTabBar(),
                ],
                if (_showSaved)
                  _buildSavedHeader(),
                Expanded(
                  child: _showSaved ? _buildSavedList() : _buildJobList(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildSavedFab(),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _showSaved ? Icons.close : Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () {
              if (_showSaved) {
                _toggleSavedView();
              } else {
                Navigator.pop(context);
              }
            },
          ),
          const SizedBox(width: 4),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFFFF6B6B)],
            ).createShader(bounds),
            child: Text(
              _showSaved ? 'Saved Jobs' : '🚀 LaunchPad',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          if (!_showSaved)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_jobs.length} jobs',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.06),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: TextField(
          controller: _searchController,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search jobs, companies, skills...',
            hintStyle: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.3),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Colors.white.withOpacity(0.4),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear,
                        color: Colors.white.withOpacity(0.4), size: 18),
                    onPressed: () {
                      _searchController.clear();
                      _fetchJobs();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          onSubmitted: (_) => _fetchJobs(),
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.1);
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        itemCount: _filterChips.length,
        itemBuilder: (context, index) {
          final chip = _filterChips[index];
          final isActive = _activeFilter == chip;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () => _onFilterTapped(chip),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: isActive
                      ? const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF9C88FF)],
                        )
                      : null,
                  color: isActive ? null : Colors.white.withOpacity(0.06),
                  border: Border.all(
                    color: isActive
                        ? Colors.transparent
                        : Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Text(
                  chip,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 150.ms);
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: false,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF9C88FF)],
          ),
        ),
        labelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.4),
        dividerColor: Colors.transparent,
        tabs: _tabQueries.map((t) => Tab(text: t['label'])).toList(),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildSavedHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          Icon(Icons.bookmark_rounded,
              color: const Color(0xFF6C63FF), size: 20),
          const SizedBox(width: 8),
          Text(
            '${_savedJobs.length} saved jobs',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildJobList() {
    if (_isLoading) {
      return _buildLoadingShimmer();
    }

    if (_hasError) {
      return _buildErrorState();
    }

    if (_jobs.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _fetchJobs,
      color: const Color(0xFF6C63FF),
      backgroundColor: const Color(0xFF1A1A3E),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: _jobs.length,
        itemBuilder: (context, index) {
          return LaunchpadJobCard(
            job: _jobs[index],
            index: index,
            onSaveToggle: () => _toggleSave(_jobs[index]),
          );
        },
      ),
    );
  }

  Widget _buildSavedList() {
    if (_savedJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bookmark_border_rounded,
                size: 64, color: Colors.white.withOpacity(0.15)),
            const SizedBox(height: 16),
            Text(
              'No saved jobs yet',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bookmark jobs to view them here',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white.withOpacity(0.25),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: _savedJobs.length,
      itemBuilder: (context, index) {
        return LaunchpadJobCard(
          job: _savedJobs[index],
          index: index,
          onSaveToggle: () => _toggleSave(_savedJobs[index]),
        );
      },
    );
  }

  Widget _buildSavedFab() {
    return FloatingActionButton.extended(
      onPressed: _toggleSavedView,
      backgroundColor: _showSaved ? Colors.white.withOpacity(0.1) : const Color(0xFF6C63FF),
      icon: Icon(
        _showSaved ? Icons.work_outline_rounded : Icons.bookmark_rounded,
        color: Colors.white,
        size: 20,
      ),
      label: Text(
        _showSaved ? 'All Jobs' : 'Saved',
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3);
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          height: 140,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white.withOpacity(0.04),
          ),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: const Color(0xFF6C63FF).withOpacity(0.5),
              ),
            ),
          ),
        )
            .animate(
              onPlay: (c) => c.repeat(),
            )
            .shimmer(
              duration: 1500.ms,
              color: Colors.white.withOpacity(0.03),
            );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded,
              size: 56, color: Colors.white.withOpacity(0.15)),
          const SizedBox(height: 16),
          Text(
            'Couldn\'t load jobs',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _fetchJobs,
            icon: const Icon(Icons.refresh_rounded,
                color: Color(0xFF6C63FF), size: 18),
            label: Text(
              'Try again',
              style: GoogleFonts.poppins(
                color: const Color(0xFF6C63FF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.work_off_outlined,
              size: 56, color: Colors.white.withOpacity(0.15)),
          const SizedBox(height: 16),
          Text(
            'No jobs found',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search or filter',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}
