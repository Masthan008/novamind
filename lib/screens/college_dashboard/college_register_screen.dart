import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/college_service.dart';

class CollegeRegisterScreen extends StatefulWidget {
  const CollegeRegisterScreen({super.key});
  @override
  State<CollegeRegisterScreen> createState() => _CollegeRegisterScreenState();
}

class _CollegeRegisterScreenState extends State<CollegeRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameC = TextEditingController();
  final _locationC = TextEditingController();
  final _universityC = TextEditingController();
  final _tpoNameC = TextEditingController();
  final _tpoEmailC = TextEditingController();
  final _tpoPhoneC = TextEditingController();
  final _studentsC = TextEditingController();
  final _branchesC = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    for (final c in [_nameC, _locationC, _universityC, _tpoNameC, _tpoEmailC, _tpoPhoneC, _studentsC, _branchesC]) c.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final ok = await CollegeService.registerCollege({
      'name': _nameC.text.trim(),
      'location': _locationC.text.trim(),
      'university': _universityC.text.trim(),
      'tpo_name': _tpoNameC.text.trim(),
      'tpo_email': _tpoEmailC.text.trim(),
      'tpo_phone': _tpoPhoneC.text.trim(),
      'total_students': int.tryParse(_studentsC.text) ?? 0,
    });

    setState(() => _submitting = false);
    if (mounted) {
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Registration submitted for admin approval!'), backgroundColor: Colors.green));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Failed to register'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        title: Text('Register College', style: GoogleFonts.orbitron(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white70), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('College Details', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)).animate().fadeIn(),
            const SizedBox(height: 16),
            _buildField(_nameC, 'College Name', Icons.account_balance, required: true),
            _buildField(_locationC, 'Location (City, State)', Icons.location_on),
            _buildField(_universityC, 'Affiliated University', Icons.school),
            const SizedBox(height: 20),
            Text('TPO Details', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 16),
            _buildField(_tpoNameC, 'TPO Name', Icons.person, required: true),
            _buildField(_tpoEmailC, 'TPO Email', Icons.email, required: true),
            _buildField(_tpoPhoneC, 'TPO Phone', Icons.phone),
            _buildField(_studentsC, 'Total Students', Icons.people, isNumber: true),
            _buildField(_branchesC, 'Branches (CSE, ECE, ...)', Icons.list),
            const SizedBox(height: 28),
            SizedBox(width: double.infinity, child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : Text('Submit Registration', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
            )).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 12),
            Center(child: Text('Registration requires admin approval', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11))),
          ]),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController c, String label, IconData icon, {bool required = false, bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
        validator: required ? (v) => v == null || v.isEmpty ? 'Required' : null : null,
        decoration: InputDecoration(
          labelText: label, labelStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
          prefixIcon: Icon(icon, color: Colors.greenAccent.withOpacity(0.5), size: 20),
          filled: true, fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.greenAccent.withOpacity(0.5))),
        ),
      ),
    );
  }
}
