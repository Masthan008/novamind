import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/student_auth_service.dart';
import '../../services/imagekit_service.dart';
import 'dart:io';

class CreateListingScreen extends StatefulWidget {
  final int collegeId;
  const CreateListingScreen({super.key, required this.collegeId});
  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _titleC = TextEditingController();
  final _descC = TextEditingController();
  final _priceC = TextEditingController();
  String _category = 'Books';
  String _condition = 'Good';
  List<File> _images = [];
  bool _posting = false;

  @override
  void dispose() { _titleC.dispose(); _descC.dispose(); _priceC.dispose(); super.dispose(); }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(maxWidth: 1000, imageQuality: 80);
    if (picked.isNotEmpty) setState(() => _images = picked.take(3).map((p) => File(p.path)).toList());
  }

  Future<void> _post() async {
    if (_titleC.text.isEmpty || _priceC.text.isEmpty) return;
    setState(() => _posting = true);

    final imageUrls = <String>[];
    for (final img in _images) {
      final url = await ImagekitService.uploadImage(imageFile: img, fileName: 'listing_${DateTime.now().millisecondsSinceEpoch}', folder: '/zerno/marketplace');
      if (url != null) imageUrls.add(url);
    }

    try {
      final student = StudentAuthService.currentStudent;
      await Supabase.instance.client.from('marketplace_listings').insert({
        'student_id': student?.id.toString(), 'student_name': student?.name,
        'title': _titleC.text, 'description': _descC.text,
        'price': int.tryParse(_priceC.text) ?? 0,
        'category': _category, 'condition': _condition,
        'images': imageUrls, 'college_id': widget.collegeId,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🛍️ Listing posted!'), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
    setState(() => _posting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0,
        title: Text('Create Listing', style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white70), onPressed: () => Navigator.pop(context))),
      body: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Photos
        GestureDetector(
          onTap: _pickImages,
          child: Container(height: 120, width: double.infinity,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.cyanAccent.withOpacity(0.3))),
            child: _images.isEmpty
                ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_photo_alternate, color: Colors.cyanAccent.withOpacity(0.5), size: 36), Text('Add photos (max 3)', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12))])
                : Row(mainAxisAlignment: MainAxisAlignment.center, children: _images.map((f) => Padding(padding: const EdgeInsets.all(4), child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(f, width: 90, height: 90, fit: BoxFit.cover)))).toList()),
          ),
        ).animate().fadeIn(),
        const SizedBox(height: 16),
        _field(_titleC, 'Title', required: true),
        _field(_descC, 'Description', maxLines: 3),
        _field(_priceC, 'Price (₹)', isNumber: true, required: true),
        const SizedBox(height: 12),
        Text('Category', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: ['Books', 'Electronics', 'Lab Equipment', 'Clothing', 'Stationery', 'Other'].map((c) =>
          ChoiceChip(label: Text(c, style: GoogleFonts.poppins(fontSize: 11)), selected: _category == c,
            selectedColor: Colors.cyanAccent, backgroundColor: Colors.white.withOpacity(0.08),
            labelStyle: TextStyle(color: _category == c ? Colors.black : Colors.grey),
            onSelected: (_) => setState(() => _category = c))).toList()),
        const SizedBox(height: 16),
        Text('Condition', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: ['Like New', 'Good', 'Used', 'Fair'].map((c) =>
          ChoiceChip(label: Text(c, style: GoogleFonts.poppins(fontSize: 11)), selected: _condition == c,
            selectedColor: Colors.cyanAccent, backgroundColor: Colors.white.withOpacity(0.08),
            labelStyle: TextStyle(color: _condition == c ? Colors.black : Colors.grey),
            onSelected: (_) => setState(() => _condition = c))).toList()),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          onPressed: _posting ? null : _post,
          child: _posting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text('Post Listing', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
        )).animate().fadeIn(delay: 200.ms),
      ])),
    );
  }

  Widget _field(TextEditingController c, String label, {bool required = false, bool isNumber = false, int maxLines = 1}) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: TextFormField(controller: c, maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(labelText: label, labelStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
        filled: true, fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))));
  }
}
