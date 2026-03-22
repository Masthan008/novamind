import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/glass_container.dart';

/// Opportunity Alerts — Curated hackathons, internships, scholarships
///
/// Supabase Table SQL:
/// CREATE TABLE IF NOT EXISTS opportunities (
///   id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
///   title TEXT NOT NULL,
///   description TEXT,
///   category TEXT NOT NULL,
///   deadline TIMESTAMPTZ,
///   url TEXT,
///   organization TEXT,
///   is_active BOOLEAN DEFAULT TRUE,
///   created_at TIMESTAMPTZ DEFAULT NOW()
/// );

class OpportunitiesScreen extends StatefulWidget {
  const OpportunitiesScreen({super.key});

  @override
  State<OpportunitiesScreen> createState() => _OpportunitiesScreenState();
}

class _OpportunitiesScreenState extends State<OpportunitiesScreen> {
  late Box _savedBox;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  Set<String> _savedIds = {};

  static const List<String> categories = [
    'All', 'Hackathons', 'Internships', 'Scholarships', 'Competitions', 'Workshops', 'Open Source',
  ];

  // Sample curated opportunities
  static final List<Map<String, dynamic>> _sampleOpportunities = [
    {'id': '1', 'title': 'MLH Global Hack Week', 'description': 'Week-long hackathon with workshops and prizes', 'category': 'Hackathons', 'organization': 'Major League Hacking', 'url': 'https://mlh.io', 'deadline': DateTime.now().add(const Duration(days: 14)).toIso8601String()},
    {'id': '2', 'title': 'Google Summer of Code', 'description': 'Contribute to open source projects with Google mentorship', 'category': 'Open Source', 'organization': 'Google', 'url': 'https://summerofcode.withgoogle.com', 'deadline': DateTime.now().add(const Duration(days: 45)).toIso8601String()},
    {'id': '3', 'title': 'LFX Mentorship', 'description': 'Linux Foundation mentorship program for open source', 'category': 'Open Source', 'organization': 'Linux Foundation', 'url': 'https://mentorship.lfx.linuxfoundation.org', 'deadline': DateTime.now().add(const Duration(days: 30)).toIso8601String()},
    {'id': '4', 'title': 'Microsoft Imagine Cup', 'description': 'Global student technology competition', 'category': 'Competitions', 'organization': 'Microsoft', 'url': 'https://imaginecup.microsoft.com', 'deadline': DateTime.now().add(const Duration(days: 60)).toIso8601String()},
    {'id': '5', 'title': 'MITACS Globalink', 'description': 'Research internship in Canada for undergrads', 'category': 'Internships', 'organization': 'MITACS', 'url': 'https://mitacs.ca', 'deadline': DateTime.now().add(const Duration(days: 90)).toIso8601String()},
    {'id': '6', 'title': 'GitHub Externship', 'description': 'Remote externship program for students', 'category': 'Internships', 'organization': 'GitHub', 'url': 'https://github.com', 'deadline': DateTime.now().add(const Duration(days: 20)).toIso8601String()},
    {'id': '7', 'title': 'Smart India Hackathon', 'description': 'India\u0027s largest hackathon by MHRD', 'category': 'Hackathons', 'organization': 'MHRD', 'url': 'https://sih.gov.in', 'deadline': DateTime.now().add(const Duration(days: 40)).toIso8601String()},
    {'id': '8', 'title': 'AICTE Pragati Scholarship', 'description': 'Scholarship for girl students in technical education', 'category': 'Scholarships', 'organization': 'AICTE', 'url': 'https://aicte-india.org', 'deadline': DateTime.now().add(const Duration(days: 50)).toIso8601String()},
    {'id': '9', 'title': 'HacktoberFest', 'description': 'Month-long celebration of open source (October)', 'category': 'Open Source', 'organization': 'DigitalOcean', 'url': 'https://hacktoberfest.com', 'deadline': DateTime.now().add(const Duration(days: 120)).toIso8601String()},
    {'id': '10', 'title': 'AWS Cloud Workshop', 'description': 'Free cloud computing workshops for students', 'category': 'Workshops', 'organization': 'Amazon', 'url': 'https://aws.amazon.com/education', 'deadline': DateTime.now().add(const Duration(days: 15)).toIso8601String()},
    {'id': '11', 'title': 'GirlScript Summer of Code', 'description': 'Open source program for beginners', 'category': 'Open Source', 'organization': 'GirlScript', 'url': 'https://gssoc.girlscript.tech', 'deadline': DateTime.now().add(const Duration(days: 35)).toIso8601String()},
    {'id': '12', 'title': 'CodeChef SnackDown', 'description': 'Global competitive programming contest', 'category': 'Competitions', 'organization': 'CodeChef', 'url': 'https://codechef.com', 'deadline': DateTime.now().add(const Duration(days: 25)).toIso8601String()},
  ];

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  void _loadSaved() {
    _savedBox = Hive.box('saved_opportunities');
    final saved = _savedBox.get('saved_ids');
    if (saved != null) _savedIds = Set<String>.from(saved as List);
  }

