import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../services/ai_service.dart';
import '../../services/student_auth_service.dart';

class FluxAIScreen extends StatefulWidget {
  const FluxAIScreen({super.key});

  @override
  State<FluxAIScreen> createState() => _FluxAIScreenState();
}

class _FluxAIScreenState extends State<FluxAIScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  
  // Get tier dynamically from StudentAuthService
  String get _userTier => StudentAuthService.currentStudent?.subscriptionTier ?? 'free';

  @override
  void initState() {
    super.initState();
    
    // Add welcome message
    final welcomeMessage = AIService.hasAIAccess(_userTier)
        ? '👋 Hello! I\'m Sentinel AI, your intelligent study assistant created by Masthan Valli for Sentinel Student OS.\n\n${AIService.getTierFeatures(_userTier)}'
        : '👋 Hello! I\'m Sentinel AI. ${AIService.getTierFeatures(_userTier)}';
    
    _messages.add({
      'role': 'ai',
      'content': welcomeMessage
    });
  }

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final prompt = _controller.text;
    setState(() {
      _messages.add({'role': 'user', 'content': prompt});
      _isLoading = true;
    });

    _controller.clear();

    try {
      final response = await AIService.getResponse(prompt, userTier: _userTier);

      setState(() {
        _messages.add({'role': 'ai', 'content': response});
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'ai', 'content': 'Error: $e'});
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Sentinel AI",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: const Color(0xFFFF6B6B),
          ),
        ),
        backgroundColor: Colors.transparent,
        actions: [
          // Tier badge
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _userTier == 'ultra'
                    ? [Colors.purple, Colors.deepPurple]
                    : _userTier == 'pro'
                        ? [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)]
                        : [Colors.grey, Colors.grey.shade700],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _userTier.toUpperCase(),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFFFF6B6B).withOpacity(0.2)
                          : Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isUser ? const Color(0xFFFF6B6B) : Colors.white24,
                      ),
                    ),
                    child: isUser
                        ? Text(
                            msg['content']!,
                            style: const TextStyle(color: Colors.white),
                          )
                        : MarkdownBody(
                            data: msg['content']!,
                            styleSheet: MarkdownStyleSheet.fromTheme(
                              Theme.of(context),
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const LinearProgressIndicator(color: Color(0xFFFF6B6B)),
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.grey[900],
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Ask Sentinel AI...",
                        filled: true,
                        fillColor: Colors.black,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFFFF6B6B)),
                    onPressed: _sendMessage,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
