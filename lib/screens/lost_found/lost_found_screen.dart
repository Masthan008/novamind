import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/student_auth_service.dart';
import '../../services/college_service.dart';
import '../../services/imagekit_service.dart';
import 'dart:io';

class LostFoundScreen extends StatefulWidget {
  const LostFoundScreen({super.key});
  @override
  State<LostFoundScreen> createState() => _LostFoundScreenState();
}

class _LostFoundScreenState extends State<LostFoundScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String _filter = 'All';
  Map<String, dynamic>? _college;
  final _db = Supabase.instance.client;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      _college = await CollegeService.getStudentCollege();
      if (_college != null) {
        final data = await _db.from('lost_found_items').select()
            .eq('college_id', _college!['id']).neq('status', 'expired')
            .order('created_at', ascending: false);
        _items = List<Map<String, dynamic>>.from(data);
      } else { _items = _fallback; }
    } catch (e) { _items = _fallback; }
    if (mounted) setState(() => _loading = false);
  }

  void _showPostSheet() {
    final descC = TextEditingController();
    final locationC = TextEditingController();
    String type = 'Lost';
    String category = 'Electronics';
    File? imageFile;

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Post Item', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          Row(children: ['Lost', 'Found'].map((t) => Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(label: Text(t), selected: type == t, selectedColor: t == 'Lost' ? Colors.redAccent : Colors.greenAccent,
              backgroundColor: Colors.white.withOpacity(0.08), labelStyle: TextStyle(color: type == t ? Colors.white : Colors.grey),
              onSelected: (_) => setSheet(() => type = t)),
          ))).toList()),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: ['Electronics', 'Books', 'ID Cards', 'Keys', 'Clothing', 'Other'].map((c) =>
            ChoiceChip(label: Text(c, style: GoogleFonts.poppins(fontSize: 11)), selected: category == c,
              selectedColor: Colors.tealAccent, backgroundColor: Colors.white.withOpacity(0.08),
              labelStyle: TextStyle(color: category == c ? Colors.black : Colors.grey),
              onSelected: (_) => setSheet(() => category = c))
          ).toList()),
          const SizedBox(height: 12),
          TextField(controller: descC, maxLines: 2, style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
            decoration: _inputDec('Description')),
          const SizedBox(height: 10),
          TextField(controller: locationC, style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
            decoration: _inputDec('Location last seen')),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 800);
              if (picked != null) setSheet(() => imageFile = File(picked.path));
            },
            child: Container(height: 60, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.tealAccent.withOpacity(0.3))),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.camera_alt, color: Colors.tealAccent.withOpacity(0.5)), const SizedBox(width: 8),
                Text(imageFile != null ? 'Photo selected ✅' : 'Add photo', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
              ])),
          ),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            onPressed: () async {
              if (descC.text.isEmpty) return;
              Navigator.pop(ctx);
              String? imageUrl;
              if (imageFile != null) imageUrl = await ImagekitService.uploadImage(imageFile: imageFile!, fileName: 'lf_${DateTime.now().millisecondsSinceEpoch}', folder: '/zerno/lost_found');
              try {
                final student = StudentAuthService.currentStudent;
                await _db.from('lost_found_items').insert({
                  'student_id': student?.id.toString(), 'student_name': student?.name,
                  'item_type': type, 'category': category, 'description': descC.text,
                  'location_seen': locationC.text, 'image_url': imageUrl,
                  'college_id': _college?['id'],
                });
                _load();
              } catch (_) {}
            },
            child: Text('Post', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          )),
        ])),
      )),
    );
  }

  InputDecoration _inputDec(String hint) => InputDecoration(
    hintText: hint, hintStyle: GoogleFonts.poppins(color: Colors.grey),
    filled: true, fillColor: Colors.white.withOpacity(0.05),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
  );

  @override
  Widget build(BuildContext context) {
    final filters = ['All', 'Lost', 'Found', 'Claimed'];
    final filtered = _filter == 'All' ? _items : _items.where((i) => (_filter == 'Lost' || _filter == 'Found') ? i['item_type'] == _filter : i['status'] == _filter.toLowerCase()).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        title: Text('Lost & Found', style: GoogleFonts.orbitron(color: Colors.tealAccent, fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white70), onPressed: () => Navigator.pop(context)),
      ),
      floatingActionButton: _college != null ? FloatingActionButton(backgroundColor: Colors.tealAccent, foregroundColor: Colors.black, child: const Icon(Icons.add), onPressed: _showPostSheet) : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.tealAccent))
          : Column(children: [
              SizedBox(height: 42, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children:
                filters.map((f) => Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(
                  label: Text(f, style: GoogleFonts.poppins(fontSize: 12)), selected: _filter == f,
                  selectedColor: Colors.tealAccent, backgroundColor: Colors.white.withOpacity(0.08),
                  labelStyle: TextStyle(color: _filter == f ? Colors.black : Colors.grey),
                  onSelected: (_) => setState(() => _filter = f)))).toList(),
              )).animate().fadeIn(),
              Expanded(
                child: filtered.isEmpty
                    ? Center(child: Text('No items posted', style: GoogleFonts.poppins(color: Colors.grey)))
                    : RefreshIndicator(onRefresh: _load, child: ListView.builder(
                        padding: const EdgeInsets.all(16), itemCount: filtered.length,
                        itemBuilder: (_, i) => _itemCard(filtered[i], i),
                      )),
              ),
            ]),
    );
  }

  Widget _itemCard(Map<String, dynamic> item, int index) {
    final isLost = item['item_type'] == 'Lost';
    final color = isLost ? Colors.redAccent : Colors.greenAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.2))),
      child: Row(children: [
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
          child: Icon(isLost ? Icons.search_off : Icons.check_circle_outline, color: color, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
              child: Text(item['item_type'] ?? '', style: GoogleFonts.poppins(color: color, fontSize: 9, fontWeight: FontWeight.bold))),
            const SizedBox(width: 6),
            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
              child: Text(item['category'] ?? '', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 9))),
          ]),
          const SizedBox(height: 6),
          Text(item['description'] ?? '', style: GoogleFonts.poppins(color: Colors.white, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
          if (item['location_seen'] != null) Text('📍 ${item['location_seen']}', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 10)),
        ])),
      ]),
    ).animate().fadeIn(delay: Duration(milliseconds: 100 + index * 50)).slideX(begin: 0.03);
  }

  static final _fallback = [
    {'item_type': 'Lost', 'category': 'Electronics', 'description': 'Black earbuds lost near library', 'location_seen': 'Central Library', 'id': '1'},
    {'item_type': 'Found', 'category': 'ID Cards', 'description': 'Found student ID card in cafeteria', 'location_seen': 'Main Cafeteria', 'id': '2'},
  ];
}
