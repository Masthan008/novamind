import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'lab_mesh_service.dart';

class LabMeshScreen extends StatefulWidget {
  const LabMeshScreen({super.key});

  @override
  State<LabMeshScreen> createState() => _LabMeshScreenState();
}

class _LabMeshScreenState extends State<LabMeshScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _messageController = TextEditingController();
  final _userNameController = TextEditingController(text: 'Student');

  // State
  bool _isAdvertising = false;
  bool _isDiscovering = false;
  bool _permissionsGranted = false;

  // Discovered peers
  final Map<String, String> _discoveredPeers = {}; // endpointId -> name
  final Set<String> _connectedPeers = {};
  final List<_ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkPermissions();
  }

  @override
  void dispose() {
    LabMeshService.stopAll();
    _messageController.dispose();
    _userNameController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    final granted = await LabMeshService.requestPermissions();
    if (mounted) setState(() => _permissionsGranted = granted);
  }

  void _setupCallbacks() {
    LabMeshService.onEndpointFound = (endpointId, name) {
      if (mounted) {
        setState(() => _discoveredPeers[endpointId] = name);
      }
    };

    LabMeshService.onEndpointLost = (endpointId) {
      if (mounted) {
        setState(() => _discoveredPeers.remove(endpointId));
      }
    };

    LabMeshService.onConnectionAccepted = (endpointId) {
      if (mounted) {
        setState(() => _connectedPeers.add(endpointId));
        _addSystemMessage('Connected to peer!');
        HapticFeedback.mediumImpact();
      }
    };

    LabMeshService.onDisconnected = (endpointId) {
      if (mounted) {
        setState(() {
          _connectedPeers.remove(endpointId);
          _discoveredPeers.remove(endpointId);
        });
        _addSystemMessage('Peer disconnected');
      }
    };

    LabMeshService.onMessageReceived = (endpointId, message) {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text: message,
            isMe: false,
            peerName: _discoveredPeers[endpointId] ?? 'Peer',
            timestamp: DateTime.now(),
          ));
        });
        HapticFeedback.lightImpact();
      }
    };

    LabMeshService.onError = (error) {
      if (mounted) {
        _showError(error);
      }
    };
  }

  void _addSystemMessage(String text) {
    setState(() {
      _messages.add(_ChatMessage(
        text: text,
        isMe: false,
        isSystem: true,
        timestamp: DateTime.now(),
      ));
    });
  }

  Future<void> _startAdvertising() async {
    _setupCallbacks();
    final success = await LabMeshService.startAdvertising(_userNameController.text);
    if (mounted) {
      setState(() => _isAdvertising = success);
      if (success) {
        _addSystemMessage('Broadcasting... waiting for peers');
      } else {
        _showError('Failed to start broadcasting');
      }
    }
  }

  Future<void> _stopAdvertising() async {
    await LabMeshService.stopAll();
    if (mounted) {
      setState(() {
        _isAdvertising = false;
        _connectedPeers.clear();
        _discoveredPeers.clear();
      });
    }
  }

  Future<void> _startDiscovery() async {
    _setupCallbacks();
    final success = await LabMeshService.startDiscovery(_userNameController.text);
    if (mounted) {
      setState(() => _isDiscovering = success);
      if (success) {
        _addSystemMessage('Scanning for nearby students...');
      } else {
        _showError('Failed to start scanning');
      }
    }
  }

  Future<void> _stopDiscovery() async {
    await LabMeshService.stopAll();
    if (mounted) {
      setState(() {
        _isDiscovering = false;
        _connectedPeers.clear();
        _discoveredPeers.clear();
      });
    }
  }

  Future<void> _connectToPeer(String endpointId) async {
    await LabMeshService.connectToEndpoint(endpointId, _userNameController.text);
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _connectedPeers.isEmpty) return;

    bool anySent = false;
    for (final peerId in _connectedPeers) {
      final success = await LabMeshService.sendText(peerId, text);
      if (success) anySent = true;
    }

    if (anySent) {
      setState(() {
        _messages.add(_ChatMessage(
          text: text,
          isMe: true,
          timestamp: DateTime.now(),
        ));
      });
      _messageController.clear();
      HapticFeedback.lightImpact();
    } else {
      _showError('Failed to send message. Check connection.');
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111118),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_tethering_rounded, color: Colors.greenAccent, size: 22),
            const SizedBox(width: 8),
            Text('LabMesh', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.greenAccent,
          labelColor: Colors.greenAccent,
          unselectedLabelColor: Colors.grey,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(icon: Icon(Icons.cell_tower_rounded), text: 'Send'),
            Tab(icon: Icon(Icons.radar_rounded), text: 'Receive'),
          ],
        ),
      ),
      body: !_permissionsGranted
          ? _buildPermissionView()
          : Column(
              children: [
                // User name input
                Container(
                  padding: const EdgeInsets.all(12),
                  color: const Color(0xFF111118),
                  child: TextField(
                    controller: _userNameController,
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Your Display Name',
                      labelStyle: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 12),
                      prefixIcon: const Icon(Icons.person, color: Colors.greenAccent, size: 20),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.3),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.greenAccent.withOpacity(0.3)),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSendTab(),
                      _buildReceiveTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPermissionView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_off_rounded, color: Colors.orange, size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              'Permissions Required',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'LabMesh needs Location, Bluetooth, and Wi-Fi permissions to find and connect with nearby students.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 14),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _checkPermissions,
              icon: const Icon(Icons.security_rounded),
              label: Text('Grant Permissions', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendTab() {
    return Column(
      children: [
        // Broadcast control
        Padding(
          padding: const EdgeInsets.all(16),
          child: GestureDetector(
            onTap: _isAdvertising ? _stopAdvertising : _startAdvertising,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                gradient: _isAdvertising
                    ? const LinearGradient(colors: [Color(0xFF00C853), Color(0xFF00E676)])
                    : LinearGradient(colors: [Colors.grey.shade800, Colors.grey.shade700]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: _isAdvertising
                    ? [BoxShadow(color: Colors.greenAccent.withOpacity(0.4), blurRadius: 20, spreadRadius: 2)]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isAdvertising ? Icons.cell_tower_rounded : Icons.power_settings_new_rounded,
                    color: _isAdvertising ? Colors.white : Colors.greenAccent,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isAdvertising ? 'Broadcasting...' : 'Start Broadcasting',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Connected peers
        if (_connectedPeers.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.people_alt_rounded, color: Colors.greenAccent, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${_connectedPeers.length} peer(s) connected',
                  style: GoogleFonts.poppins(color: Colors.greenAccent, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

        // Messages area
        Expanded(child: _buildMessagesArea()),

        // Send input
        if (_connectedPeers.isNotEmpty) _buildMessageInput(),
      ],
    );
  }

  Widget _buildReceiveTab() {
    return Column(
      children: [
        // Discovery control
        Padding(
          padding: const EdgeInsets.all(16),
          child: GestureDetector(
            onTap: _isDiscovering ? _stopDiscovery : _startDiscovery,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                gradient: _isDiscovering
                    ? const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF42A5F5)])
                    : LinearGradient(colors: [Colors.grey.shade800, Colors.grey.shade700]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: _isDiscovering
                    ? [BoxShadow(color: Colors.blueAccent.withOpacity(0.4), blurRadius: 20, spreadRadius: 2)]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isDiscovering ? Icons.radar_rounded : Icons.search_rounded,
                    color: _isDiscovering ? Colors.white : Colors.blueAccent,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isDiscovering ? 'Scanning...' : 'Find Nearby Students',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Discovered peers list
        if (_discoveredPeers.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Nearby Students',
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                ..._discoveredPeers.entries.map((entry) {
                  final isConnected = _connectedPeers.contains(entry.key);
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isConnected
                          ? Colors.greenAccent.withOpacity(0.2)
                          : Colors.blueAccent.withOpacity(0.2),
                      child: Icon(
                        isConnected ? Icons.check_circle_rounded : Icons.person_rounded,
                        color: isConnected ? Colors.greenAccent : Colors.blueAccent,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      entry.value,
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                    ),
                    subtitle: Text(
                      isConnected ? 'Connected' : 'Tap to connect',
                      style: GoogleFonts.poppins(
                        color: isConnected ? Colors.greenAccent : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    trailing: isConnected
                        ? const Icon(Icons.link_rounded, color: Colors.greenAccent, size: 20)
                        : const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
                    onTap: isConnected ? null : () => _connectToPeer(entry.key),
                  );
                }),
              ],
            ),
          ),

        if (_discoveredPeers.isEmpty && _isDiscovering)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    color: Colors.blueAccent.withOpacity(0.5),
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Looking for students nearby...',
                  style: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 14),
                ),
              ],
            ),
          ),

        // Messages area
        Expanded(child: _buildMessagesArea()),

        // Send input (if connected)
        if (_connectedPeers.isNotEmpty) _buildMessageInput(),
      ],
    );
  }

  Widget _buildMessagesArea() {
    if (_messages.isEmpty) {
      return Center(
        child: Text(
          'No messages yet',
          style: GoogleFonts.poppins(color: Colors.grey.shade700, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      reverse: true,
      itemBuilder: (context, index) {
        final msg = _messages[_messages.length - 1 - index];
        
        if (msg.isSystem) {
          return Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                msg.text,
                style: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 12),
              ),
            ),
          );
        }

        return Align(
          alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: msg.isMe
                  ? Colors.greenAccent.withOpacity(0.15)
                  : Colors.blueAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomRight: msg.isMe ? const Radius.circular(4) : null,
                bottomLeft: !msg.isMe ? const Radius.circular(4) : null,
              ),
              border: Border.all(
                color: msg.isMe
                    ? Colors.greenAccent.withOpacity(0.3)
                    : Colors.blueAccent.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!msg.isMe && msg.peerName != null)
                  Text(
                    msg.peerName!,
                    style: GoogleFonts.poppins(
                      color: Colors.blueAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                Text(
                  msg.text,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 200.ms).slideX(begin: msg.isMe ? 0.1 : -0.1);
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111118),
        border: Border(top: BorderSide(color: Colors.greenAccent.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
                filled: true,
                fillColor: Colors.black.withOpacity(0.3),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00C853), Color(0xFF00E676)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.greenAccent.withOpacity(0.3),
                    blurRadius: 8,
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

class _ChatMessage {
  final String text;
  final bool isMe;
  final bool isSystem;
  final String? peerName;
  final DateTime timestamp;

  _ChatMessage({
    required this.text,
    required this.isMe,
    this.isSystem = false,
    this.peerName,
    required this.timestamp,
  });
}
