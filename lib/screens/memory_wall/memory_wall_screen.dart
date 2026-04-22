import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/student_auth_service.dart';
import '../../services/college_service.dart';
import 'add_memory_screen.dart';

class MemoryWallScreen extends StatefulWidget {
  const MemoryWallScreen({super.key});
  @override
  State<MemoryWallScreen> createState() => _MemoryWallScreenState();
}

class _MemoryWallScreenState extends State<MemoryWallScreen> {
  List<Map<String, dynamic>> _memories = [];
  bool _loading = true;
  String _filterTag = 'All';
  Map<String, dynamic>? _college;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      _college = await CollegeService.getStudentCollege();
      if (_college != null) {
        final data = await Supabase.instance.client.from('memories').select()
            .eq('college_id', _college!['id']).order('created_at', ascending: false);
        _memories = List<Map<String, dynamic>>.from(data);
      }
    } catch (e) {
      _memories = _fallbackMemories;
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        title: Text('Memory Wall', style: GoogleFonts.orbitron(color: Colors.pinkAccent, fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white70), onPressed: () => Navigator.pop(context)),
      ),
      floatingActionButton: _college != null ? FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        child: const Icon(Icons.add_a_photo, color: Colors.white),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => AddMemoryScreen(collegeId: _college!['id'] as int)));
          _load();
        },
      ) : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.pinkAccent))
          : _college == null
              ? _buildNoCollege()
              : _buildWall(),
    );
  }

  Widget _buildNoCollege() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.photo_library, color: Colors.pinkAccent.withOpacity(0.3), size: 80),
      const SizedBox(height: 16),
      Text('Join a college first', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
    ]));
  }

  Widget _buildWall() {
    final tags = ['All', 'Fest', 'Sports', 'Cultural', 'Farewell', 'Fresher', 'Workshop', 'Trip'];
    final filtered = _filterTag == 'All' ? _memories : _memories.where((m) => m['event_tag'] == _filterTag).toList();

    return Column(children: [
      // Tag Filters
      SizedBox(
        height: 42,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: tags.length,
          itemBuilder: (_, i) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(tags[i], style: GoogleFonts.poppins(fontSize: 12)),
              selected: _filterTag == tags[i],
              selectedColor: Colors.pinkAccent,
              backgroundColor: Colors.white.withOpacity(0.08),
              labelStyle: TextStyle(color: _filterTag == tags[i] ? Colors.white : Colors.grey),
              onSelected: (_) => setState(() => _filterTag = tags[i]),
            ),
          ),
        ),
      ).animate().fadeIn(),
      const SizedBox(height: 12),

      // Memories Grid
      Expanded(
        child: filtered.isEmpty
            ? Center(child: Text('No memories yet — be the first! 📸', style: GoogleFonts.poppins(color: Colors.grey)))
            : RefreshIndicator(
                onRefresh: _load,
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.75,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _memoryCard(filtered[i], i),
                ),
              ),
      ),
    ]);
  }

  Widget _memoryCard(Map<String, dynamic> m, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.pinkAccent.withOpacity(0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(children: [
          // Image
          Positioned.fill(
            child: m['image_url'] != null
                ? CachedNetworkImage(imageUrl: m['image_url'], fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: Colors.white.withOpacity(0.05)),
                    errorWidget: (_, __, ___) => Container(color: Colors.white.withOpacity(0.05), child: const Icon(Icons.image, color: Colors.grey)))
                : Container(color: Colors.white.withOpacity(0.05), child: Icon(Icons.photo, color: Colors.pinkAccent.withOpacity(0.3), size: 40)),
          ),
          // Gradient overlay
          Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.8)]),
          ))),
          // Caption & likes
          Positioned(left: 8, right: 8, bottom: 8, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (m['event_tag'] != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.pinkAccent.withOpacity(0.7), borderRadius: BorderRadius.circular(6)),
                child: Text(m['event_tag'], style: GoogleFonts.poppins(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            const SizedBox(height: 4),
            Text(m['caption'] ?? '', style: GoogleFonts.poppins(color: Colors.white, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
            Row(children: [
              Icon(Icons.favorite, color: Colors.pinkAccent, size: 14),
              const SizedBox(width: 4),
              Text('${m['likes'] ?? 0}', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 10)),
              const Spacer(),
              Text(m['student_name'] ?? '', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 9)),
            ]),
          ])),
        ]),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 100 + index * 50)).scale(begin: const Offset(0.95, 0.95));
  }

  static final _fallbackMemories = [
    {'caption': 'Annual Tech Fest 2026 🎉', 'event_tag': 'Fest', 'student_name': 'Rahul', 'likes': 42, 'image_url': null},
    {'caption': 'Cricket Tournament Finals ⚡', 'event_tag': 'Sports', 'student_name': 'Priya', 'likes': 35, 'image_url': null},
    {'caption': 'Cultural Night Performance', 'event_tag': 'Cultural', 'student_name': 'Ankit', 'likes': 28, 'image_url': null},
  ];
}
