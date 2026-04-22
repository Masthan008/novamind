import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/college_service.dart';
import 'create_listing_screen.dart';
import 'listing_detail_screen.dart';

class StudentMarketplaceScreen extends StatefulWidget {
  const StudentMarketplaceScreen({super.key});
  @override
  State<StudentMarketplaceScreen> createState() => _StudentMarketplaceScreenState();
}

class _StudentMarketplaceScreenState extends State<StudentMarketplaceScreen> {
  List<Map<String, dynamic>> _listings = [];
  bool _loading = true;
  String _category = 'All';
  Map<String, dynamic>? _college;
  final _db = Supabase.instance.client;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      _college = await CollegeService.getStudentCollege();
      if (_college != null) {
        final data = await _db.from('marketplace_listings').select().eq('college_id', _college!['id']).order('created_at', ascending: false);
        _listings = List<Map<String, dynamic>>.from(data);
      } else { _listings = _fallback; }
    } catch (e) { _listings = _fallback; }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['All', 'Books', 'Electronics', 'Lab Equipment', 'Clothing', 'Stationery', 'Other'];
    final filtered = _category == 'All' ? _listings : _listings.where((l) => l['category'] == _category).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        title: Text('Marketplace', style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white70), onPressed: () => Navigator.pop(context)),
      ),
      floatingActionButton: _college != null ? FloatingActionButton(
        backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black,
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => CreateListingScreen(collegeId: _college!['id'] as int)));
          _load();
        },
      ) : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
          : Column(children: [
              SizedBox(height: 42, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children:
                categories.map((c) => Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(
                  label: Text(c, style: GoogleFonts.poppins(fontSize: 11)), selected: _category == c,
                  selectedColor: Colors.cyanAccent, backgroundColor: Colors.white.withOpacity(0.08),
                  labelStyle: TextStyle(color: _category == c ? Colors.black : Colors.grey),
                  onSelected: (_) => setState(() => _category = c)))).toList(),
              )).animate().fadeIn(),
              Expanded(
                child: filtered.isEmpty
                    ? Center(child: Text('No listings yet', style: GoogleFonts.poppins(color: Colors.grey)))
                    : RefreshIndicator(onRefresh: _load, child: GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.72),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => _listingCard(filtered[i], i),
                      )),
              ),
            ]),
    );
  }

  Widget _listingCard(Map<String, dynamic> l, int index) {
    final sold = l['is_sold'] == true;
    final images = l['images'] as List?;
    final imageUrl = images != null && images.isNotEmpty ? images[0] : null;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: l))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16),
          border: Border.all(color: (sold ? Colors.grey : Colors.cyanAccent).withOpacity(0.2)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Image
            Expanded(
              child: Stack(children: [
                Container(
                  width: double.infinity, color: Colors.white.withOpacity(0.03),
                  child: imageUrl != null
                      ? CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover, errorWidget: (_, __, ___) => const Icon(Icons.image, color: Colors.grey))
                      : Center(child: Icon(Icons.shopping_bag, color: Colors.cyanAccent.withOpacity(0.3), size: 40)),
                ),
                if (sold) Positioned.fill(child: Container(
                  color: Colors.black54, child: const Center(child: Text('SOLD', style: TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold))),
                )),
              ]),
            ),
            // Details
            Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l['title'] ?? '', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
              Row(children: [
                Text('₹${l['price'] ?? 0}', style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                const Spacer(),
                Text(l['condition'] ?? '', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 9)),
              ]),
            ])),
          ]),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 100 + index * 50)).scale(begin: const Offset(0.95, 0.95));
  }

  static final _fallback = [
    {'title': 'Data Structures Textbook', 'price': 150, 'category': 'Books', 'condition': 'Good', 'is_sold': false, 'student_name': 'Rahul', 'images': null, 'id': '1'},
    {'title': 'Scientific Calculator', 'price': 300, 'category': 'Electronics', 'condition': 'Like New', 'is_sold': false, 'student_name': 'Priya', 'images': null, 'id': '2'},
    {'title': 'Lab Coat (M)', 'price': 80, 'category': 'Clothing', 'condition': 'Used', 'is_sold': true, 'student_name': 'Ankit', 'images': null, 'id': '3'},
  ];
}
