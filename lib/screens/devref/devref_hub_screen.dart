import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/cheatsheet_loader_service.dart';
import '../../models/cheatsheet.dart';
import 'cheatsheet_viewer_screen.dart';

class DevRefHubScreen extends StatefulWidget {
  const DevRefHubScreen({super.key});

  @override
  State<DevRefHubScreen> createState() => _DevRefHubScreenState();
}

class _DevRefHubScreenState extends State<DevRefHubScreen> {
  String _searchQuery = '';
  String? _selectedCategory;
  List<Map<String, dynamic>> _allCheatsheets = [];
  List<Map<String, dynamic>> _filteredSheets = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  int _totalCount = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load index and all cheatsheets
      final categories = await CheatsheetLoaderService.getCategories();
      final allSheets = await CheatsheetLoaderService.getAllCheatsheets();
      final count = await CheatsheetLoaderService.getTotalCount();

      setState(() {
        _categories = categories;
        _allCheatsheets = allSheets;
        _filteredSheets = allSheets;
        _totalCount = count;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e, stackTrace) {
      print('Error loading cheatsheets: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _filterCheatsheets(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredSheets = _selectedCategory != null
            ? _allCheatsheets.where((s) => s['category'] == _selectedCategory).toList()
            : _allCheatsheets;
      } else {
        _filteredSheets = _allCheatsheets.where((sheet) {
          final title = (sheet['title'] as String).toLowerCase();
          return title.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _filterByCategory(String? category) {
    setState(() {
      _selectedCategory = category;
      if (category == null) {
        _filteredSheets = _searchQuery.isEmpty
            ? _allCheatsheets
            : _allCheatsheets.where((s) => (s['title'] as String).toLowerCase().contains(_searchQuery.toLowerCase())).toList();
      } else {
        _filteredSheets = _allCheatsheets.where((s) => s['category'] == category).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade900,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.library_books, color: Colors.amber),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DevRef',
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  '$_totalCount+ References',
                  style: TextStyle(
                    color: Colors.amber.shade200,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.amber),
      ),
      body: _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 80, color: Colors.red),
                    const SizedBox(height: 24),
                    Text(
                      'Error Loading DevRef',
                      style: GoogleFonts.orbitron(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _errorMessage = null;
                        });
                        _loadData();
                      },
                      icon: Icon(Icons.refresh),
                      label: Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : _isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.amber),
                      const SizedBox(height: 16),
                      Text(
                        'Loading cheatsheets...',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                )
              : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Search Bar
                _buildSearchBar(),
                const SizedBox(height: 20),

                // Quick Access
                _buildQuickAccess(),
                const SizedBox(height: 25),

                // Categories
                _buildCategories(),
                const SizedBox(height: 25),

                // All Cheatsheets
                _buildAllCheatsheets(),
              ],
            ),
    );
  }

  // 🖼️ SMART ICON RENDERER
  // If it's a file path, show Image. If it's emoji, show Text.
  Widget _buildIcon(String iconData, {double size = 24}) {
    if (iconData.endsWith('.png') || iconData.endsWith('.jpg') || iconData.endsWith('.jpeg')) {
      return Image.asset(
        iconData,
        width: size,
        height: size,
        errorBuilder: (c, o, s) => Icon(Icons.broken_image, color: Colors.grey, size: size),
      );
    } else {
      return Text(iconData, style: TextStyle(fontSize: size));
    }
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.shade800.withOpacity(0.5),
            Colors.purple.shade900.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: '🔍 Search references...',
          hintStyle: TextStyle(color: Colors.white54),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.amber),
                  onPressed: () {
                    _filterCheatsheets('');
                  },
                )
              : null,
        ),
        onChanged: _filterCheatsheets,
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildQuickAccess() {
    final quickAccess = _allCheatsheets.take(8).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📌 Quick Access',
          style: GoogleFonts.poppins(
            color: Colors.amber,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: quickAccess.map((sheet) {
            return _buildQuickAccessChip(sheet);
          }).toList(),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms, duration: 600.ms);
  }

  Widget _buildQuickAccessChip(Map<String, dynamic> sheet) {
    return InkWell(
      onTap: () => _openCheatsheet(sheet),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.shade700,
              Colors.purple.shade800,
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.amber.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(sheet['icon'] as String, size: 18),
            const SizedBox(width: 8),
            Text(
              sheet['title'] as String,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📚 Browse by Category',
          style: GoogleFonts.poppins(
            color: Colors.amber,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _categories.map((category) {
            final categoryId = category['id'] as String;
            final categoryName = category['name'] as String;
            final isSelected = _selectedCategory == categoryId;
            return FilterChip(
              label: Text(categoryName),
              selected: isSelected,
              onSelected: (selected) {
                _filterByCategory(selected ? categoryId : null);
              },
              backgroundColor: Colors.grey.shade900,
              selectedColor: Colors.deepPurple.shade700,
              labelStyle: TextStyle(
                color: isSelected ? Colors.amber : Colors.white70,
              ),
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms, duration: 600.ms);
  }

  Widget _buildAllCheatsheets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📖 All References (${_filteredSheets.length})',
          style: GoogleFonts.poppins(
            color: Colors.amber,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ..._filteredSheets.map((sheet) => _buildCheatsheetCard(sheet)).toList(),
      ],
    ).animate().fadeIn(delay: 600.ms, duration: 600.ms);
  }

  Widget _buildCheatsheetCard(Map<String, dynamic> sheet) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade900,
            Colors.grey.shade800,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.deepPurple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _openCheatsheet(sheet),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _buildIcon(sheet['icon'] as String, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sheet['title'] as String,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTag(sheet['category'] as String, Colors.deepPurple),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.amber, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _openCheatsheet(Map<String, dynamic> sheetData) {
    // Create CheatSheet object from JSON data
    final sheet = CheatSheet(
      id: sheetData['id'] as String,
      title: sheetData['title'] as String,
      icon: sheetData['icon'] as String,
      category: sheetData['category'] as String,
      url: sheetData['url'] as String,
      description: 'Quick reference for ${sheetData['title']}',
      difficulty: 'Intermediate',
      tags: const [], // Empty tags list for JSON-loaded cheatsheets
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheatsheetViewerScreen(cheatsheet: sheet),
      ),
    );
  }
}
