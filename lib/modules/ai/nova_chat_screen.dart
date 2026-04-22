import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../services/ai_service.dart';
import '../../services/rag_service.dart';
import '../../services/student_auth_service.dart';
import '../../services/subscription_service.dart';

class NovaChatScreen extends StatefulWidget {
  const NovaChatScreen({super.key});

  @override
  State<NovaChatScreen> createState() => _NovaChatScreenState();
}

class _NovaChatScreenState extends State<NovaChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isThinking = false;
  bool _useZernoBrain = false; // RAG toggle
  List<String> _lastSources = []; // Sources from last RAG response
  
  // Get tier dynamically from StudentAuthService
  String get _userTier => StudentAuthService.currentStudent?.subscriptionTier ?? 'free';

  @override
  void initState() {
    super.initState();
    
    // Welcome message
    _messages.add(ChatMessage(
      text: '👋 Hey there! I\'m **Zerno AI**, your expert study assistant.\n\n'
            'I can help you with:\n'
            '• 💻 **Coding** — debugging, optimization, architecture\n'
            '• 📚 **Academics** — concepts, explanations, exam prep\n'
            '• 🚀 **Career** — roadmaps, interview prep, guidance\n'
            '• 🧠 **Problem Solving** — DSA, system design, logic\n\n'
            'Ask me anything — I\'ll give you detailed, expert-level answers!',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Build conversation history for API context
  List<Map<String, String>> _buildConversationHistory() {
    // Convert messages to API format, skip the welcome message
    final history = <Map<String, String>>[];
    for (int i = 1; i < _messages.length; i++) {
      final msg = _messages[i];
      history.add({
        "role": msg.isUser ? "user" : "assistant",
        "content": msg.text,
      });
    }
    return history;
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isThinking) return;

    // Add user message
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isThinking = true;
      _lastSources = [];
    });

    _controller.clear();
    _scrollToBottom();

    // Build conversation history including the new user message
    final history = _buildConversationHistory();

    try {
      String response;
      
      if (_useZernoBrain && SubscriptionService.isPro) {
        // RAG-enhanced response
        final result = await RAGService.askWithContext(
          text,
          conversationHistory: history,
        );
        response = result.answer;
        _lastSources = result.sources;
      } else {
        // Standard AI response
        response = await AIService.getResponse(
          text,
          userTier: _userTier,
          conversationHistory: history,
        );
      }

      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
          sources: List.from(_lastSources),
        ));
        _isThinking = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Sorry, I encountered an error. Please try again.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isThinking = false;
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _messages.add(ChatMessage(
        text: '🔄 Chat cleared! I still remember nothing from before — ask me anything fresh!',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '✅ Copied to clipboard',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        backgroundColor: const Color(0xFF2A2A3E),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Model Banner
          _buildModelBanner(),
          
          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),

          // Thinking Indicator
          if (_isThinking) _buildThinkingIndicator(),

          // Input Bar
          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0A0A1A),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF9C88FF)],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Zerno AI',
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'ONLINE • Llama 3.3 70B',
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Zerno Brain toggle (Pro only)
        if (SubscriptionService.isPro)
          Tooltip(
            message: _useZernoBrain ? 'Brain ON' : 'Brain OFF',
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _useZernoBrain = !_useZernoBrain);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: _useZernoBrain
                      ? const Color(0xFF6C63FF).withOpacity(0.3)
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _useZernoBrain ? const Color(0xFF6C63FF) : Colors.white24,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.psychology,
                      size: 16,
                      color: _useZernoBrain ? const Color(0xFF9C88FF) : Colors.white38,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Brain',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: _useZernoBrain ? const Color(0xFF9C88FF) : Colors.white38,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.white54),
          onPressed: _clearChat,
          tooltip: 'Clear Chat',
        ),
      ],
    );
  }

  Widget _buildModelBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6C63FF).withOpacity(0.15),
            const Color(0xFF9C88FF).withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_awesome, color: Color(0xFF9C88FF), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Zerno AI Pro',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Context-aware • Expert-level answers • Multi-turn chat',
                  style: GoogleFonts.poppins(
                    color: Colors.white38,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final timeStr = DateFormat('hh:mm a').format(message.timestamp);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!message.isUser) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6C63FF).withOpacity(0.3),
                        const Color(0xFF9C88FF).withOpacity(0.2),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome, color: Color(0xFF9C88FF), size: 18),
                ),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? const Color(0xFF6C63FF).withOpacity(0.3)
                        : const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                      bottomRight: Radius.circular(message.isUser ? 4 : 16),
                    ),
                    border: message.isUser
                        ? Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3))
                        : const Border(
                            left: BorderSide(color: Color(0xFF6C63FF), width: 3),
                          ),
                  ),
                  child: MarkdownBody(
                    data: message.text,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        height: 1.6,
                      ),
                      h1: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      h2: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      h3: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      strong: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      em: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.8),
                        fontStyle: FontStyle.italic,
                      ),
                      listBullet: GoogleFonts.poppins(
                        color: const Color(0xFF6C63FF),
                        fontSize: 14,
                      ),
                      code: GoogleFonts.firaCode(
                        backgroundColor: const Color(0xFF0D0D1A),
                        color: Colors.cyanAccent,
                        fontSize: 12,
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: const Color(0xFF0D0D1A),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      codeblockPadding: const EdgeInsets.all(14),
                      blockquote: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                      blockquoteDecoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withOpacity(0.08),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        border: const Border(
                          left: BorderSide(color: Color(0xFF6C63FF), width: 3),
                        ),
                      ),
                      tableBorder: TableBorder.all(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      tableHead: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      tableBody: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
              if (message.isUser) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 18),
                ),
              ],
            ],
          ),
          // Time + Copy + Feedback row
          Padding(
            padding: EdgeInsets.only(
              top: 4,
              left: message.isUser ? 0 : 46,
              right: message.isUser ? 46 : 0,
            ),
            child: Row(
              mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Text(
                  timeStr,
                  style: GoogleFonts.poppins(
                    color: Colors.white38,
                    fontSize: 10,
                  ),
                ),
                if (!message.isUser) ...[
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _copyToClipboard(message.text),
                    child: Icon(
                      Icons.copy_rounded,
                      size: 14,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Thumbs up
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      // Find the preceding user message
                      final idx = _messages.indexOf(message);
                      final question = idx > 0 ? _messages[idx - 1].text : '';
                      RAGService.saveFeedback(
                        question: question,
                        answer: message.text,
                        rating: 1,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('👍 Thanks for the feedback!', style: GoogleFonts.poppins(fontSize: 12)),
                          backgroundColor: const Color(0xFF2A2A3E),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Icon(Icons.thumb_up_alt_outlined, size: 14, color: Colors.white.withOpacity(0.3)),
                  ),
                  const SizedBox(width: 6),
                  // Thumbs down
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      final idx = _messages.indexOf(message);
                      final question = idx > 0 ? _messages[idx - 1].text : '';
                      RAGService.saveFeedback(
                        question: question,
                        answer: message.text,
                        rating: -1,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('👎 Noted, we\'ll improve!', style: GoogleFonts.poppins(fontSize: 12)),
                          backgroundColor: const Color(0xFF2A2A3E),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Icon(Icons.thumb_down_alt_outlined, size: 14, color: Colors.white.withOpacity(0.3)),
                  ),
                ],
              ],
            ),
          ),
          // Source chips (if RAG was used)
          if (!message.isUser && message.sources.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 6, left: message.isUser ? 0 : 46),
              child: Wrap(
                spacing: 6,
                children: [
                  Icon(Icons.psychology, size: 12, color: const Color(0xFF9C88FF).withOpacity(0.6)),
                  ...message.sources.map((s) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
                    ),
                    child: Text(s, style: GoogleFonts.poppins(fontSize: 9, color: const Color(0xFF9C88FF))),
                  )),
                ],
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(
          begin: message.isUser ? 0.2 : -0.2,
          end: 0,
        );
  }

  Widget _buildThinkingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Color(0xFF9C88FF)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _useZernoBrain ? 'Searching Zerno Brain...' : 'Zerno AI is thinking...',
            style: GoogleFonts.poppins(
              color: const Color(0xFF9C88FF),
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
        .fadeIn()
        .shimmer(color: const Color(0xFF6C63FF).withOpacity(0.3));
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 80,
        left: 16,
        right: 16,
        top: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A1A),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
      ),
      child: Row(
        children: [
          // Text field
          Expanded(
            child: TextField(
              controller: _controller,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Ask Zerno AI anything...',
                hintStyle: GoogleFonts.poppins(color: Colors.white30),
                filled: true,
                fillColor: const Color(0xFF1A1A2E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: const Color(0xFF6C63FF).withOpacity(0.4),
                    width: 1,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 10),
          
          // Send button
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF9C88FF)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String> sources;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.sources = const [],
  });
}
