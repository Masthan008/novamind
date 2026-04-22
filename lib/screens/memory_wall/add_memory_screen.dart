import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/student_auth_service.dart';
import '../../services/imagekit_service.dart';
import 'dart:io';

class AddMemoryScreen extends StatefulWidget {
  final int collegeId;
  const AddMemoryScreen({super.key, required this.collegeId});
  @override
  State<AddMemoryScreen> createState() => _AddMemoryScreenState();
}

class _AddMemoryScreenState extends State<AddMemoryScreen> {
  final _captionC = TextEditingController();
  String _eventTag = 'Fest';
  File? _imageFile;
  bool _posting = false;

  @override
  void dispose() { _captionC.dispose(); super.dispose(); }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 85);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _post() async {
    if (_captionC.text.isEmpty) return;
    setState(() => _posting = true);

    String? imageUrl;
    if (_imageFile != null) {
      imageUrl = await ImagekitService.uploadImage(imageFile: _imageFile!, fileName: 'memory_${DateTime.now().millisecondsSinceEpoch}', folder: '/zerno/memories');
    }

    try {
      final student = StudentAuthService.currentStudent;
      await Supabase.instance.client.from('memories').insert({
        'student_id': student?.id.toString(),
        'student_name': student?.name ?? 'Anonymous',
        'college_id': widget.collegeId,
        'image_url': imageUrl,
        'caption': _captionC.text.trim(),
        'event_tag': _eventTag,
        'academic_year': '2025-26',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📸 Memory posted!'), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
    setState(() => _posting = false);
  }

  @override
  Widget build(BuildContext context) {
    final tags = ['Fest', 'Sports', 'Cultural', 'Farewell', 'Fresher', 'Workshop', 'Trip', 'Other'];
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        title: Text('Add Memory', style: GoogleFonts.orbitron(color: Colors.pinkAccent, fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white70), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Image Picker
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 200, width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.pinkAccent.withOpacity(0.3)),
              ),
              child: _imageFile != null
                  ? ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.file(_imageFile!, fit: BoxFit.cover))
                  : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.add_a_photo, color: Colors.pinkAccent.withOpacity(0.5), size: 40),
                      const SizedBox(height: 8),
                      Text('Tap to add photo', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
                    ]),
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 20),

          // Caption
          TextField(
            controller: _captionC, maxLines: 3,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Write a caption...', hintStyle: GoogleFonts.poppins(color: Colors.grey),
              filled: true, fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 20),

          // Event Tag Selector
          Text('Event Tag', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: tags.map((t) => ChoiceChip(
              label: Text(t, style: GoogleFonts.poppins(fontSize: 12)),
              selected: _eventTag == t,
              selectedColor: Colors.pinkAccent,
              backgroundColor: Colors.white.withOpacity(0.08),
              labelStyle: TextStyle(color: _eventTag == t ? Colors.white : Colors.grey),
              onSelected: (_) => setState(() => _eventTag = t),
            )).toList(),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 28),

          // Post Button
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            icon: _posting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.send, size: 18),
            label: Text(_posting ? 'Posting...' : 'Post Memory', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            onPressed: _posting ? null : _post,
          )).animate().fadeIn(delay: 300.ms),
        ]),
      ),
    );
  }
}
