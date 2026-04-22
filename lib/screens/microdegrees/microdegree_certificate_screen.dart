import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class MicrodegreeCertificateScreen extends StatelessWidget {
  final String studentName;
  final String degreeTitle;
  final String certificateId;

  const MicrodegreeCertificateScreen({
    super.key,
    required this.studentName,
    required this.degreeTitle,
    required this.certificateId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Certificate', style: GoogleFonts.poppins(
          fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Certificate card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1A1A2E),
                      const Color(0xFF16213E),
                      const Color(0xFF1A1A2E),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.tealAccent.withOpacity(0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.tealAccent.withOpacity(0.1),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Zerno logo
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.tealAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.school, color: Colors.tealAccent, size: 32),
                    ),
                    const SizedBox(height: 16),

                    Text('CERTIFICATE OF COMPLETION', style: GoogleFonts.orbitron(
                      fontSize: 12, color: Colors.tealAccent, letterSpacing: 3, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 24),

                    // Decorative line
                    Container(
                      width: 60,
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Colors.tealAccent, Color(0xFF00E5FF)]),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text('This certifies that', style: GoogleFonts.poppins(
                      color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 8),
                    Text(studentName, style: GoogleFonts.poppins(
                      fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text('has successfully completed', style: GoogleFonts.poppins(
                      color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.tealAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
                      ),
                      child: Text(degreeTitle, style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w600, color: Colors.tealAccent),
                        textAlign: TextAlign.center),
                    ),
                    const SizedBox(height: 20),

                    Text('MicroDegree by Zerno', style: GoogleFonts.poppins(
                      color: Colors.grey.shade500, fontSize: 12)),
                    const SizedBox(height: 24),

                    // Certificate ID
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('ID: $certificateId', style: GoogleFonts.firaCode(
                        fontSize: 11, color: Colors.grey.shade500)),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      'Issued on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                      style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 11),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.95, 0.95)),

              const SizedBox(height: 32),

              // Done button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Done', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
