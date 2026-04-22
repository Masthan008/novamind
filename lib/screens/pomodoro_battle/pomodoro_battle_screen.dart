import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/student_auth_service.dart';

class PomodoroBattleScreen extends StatefulWidget {
  const PomodoroBattleScreen({super.key});
  @override
  State<PomodoroBattleScreen> createState() => _PomodoroBattleScreenState();
}

class _PomodoroBattleScreenState extends State<PomodoroBattleScreen> {
  // Timer
  int _minutes = 25;
  int _seconds = 0;
  bool _isRunning = false;
  bool _isBattle = false;
  Timer? _timer;
  int _totalSeconds = 25 * 60;
  int _remainingSeconds = 25 * 60;

  // Battle
  List<Map<String, dynamic>> _history = [];
  bool _loading = true;
  final _db = Supabase.instance.client;

  @override
  void initState() { super.initState(); _loadHistory(); }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  Future<void> _loadHistory() async {
    try {
      final student = StudentAuthService.currentStudent;
      if (student != null) {
        final data = await _db.from('pomodoro_battles').select()
            .or('challenger_id.eq.${student.id},opponent_id.eq.${student.id}')
            .order('created_at', ascending: false).limit(20);
        _history = List<Map<String, dynamic>>.from(data);
      }
    } catch (e) {
      _history = _fallbackHistory;
    }
    if (mounted) setState(() => _loading = false);
  }

  void _startTimer() {
    setState(() { _isRunning = true; _remainingSeconds = _totalSeconds; });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        _timer?.cancel();
        HapticFeedback.heavyImpact();
        setState(() { _isRunning = false; _minutes = 0; _seconds = 0; });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🎉 Session complete!'), backgroundColor: Colors.green));
      } else {
        setState(() {
          _remainingSeconds--;
          _minutes = _remainingSeconds ~/ 60;
          _seconds = _remainingSeconds % 60;
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() { _isRunning = false; _minutes = _totalSeconds ~/ 60; _seconds = 0; _remainingSeconds = _totalSeconds; });
  }

  void _showChallengeSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Challenge a Friend', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          Text('Start a focus battle via Supabase Realtime', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 24),
          ...['15 min Sprint', '25 min Classic', '45 min Deep Focus'].map((opt) {
            final mins = opt.startsWith('15') ? 15 : opt.startsWith('25') ? 25 : 45;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SizedBox(width: double.infinity, child: OutlinedButton(
                style: OutlinedButton.styleFrom(foregroundColor: Colors.amberAccent, side: BorderSide(color: Colors.amberAccent.withOpacity(0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() { _totalSeconds = mins * 60; _remainingSeconds = _totalSeconds; _minutes = mins; _seconds = 0; _isBattle = true; });
                  _startTimer();
                },
                child: Text(opt, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              )),
            );
          }),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalSeconds > 0 ? (_totalSeconds - _remainingSeconds) / _totalSeconds : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0,
        title: Text('Pomodoro Battle', style: GoogleFonts.orbitron(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white70), onPressed: () => Navigator.pop(context))),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
        // Timer Circle
        const SizedBox(height: 20),
        SizedBox(
          width: 220, height: 220,
          child: Stack(alignment: Alignment.center, children: [
            SizedBox(width: 220, height: 220, child: CircularProgressIndicator(
              value: progress, strokeWidth: 8, backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation(_isBattle ? Colors.amberAccent : Colors.cyanAccent),
            )),
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('${_minutes.toString().padLeft(2, '0')}:${_seconds.toString().padLeft(2, '0')}',
                style: GoogleFonts.orbitron(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold)),
              Text(_isBattle ? '⚔️ BATTLE MODE' : 'FOCUS', style: GoogleFonts.poppins(color: _isBattle ? Colors.amberAccent : Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
          ]),
        ).animate().scale(delay: 100.ms, duration: 600.ms, curve: Curves.elasticOut),
        const SizedBox(height: 32),

        // Controls
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (!_isRunning) ...[
            // Duration selector
            ...([15, 25, 45].map((m) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: GestureDetector(
                onTap: () => setState(() { _totalSeconds = m * 60; _remainingSeconds = _totalSeconds; _minutes = m; _seconds = 0; }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _totalSeconds == m * 60 ? Colors.cyanAccent.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10), border: Border.all(color: _totalSeconds == m * 60 ? Colors.cyanAccent : Colors.grey.shade800)),
                  child: Text('${m}m', style: GoogleFonts.orbitron(color: _totalSeconds == m * 60 ? Colors.cyanAccent : Colors.grey, fontSize: 13)),
                ),
              ),
            ))),
          ],
        ]).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 20),

        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ElevatedButton.icon(
            icon: Icon(_isRunning ? Icons.stop : Icons.play_arrow, size: 20),
            label: Text(_isRunning ? 'Stop' : 'Start Solo', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: _isRunning ? Colors.redAccent : Colors.cyanAccent, foregroundColor: _isRunning ? Colors.white : Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            onPressed: _isRunning ? _stopTimer : () { _isBattle = false; _startTimer(); },
          ),
          if (!_isRunning) ...[
            const SizedBox(width: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.flash_on, size: 20),
              label: Text('Battle', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amberAccent, foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              onPressed: _showChallengeSheet,
            ),
          ],
        ]).animate().fadeIn(delay: 300.ms),

        const SizedBox(height: 36),

        // Session History
        Align(alignment: Alignment.centerLeft, child: Text('Battle History', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)).animate().fadeIn(delay: 400.ms)),
        const SizedBox(height: 12),
        if (_loading)
          const CircularProgressIndicator(color: Colors.amberAccent)
        else if (_history.isEmpty)
          Text('No battles yet — challenge a friend!', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13))
        else
          ..._history.take(5).map((b) => Container(
            margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Icon(b['status'] == 'completed' ? Icons.emoji_events : Icons.timer, color: b['status'] == 'completed' ? Colors.amberAccent : Colors.grey, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text('${b['duration_minutes'] ?? 25} min ${b['status'] ?? 'pending'}', style: GoogleFonts.poppins(color: Colors.white, fontSize: 13))),
              Text(b['winner_id'] != null ? 'Won' : '—', style: GoogleFonts.poppins(color: Colors.amberAccent, fontSize: 12, fontWeight: FontWeight.bold)),
            ]),
          )),
        const SizedBox(height: 40),
      ])),
    );
  }

  static final _fallbackHistory = <Map<String, dynamic>>[];
}
