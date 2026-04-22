import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ListingDetailScreen extends StatelessWidget {
  final Map<String, dynamic> listing;
  const ListingDetailScreen({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final images = listing['images'] as List?;
    final sold = listing['is_sold'] == true;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white70), onPressed: () => Navigator.pop(context))),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Image carousel
        Container(
          height: 250, width: double.infinity,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
          child: images != null && images.isNotEmpty
              ? ClipRRect(borderRadius: BorderRadius.circular(20), child: PageView.builder(
                  itemCount: images.length,
                  itemBuilder: (_, i) => CachedNetworkImage(imageUrl: images[i], fit: BoxFit.cover, errorWidget: (_, __, ___) => const Icon(Icons.image, color: Colors.grey, size: 60)),
                ))
              : Center(child: Icon(Icons.shopping_bag, color: Colors.cyanAccent.withOpacity(0.3), size: 60)),
        ).animate().fadeIn(),
        const SizedBox(height: 20),

        // Title & Price
        Row(children: [
          Expanded(child: Text(listing['title'] ?? '', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20))),
          if (sold)
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
              child: Text('SOLD', style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12))),
        ]).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 8),
        Text('₹${listing['price'] ?? 0}', style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 28)).animate().fadeIn(delay: 150.ms),
        const SizedBox(height: 16),

        // Meta chips
        Wrap(spacing: 8, children: [
          _chip(listing['category'] ?? '', Colors.cyanAccent),
          _chip(listing['condition'] ?? '', Colors.amber),
        ]).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 20),

        // Description
        Text('Description', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)).animate().fadeIn(delay: 250.ms),
        const SizedBox(height: 8),
        Text(listing['description'] ?? 'No description', style: GoogleFonts.poppins(color: Colors.grey.shade300, fontSize: 14, height: 1.6)).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 24),

        // Seller Info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.cyanAccent.withOpacity(0.2))),
          child: Row(children: [
            CircleAvatar(radius: 20, backgroundColor: Colors.cyanAccent.withOpacity(0.2), child: const Icon(Icons.person, color: Colors.cyanAccent, size: 20)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(listing['student_name'] ?? 'Seller', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
              Text('Verified Student', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11)),
            ])),
            Icon(Icons.verified, color: Colors.cyanAccent, size: 20),
          ]),
        ).animate().fadeIn(delay: 350.ms),
        const SizedBox(height: 24),

        // Contact Button
        if (!sold)
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            icon: const Icon(Icons.chat_bubble_outline, size: 18),
            label: Text('Contact Seller', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('💬 Chat feature coming soon!'))),
          )).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 40),
      ])),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: GoogleFonts.poppins(color: color, fontSize: 11, fontWeight: FontWeight.w600)));
  }
}
