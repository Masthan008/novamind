import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/tools_directory_data.dart';
import '../../widgets/glass_container.dart';

/// Free Tools Directory — Searchable, filterable directory with My Toolkit
class ToolsDirectoryScreen extends StatefulWidget {
  const ToolsDirectoryScreen({super.key});

  @override
  State<ToolsDirectoryScreen> createState() => _ToolsDirectoryScreenState();
}

class _ToolsDirectoryScreenState extends State<ToolsDirectoryScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late Box _savedBox;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  Set<String> _savedToolNames = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSaved();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadSaved() {
    _savedBox = Hive.box('saved_tools');
    final saved = _savedBox.get('saved_names');
    if (saved != null) {
      _savedToolNames = Set<String>.from(saved as List);
    }
  }

  void _toggleSaved(String toolName) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_savedToolNames.contains(toolName)) {
        _savedToolNames.remove(toolName);
      } else {
        _savedToolNames.add(toolName);
      }
      _savedBox.put('saved_names', _savedToolNames.toList());
    });
  }

  List<ToolItem> get _filteredTools {
    return ToolsDirectoryData.tools.where((tool) {
      final matchesCategory = _selectedCategory == 'All' || tool.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          tool.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tool.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tool.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<ToolItem> get _savedTools {
    return ToolsDirectoryData.tools.where((t) => _savedToolNames.contains(t.name)).toList();
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white70), onPressed: () => Navigator.pop(context)),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(colors: [Colors.tealAccent, Colors.cyanAccent]).createShader(bounds),
          child: Text('Free Tools', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.cyanAccent,
          labelColor: Colors.cyanAccent,
          unselectedLabelColor: Colors.white38,
          tabs: [
            Tab(text: 'Directory (${ToolsDirectoryData.tools.length})', icon: const Icon(Icons.apps, size: 18)),
            Tab(text: 'My Toolkit (${_savedToolNames.length})', icon: const Icon(Icons.bookmark, size: 18)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDirectoryTab(),
          _buildToolkitTab(),
        ],
      ),
    );
  }

  Widget _buildDirectoryTab() {
    final filtered = _filteredTools;
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Search tools...', hintStyle: TextStyle(color: Colors.white30),
              prefixIcon: const Icon(Icons.search, color: Colors.cyanAccent),
              filled: true, fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),

        // Category chips
        SizedBox(
          height: 42,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: ToolsDirectoryData.categories.length,
            itemBuilder: (context, index) {
              final cat = ToolsDirectoryData.categories[index];
              final selected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  label: Text(cat, style: TextStyle(color: selected ? Colors.black : Colors.white70, fontSize: 11)),
                  selected: selected,
                  selectedColor: Colors.cyanAccent,
                  backgroundColor: Colors.white.withOpacity(0.08),
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                ),
              );
            },
          ),
        ),

        // Results count
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('${filtered.length} tools found', style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12)),
          ),
        ),

        // Tools grid
        Expanded(
          child: filtered.isEmpty
            ? Center(child: Text('No matching tools', style: GoogleFonts.poppins(color: Colors.white54)))
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.85),
                itemCount: filtered.length,
                itemBuilder: (context, index) => _buildToolCard(filtered[index]),
              ),
        ),
      ],
    );
  }

  Widget _buildToolkitTab() {
    final saved = _savedTools;
    if (saved.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.bookmark_border, size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          Text('Your toolkit is empty', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 16)),
          Text('Save tools from Directory', style: GoogleFonts.poppins(color: Colors.white38, fontSize: 13)),
        ]),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: saved.length,
      itemBuilder: (context, index) => _buildToolListItem(saved[index]),
    );
  }

  Widget _buildToolCard(ToolItem tool) {
    final saved = _savedToolNames.contains(tool.name);
    return InkWell(
      onTap: () => _openUrl(tool.url),
      borderRadius: BorderRadius.circular(16),
      child: GlassContainer(
        padding: const EdgeInsets.all(14),
        borderRadius: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(tool.icon, style: const TextStyle(fontSize: 24)),
                const Spacer(),
                InkWell(
                  onTap: () => _toggleSaved(tool.name),
                  child: Icon(saved ? Icons.bookmark : Icons.bookmark_border,
                    color: saved ? Colors.cyanAccent : Colors.white38, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(tool.name, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(tool.description, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11, height: 1.3),
              maxLines: 2, overflow: TextOverflow.ellipsis),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: Colors.cyanAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
              child: Text(tool.category, style: GoogleFonts.poppins(color: Colors.cyanAccent, fontSize: 9, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolListItem(ToolItem tool) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      borderRadius: 14,
      child: InkWell(
        onTap: () => _openUrl(tool.url),
        child: Row(
          children: [
            Text(tool.icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tool.name, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(tool.description, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.bookmark_remove, color: Colors.redAccent, size: 20),
              onPressed: () => _toggleSaved(tool.name),
            ),
          ],
        ),
      ),
    );
  }
}
