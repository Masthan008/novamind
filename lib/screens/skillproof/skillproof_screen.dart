import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../widgets/glass_container.dart';

/// SkillProof Basic — Generate shareable proof-of-skill summaries
class SkillProofScreen extends StatefulWidget {
  const SkillProofScreen({super.key});

  @override
  State<SkillProofScreen> createState() => _SkillProofScreenState();
}

class _SkillProofScreenState extends State<SkillProofScreen> {
  final _nameController = TextEditingController();
  final _skillsController = TextEditingController();
  final _projectController = TextEditingController();
  final _achievementController = TextEditingController();
  String _tier = 'Beginner';
  bool _generated = false;

  static const List<String> tiers = ['Beginner', 'Intermediate', 'Advanced', 'Expert'];

  void _generateProof() {
    if (_nameController.text.isEmpty || _skillsController.text.isEmpty) return;
    HapticFeedback.mediumImpact();
    setState(() => _generated = true);
  }

  String _buildShareText() {
    final name = _nameController.text.trim();
    final skills = _skillsController.text.trim();
    final project = _projectController.text.trim();
    final achievement = _achievementController.text.trim();

    final buffer = StringBuffer();
    buffer.writeln('🏆 Zerno SkillProof Certificate');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('');
    buffer.writeln('👤 Student: $name');
    buffer.writeln('⭐ Tier: $_tier');
    buffer.writeln('');
    buffer.writeln('🛠️ Skills: $skills');
    if (project.isNotEmpty) buffer.writeln('📁 Project: $project');
    if (achievement.isNotEmpty) buffer.writeln('🏅 Achievement: $achievement');
    buffer.writeln('');
    buffer.writeln('📅 Generated: ${DateTime.now().toString().substring(0, 10)}');
    buffer.writeln('');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('Verified by Zerno Student OS');
    buffer.writeln('#ZernoSkillProof #StudentOS');

    return buffer.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skillsController.dispose();
    _projectController.dispose();
    _achievementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(colors: [Colors.amber, Colors.orangeAccent]).createShader(bounds),
          child: Text('SkillProof', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _generated ? _buildProofCard() : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Create Your Skill Proof', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        Text('Generate a shareable proof-of-skill summary', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13)),
        const SizedBox(height: 20),

        _buildField('Your Name', _nameController, Icons.person),
        const SizedBox(height: 14),
        _buildField('Skills (comma separated)', _skillsController, Icons.code, hint: 'Flutter, Python, Git...'),
        const SizedBox(height: 14),
        _buildField('Primary Project', _projectController, Icons.folder, isOptional: true, hint: 'My portfolio app...'),
        const SizedBox(height: 14),
        _buildField('Key Achievement', _achievementController, Icons.emoji_events, isOptional: true, hint: 'Won hackathon X...'),
        const SizedBox(height: 14),

        // Tier selection
        Text('Skill Tier', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: tiers.map((t) => ChoiceChip(
            label: Text(t, style: TextStyle(color: _tier == t ? Colors.black : Colors.white70, fontSize: 12)),
            selected: _tier == t,
            selectedColor: Colors.amber,
            backgroundColor: Colors.white.withOpacity(0.1),
            onSelected: (_) => setState(() => _tier = t),
          )).toList(),
        ),

        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _generateProof,
            icon: const Icon(Icons.auto_awesome, size: 20),
            label: Text('Generate SkillProof', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber, foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon,
      {bool isOptional = false, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(label, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
          if (isOptional) Text(' (optional)', style: GoogleFonts.poppins(color: Colors.white30, fontSize: 11)),
        ]),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint ?? label, hintStyle: TextStyle(color: Colors.white24),
            prefixIcon: Icon(icon, color: Colors.amber, size: 20),
            filled: true, fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildProofCard() {
    final shareText = _buildShareText();
    return Column(
      children: [
        // Certificate card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A1A2E),
                Colors.amber.withOpacity(0.1),
                const Color(0xFF1A1A2E),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amber.withOpacity(0.5), width: 2),
            boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.1), blurRadius: 20)],
          ),
          child: Column(
            children: [
              // Logo
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Colors.amber, Colors.orangeAccent]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.bolt, color: Colors.black, size: 28),
              ),
              const SizedBox(height: 12),
              Text('Zerno SkillProof', style: GoogleFonts.orbitron(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Certificate of Skills', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 16),
              Divider(color: Colors.amber.withOpacity(0.3)),
              const SizedBox(height: 12),

              _buildCertRow('👤', 'Student', _nameController.text),
              _buildCertRow('⭐', 'Tier', _tier),
              _buildCertRow('🛠️', 'Skills', _skillsController.text),
              if (_projectController.text.isNotEmpty)
                _buildCertRow('📁', 'Project', _projectController.text),
              if (_achievementController.text.isNotEmpty)
                _buildCertRow('🏅', 'Achievement', _achievementController.text),

              const SizedBox(height: 12),
              Divider(color: Colors.amber.withOpacity(0.3)),
              const SizedBox(height: 8),
              Text('Generated: ${DateTime.now().toString().substring(0, 10)}',
                style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11)),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Share.share(shareText);
                },
                icon: const Icon(Icons.share, size: 18),
                label: Text('Share'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.withOpacity(0.2), foregroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: shareText));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Copied to clipboard!'), backgroundColor: Colors.greenAccent.withOpacity(0.3)),
                  );
                },
                icon: const Icon(Icons.copy, size: 18),
                label: Text('Copy'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent.withOpacity(0.2), foregroundColor: Colors.cyanAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() => _generated = false),
          child: Text('← Edit Details', style: GoogleFonts.poppins(color: Colors.white54)),
        ),
      ],
    );
  }

  Widget _buildCertRow(String emoji, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text('$label: ', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13)),
          Expanded(child: Text(value, style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
