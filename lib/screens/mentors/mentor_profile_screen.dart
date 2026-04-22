import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/mentor_service.dart';

class MentorProfileScreen extends StatefulWidget {
  final Map<String, dynamic> mentor;
  const MentorProfileScreen({super.key, required this.mentor});

  @override
  State<MentorProfileScreen> createState() => _MentorProfileScreenState();
}

class _MentorProfileScreenState extends State<MentorProfileScreen> {
  final _topicController = TextEditingController();
  bool _isBooking = false;

  Future<void> _bookSession() async {
    if (_topicController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a topic', style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: const Color(0xFF2A2A3E),
      ));
      return;
    }

    setState(() => _isBooking = true);
    final mentorId = widget.mentor['id'] is int ? widget.mentor['id'] : int.tryParse('${widget.mentor['id']}') ?? 0;
    final ok = await MentorService.bookSession(
      mentorId: mentorId,
      topic: _topicController.text.trim(),
      scheduledAt: DateTime.now().add(const Duration(days: 1)),
    );

    if (mounted) {
      setState(() => _isBooking = false);
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('🎉 Session booked!', style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: const Color(0xFF2A2A3E),
        ));
        _topicController.clear();
      }
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.mentor['name'] ?? 'Mentor';
    final title = widget.mentor['title'] ?? '';
    final bio = widget.mentor['bio'] ?? '';
    final rating = (widget.mentor['rating'] ?? 5.0).toDouble();
    final sessions = widget.mentor['total_sessions'] ?? 0;
    final expertise = List<String>.from(widget.mentor['expertise'] ?? []);
    final rate = widget.mentor['rate_per_session'] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFF0A0A0F),
            expandedHeight: 220,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.orangeAccent.withOpacity(0.2), const Color(0xFF0A0A0F)],
                  ),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const SizedBox(height: 40),
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.orangeAccent.withOpacity(0.4), Colors.deepOrange.withOpacity(0.3)]),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(child: Text(name.isNotEmpty ? name[0] : 'M',
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold))),
                  ),
                  const SizedBox(height: 12),
                  Text(name, style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(title, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
                ]),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(delegate: SliverChildListDelegate([
              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _stat('⭐', rating.toStringAsFixed(1), 'Rating'),
                  _stat('📅', sessions.toString(), 'Sessions'),
                  _stat('💰', rate > 0 ? '₹$rate' : 'Free', 'Rate'),
                ],
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 24),

              // Bio
              Text('About', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 8),
              Text(bio, style: GoogleFonts.poppins(color: Colors.grey.shade300, fontSize: 13, height: 1.5)),
              const SizedBox(height: 24),

              // Expertise
              Text('Expertise', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: expertise.map((e) => Chip(
                label: Text(e, style: GoogleFonts.poppins(fontSize: 12, color: Colors.orangeAccent)),
                backgroundColor: Colors.orangeAccent.withOpacity(0.1),
                side: BorderSide(color: Colors.orangeAccent.withOpacity(0.3)),
              )).toList()),
              const SizedBox(height: 32),

              // Book session
              Text('Book a Session', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 12),
              TextField(
                controller: _topicController,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'What do you want to learn?',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isBooking ? null : _bookSession,
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(_isBooking ? 'Booking...' : 'Book Session',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 40),
            ])),
          ),
        ],
      ),
    );
  }

  Widget _stat(String emoji, String value, String label) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 10)),
      ]),
    );
  }
}