  void _toggleSaved(String id) {
    HapticFeedback.lightImpact();
    setState(() {
      _savedIds.contains(id) ? _savedIds.remove(id) : _savedIds.add(id);
      _savedBox.put('saved_ids', _savedIds.toList());
    });
  }

  List<Map<String, dynamic>> get _filtered {
    return _sampleOpportunities.where((o) {
      final matchesCat = _selectedCategory == 'All' || o['category'] == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          (o['title'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (o['organization'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
      // Hide expired
      final deadline = DateTime.tryParse(o['deadline'] ?? '');
      final isActive = deadline == null || deadline.isAfter(DateTime.now());
      return matchesCat && matchesSearch && isActive;
    }).toList()..sort((a, b) => (a['deadline'] ?? '').compareTo(b['deadline'] ?? ''));
  }

  int _daysUntil(String? dateStr) {
    if (dateStr == null) return 999;
    final date = DateTime.tryParse(dateStr);
    if (date == null) return 999;
    return date.difference(DateTime.now()).inDays;
  }

  Color _urgencyColor(int days) {
    if (days <= 7) return Colors.redAccent;
    if (days <= 14) return Colors.orangeAccent;
    if (days <= 30) return Colors.amberAccent;
    return Colors.greenAccent;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white70), onPressed: () => Navigator.pop(context)),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(colors: [Colors.amber, Colors.orangeAccent]).createShader(bounds),
          child: Text('Opportunities', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search opportunities...', hintStyle: TextStyle(color: Colors.white30),
                prefixIcon: const Icon(Icons.search, color: Colors.amber),
                filled: true, fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
          ),
          // Category chips
          SizedBox(
            height: 42,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (_, i) {
                final cat = categories[i];
                final selected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(cat, style: TextStyle(color: selected ? Colors.black : Colors.white70, fontSize: 11)),
                    selected: selected, selectedColor: Colors.amber,
                    backgroundColor: Colors.white.withOpacity(0.08),
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  ),
                );
              },
            ),
          ),
          // List
          Expanded(
            child: filtered.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.emoji_events_outlined, size: 64, color: Colors.white24),
                  const SizedBox(height: 16),
                  Text('No opportunities found', style: GoogleFonts.poppins(color: Colors.white54)),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _buildOpportunityCard(filtered[i]),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpportunityCard(Map<String, dynamic> opp) {
    final days = _daysUntil(opp['deadline']);
    final color = _urgencyColor(days);
    final saved = _savedIds.contains(opp['id']);

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: InkWell(
        onTap: () async {
          final url = opp['url'];
          if (url != null) {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
              child: Text(opp['category'] ?? '', style: GoogleFonts.poppins(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.w600)),
            ),
            const Spacer(),
            InkWell(
              onTap: () => _toggleSaved(opp['id'] ?? ''),
              child: Icon(saved ? Icons.bookmark : Icons.bookmark_border, color: saved ? Colors.amber : Colors.white38, size: 20),
            ),
          ]),
          const SizedBox(height: 8),
          Text(opp['title'] ?? '', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 4),
          Text(opp['description'] ?? '', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12), maxLines: 2),
          const SizedBox(height: 8),
          Row(children: [
            Icon(Icons.business, color: Colors.white38, size: 14),
            const SizedBox(width: 4),
            Text(opp['organization'] ?? '', style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
              child: Text(days <= 0 ? 'Ending soon' : '$days days left',
                style: GoogleFonts.poppins(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
            ),
          ]),
        ]),
      ),
    );
  }
}
