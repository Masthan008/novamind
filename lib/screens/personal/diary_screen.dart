import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:intl/intl.dart';
import '../../services/supabase_data_service.dart';
import '../../services/student_auth_service.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final _dataService = SupabaseDataService();
  List<Map<String, dynamic>> _entries = [];
  bool _isLoading = true;
  String _filterMood = 'All';
  
  // Mood data with icons instead of emojis
  final List<Map<String, dynamic>> _moods = [
    {'name': 'All', 'icon': Icons.list_alt, 'color': Colors.grey},
    {'name': 'Happy', 'icon': Icons.sentiment_very_satisfied, 'color': Colors.greenAccent},
    {'name': 'Sad', 'icon': Icons.sentiment_dissatisfied, 'color': Colors.blueAccent},
    {'name': 'Stressed', 'icon': Icons.psychology_alt, 'color': Colors.orangeAccent},
    {'name': 'Excited', 'icon': Icons.celebration, 'color': Colors.pinkAccent},
    {'name': 'Tired', 'icon': Icons.bedtime, 'color': Colors.purpleAccent},
    {'name': 'Grateful', 'icon': Icons.favorite, 'color': Colors.tealAccent},
    {'name': 'Anxious', 'icon': Icons.warning_amber, 'color': Colors.redAccent},
  ];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);
    final entries = await _dataService.getMyDiaries();
    if (mounted) {
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    }
  }

  /// Opens the note editor - for creating new or editing existing entries
  void _openNoteEditor({Map<String, dynamic>? existingEntry}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _NoteEditorPage(
          existingEntry: existingEntry,
          moods: _moods,
          onSave: (bool saved) {
            if (saved) {
              _loadEntries();
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a1a),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.book, color: Colors.purpleAccent, size: 24),
            const SizedBox(width: 8),
            Text(
              'My Notes',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: _loadEntries,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNoteEditor(),
        backgroundColor: Colors.purpleAccent,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ).animate().scale(delay: 300.ms),
      body: Stack(
        children: [
          // Background decorations
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.purpleAccent.withOpacity(0.2), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.pinkAccent.withOpacity(0.15), Colors.transparent],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Mood filter chips
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _moods.length,
                    itemBuilder: (context, index) {
                      final mood = _moods[index];
                      final isSelected = _filterMood == mood['name'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () => setState(() => _filterMood = mood['name'] as String),
                          borderRadius: BorderRadius.circular(25),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? (mood['color'] as Color).withOpacity(0.3) 
                                  : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: isSelected ? mood['color'] as Color : Colors.white10,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(mood['icon'] as IconData, color: mood['color'] as Color, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  mood['name'] as String,
                                  style: GoogleFonts.poppins(
                                    color: isSelected ? mood['color'] as Color : Colors.white54,
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
                const SizedBox(height: 16),

                // Entries grid/list
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.purpleAccent))
                      : _entries.isEmpty
                          ? _buildEmptyState()
                          : _buildEntriesList(),
                ),
              ],
            ),
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
          Icon(Icons.note_alt_outlined, size: 80, color: Colors.white.withOpacity(0.15)),
          const SizedBox(height: 24),
          Text(
            'No notes yet',
            style: GoogleFonts.poppins(color: Colors.white38, fontSize: 20, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to create your first note',
            style: GoogleFonts.poppins(color: Colors.white24),
          ),
        ],
      ).animate().fadeIn().scale(),
    );
  }

  Widget _buildEntriesList() {
    final filtered = _filterMood == 'All' 
        ? _entries 
        : _entries.where((e) => e['mood'] == _filterMood).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'No notes with $_filterMood mood',
          style: GoogleFonts.poppins(color: Colors.white38),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final entry = filtered[index];
        final date = DateTime.parse(entry['created_at']);
        final mood = _moods.firstWhere((m) => m['name'] == entry['mood'], orElse: () => _moods[1]);

        return Dismissible(
          key: Key(entry['id']),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.delete, color: Colors.redAccent, size: 28),
          ),
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: const Color(0xFF1a1a2e),
                title: Text('Delete Note?', style: GoogleFonts.poppins(color: Colors.white)),
                content: Text('This action cannot be undone.', style: GoogleFonts.poppins(color: Colors.white70)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.white54)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text('Delete', style: GoogleFonts.poppins(color: Colors.redAccent)),
                  ),
                ],
              ),
            );
          },
          onDismissed: (direction) async {
            await _dataService.deleteDiaryEntry(entry['id']);
            _loadEntries();
          },
          child: InkWell(
            onTap: () => _openNoteEditor(existingEntry: entry),
            borderRadius: BorderRadius.circular(20),
            child: GlassmorphicContainer(
              width: double.infinity,
              height: 140,
              borderRadius: 20,
              blur: 20,
              alignment: Alignment.center,
              border: 1,
              linearGradient: LinearGradient(
                colors: [
                  (mood['color'] as Color).withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderGradient: LinearGradient(
                colors: [
                  (mood['color'] as Color).withOpacity(0.5),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (mood['color'] as Color).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(mood['icon'] as IconData, color: mood['color'] as Color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry['title'] ?? 'Untitled',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                DateFormat('MMM d, yyyy • h:mm a').format(date),
                                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.edit_note, color: Colors.white24, size: 20),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Text(
                        entry['content'] ?? '',
                        style: GoogleFonts.poppins(
                          color: Colors.white60,
                          fontSize: 13,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: index * 80)).slideY(begin: 0.05),
        );
      },
    );
  }
}

/// Full-screen note editor page (like a notes app)
class _NoteEditorPage extends StatefulWidget {
  final Map<String, dynamic>? existingEntry;
  final List<Map<String, dynamic>> moods;
  final Function(bool saved) onSave;

  const _NoteEditorPage({
    this.existingEntry,
    required this.moods,
    required this.onSave,
  });

  @override
  State<_NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<_NoteEditorPage> {
  final _dataService = SupabaseDataService();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late String _selectedMood;
  bool _isSaving = false;
  bool _hasChanges = false;

  bool get _isEditing => widget.existingEntry != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingEntry?['title'] ?? '');
    _contentController = TextEditingController(text: widget.existingEntry?['content'] ?? '');
    _selectedMood = widget.existingEntry?['mood'] ?? 'Happy';
    
    // Track changes
    _titleController.addListener(_markChanged);
    _contentController.addListener(_markChanged);
  }

  void _markChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please write something first', style: GoogleFonts.poppins()),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    bool success;
    final title = _titleController.text.trim().isEmpty ? 'Untitled' : _titleController.text.trim();
    final content = _contentController.text.trim();

    if (_isEditing) {
      // Update existing entry
      success = await _dataService.updateDiaryEntry(
        widget.existingEntry!['id'],
        title: title,
        content: content,
        mood: _selectedMood,
      );
    } else {
      // Create new entry
      success = await _dataService.saveDiaryEntry(title, content, _selectedMood);
    }

    setState(() => _isSaving = false);

    if (success && mounted) {
      widget.onSave(true);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Note updated!' : 'Note saved!', style: GoogleFonts.poppins()),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save note', style: GoogleFonts.poppins()),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: Text('Discard changes?', style: GoogleFonts.poppins(color: Colors.white)),
        content: Text('You have unsaved changes.', style: GoogleFonts.poppins(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Keep Editing', style: GoogleFonts.poppins(color: Colors.purpleAccent)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Discard', style: GoogleFonts.poppins(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final moodData = widget.moods.firstWhere(
      (m) => m['name'] == _selectedMood,
      orElse: () => widget.moods[1],
    );

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFF0a0a1a),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () async {
              if (await _onWillPop()) Navigator.pop(context);
            },
          ),
          title: Text(
            _isEditing ? 'Edit Note' : 'New Note',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          actions: [
            _isSaving
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.purpleAccent, strokeWidth: 2),
                    ),
                  )
                : TextButton(
                    onPressed: _saveNote,
                    child: Text(
                      'Save',
                      style: GoogleFonts.poppins(color: Colors.purpleAccent, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
          ],
        ),
        body: Column(
          children: [
            // Date and content area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date display
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                      style: GoogleFonts.poppins(color: Colors.white54, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    
                    // Title field
                    TextField(
                      controller: _titleController,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Title',
                        hintStyle: GoogleFonts.poppins(color: Colors.white30, fontSize: 24, fontWeight: FontWeight.bold),
                        border: InputBorder.none,
                      ),
                    ),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 12),
                    
                    // Content field
                    TextField(
                      controller: _contentController,
                      style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9), fontSize: 16, height: 1.8),
                      maxLines: null,
                      minLines: 15,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: 'Start writing...',
                        hintStyle: GoogleFonts.poppins(color: Colors.white30, fontSize: 16),
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Mood selector at bottom
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1a1a2e),
                border: Border(top: BorderSide(color: Colors.white10)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How do you feel?',
                    style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: widget.moods.where((m) => m['name'] != 'All').map((mood) {
                        final isSelected = _selectedMood == mood['name'];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedMood = mood['name'] as String;
                                _hasChanges = true;
                              });
                            },
                            borderRadius: BorderRadius.circular(25),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (mood['color'] as Color).withOpacity(0.3)
                                    : Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: isSelected ? mood['color'] as Color : Colors.white10,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(mood['icon'] as IconData, color: mood['color'] as Color, size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    mood['name'] as String,
                                    style: GoogleFonts.poppins(
                                      color: isSelected ? mood['color'] as Color : Colors.white54,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
