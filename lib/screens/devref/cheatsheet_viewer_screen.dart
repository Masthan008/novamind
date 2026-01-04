import 'dart:convert'; // <--- Add this line
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/cheatsheet.dart';
import '../../services/cheatsheet_loader_service.dart';

class CheatsheetViewerScreen extends StatefulWidget {
  final CheatSheet cheatsheet;

  const CheatsheetViewerScreen({super.key, required this.cheatsheet});

  @override
  State<CheatsheetViewerScreen> createState() => _CheatsheetViewerScreenState();
}

class _CheatsheetViewerScreenState extends State<CheatsheetViewerScreen> {
  bool _isFavorite = false;
  late Future<Map<String, String>> _snippetsFuture;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.cheatsheet.isFavorite;
    
    // 🛡️ SAFETY CHECK: Only save if the object is actually in the database
    // For JSON-loaded cheatsheets, we'll increment view count without saving to Hive
    try {
      if (widget.cheatsheet.isInBox) {
        widget.cheatsheet.incrementViewCount();
      } else {
        // For JSON-loaded cheatsheets, just update the view count locally
        widget.cheatsheet.viewCount++;
        widget.cheatsheet.lastViewed = DateTime.now();
      }
    } catch (e) {
      print('Warning: Could not update view count: $e');
    }
    
    _snippetsFuture = _loadSnippets();
  }

  Future<Map<String, String>> _loadSnippets() async {
    try {
      // 1. CLEAN THE ID
      // If the ID is "dart", we want "assets/data/cheatsheets/programming/dart.json"
      String cleanId = widget.cheatsheet.id;
      String category = widget.cheatsheet.category;
      
      // 2. CONSTRUCT EXACT PATH
      // We manually build the path so no service can mess it up
      final String path = 'assets/data/cheatsheets/$category/$cleanId.json';
      
      print('🔍 Loading CheatSheet from: $path'); // Debug Print

      // 3. LOAD DIRECTLY
      final String jsonString = await DefaultAssetBundle.of(context).loadString(path);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      // 4. PARSE SNIPPETS
      final Map<String, String> snippets = {};
      if (jsonData.containsKey('snippets')) {
        final snippetsData = jsonData['snippets'] as Map<String, dynamic>;
        snippetsData.forEach((key, value) {
          snippets[key] = value.toString();
        });
      }
      return snippets;

    } catch (e) {
      print('❌ Error loading $e');
      // This throws the error to the UI so you see the "Crash Prevented" screen
      throw "File not found: assets/data/cheatsheets/${widget.cheatsheet.category}/${widget.cheatsheet.id}.json\n\nCheck that the file exists in the 'assets/data/cheatsheets/' folder!";
    }
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
            Text(widget.cheatsheet.icon, style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.cheatsheet.title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.amber),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.star : Icons.star_border,
              color: _isFavorite ? Colors.amber : Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
                
                // 🛠️ FIX: Update the Hive Object directly!
                widget.cheatsheet.isFavorite = _isFavorite;
                
                // Save to database
                try {
                  if (widget.cheatsheet.isInBox) {
                    widget.cheatsheet.save(); // <--- THIS SAVES IT PERMANENTLY
                  }
                } catch (e) {
                  print('Warning: Could not save favorite status: $e');
                }
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isFavorite ? '⭐ Added to favorites!' : 'Removed from favorites',
                  ),
                  backgroundColor: Colors.deepPurple.shade800,
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(milliseconds: 500),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.cheatsheet.url));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.greenAccent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Link copied: ${widget.cheatsheet.url}'),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.deepPurple.shade800,
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 3),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _snippetsFuture,
        builder: (context, snapshot) {
          // 🛑 CASE 1: LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.amber),
                  const SizedBox(height: 16),
                  Text(
                    'Loading snippets...',
                    style: GoogleFonts.poppins(color: Colors.white70),
                  ),
                ],
              ),
            );
          }

          // 🛑 CASE 2: ERROR
          if (snapshot.hasError) {
            return _buildErrorScreen(snapshot.error.toString());
          }

          // ✅ CASE 3: SUCCESS
          final snippets = snapshot.data!;
          
          if (snippets.isEmpty) {
            return _buildEmptyState();
          }

          return _buildSnippetsView(snippets);
        },
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.deepPurple.shade900,
            Colors.black,
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, size: 80, color: Colors.redAccent),
              const SizedBox(height: 24),
              Text(
                'CRASH PREVENTED 🛡️',
                style: GoogleFonts.orbitron(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Could not load cheatsheet',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'File: ${widget.cheatsheet.category}/${widget.cheatsheet.id}.json',
                style: TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Error Details:',
                      style: GoogleFonts.poppins(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error,
                      style: GoogleFonts.firaCode(
                        color: Colors.white60,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Possible causes:',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• JSON file does not exist in assets/data/cheatsheets/\n'
                '• File not registered in pubspec.yaml\n'
                '• Invalid JSON format\n'
                '• Missing "snippets" field in JSON',
                style: TextStyle(color: Colors.white60, fontSize: 11),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _snippetsFuture = _loadSnippets();
                      });
                    },
                    icon: Icon(Icons.refresh),
                    label: Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back),
                    label: Text('Go Back'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.code_off, size: 80, color: Colors.grey),
          const SizedBox(height: 24),
          Text(
            'No Snippets Available',
            style: GoogleFonts.orbitron(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This cheatsheet has no code snippets yet',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSnippetsView(Map<String, String> snippets) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.deepPurple.shade900,
            Colors.deepPurple.shade800,
            Colors.black,
          ],
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: snippets.length,
        itemBuilder: (context, index) {
          final entry = snippets.entries.elementAt(index);
          return _buildSnippetCard(entry.key, entry.value, index);
        },
      ),
    );
  }

  Widget _buildSnippetCard(String title, String code, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade800.withOpacity(0.5),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.code, color: Colors.amber, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.copy, color: Colors.amber, size: 20),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.greenAccent),
                            const SizedBox(width: 8),
                            Text('Copied to clipboard!'),
                          ],
                        ),
                        backgroundColor: Colors.deepPurple.shade800,
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Code
          Container(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              code,
              style: GoogleFonts.firaCode(
                color: Colors.greenAccent.shade100,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: -0.1);
  }
}
