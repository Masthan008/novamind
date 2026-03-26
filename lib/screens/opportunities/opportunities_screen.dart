import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/glass_container.dart';

final supabase = Supabase.instance.client;

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

  // Fetch from Supabase, but keep samples as fallback if needed
  List<Map<String, dynamic>> _opportunities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSaved();
    _fetchOpportunities();
  }

  Future<void> _fetchOpportunities() async {
    try {
      final response = await supabase
          .from('opportunities')
          .select()
          .eq('is_active', true)
          .order('deadline', ascending: true);
          
      if (mounted) {
        setState(() {
          // Store response and also convert Supabase timestamps to expected format
          _opportunities = List<Map<String, dynamic>>.from(response).map((opp) {
            // Check mapping compatibility, sometimes date fields might be named differently
            return opp; 
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('⚠️ Error fetching opportunities from Supabase: $e');
      if (mounted) {
        setState(() {
          // If fetch fails, show empty state or fallback 
          // (In a real app, maybe show an error or fallback to local cache. 
          // Here, we'll just leave it empty and not crash)
          _opportunities = [];
          _isLoading = false;
        });
      }
    }
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
    return _opportunities.where((o) {
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
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.amber))
        : Column(
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
