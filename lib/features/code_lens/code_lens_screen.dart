import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'code_lens_service.dart';

class CodeLensScreen extends StatefulWidget {
  const CodeLensScreen({super.key});

  @override
  State<CodeLensScreen> createState() => _CodeLensScreenState();
}

class _CodeLensScreenState extends State<CodeLensScreen> with TickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _isProcessing = false;
  bool _showRawOCR = false;
  String? _rawText;
  CodeLensResult? _result;
  String? _errorMessage;
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _errorMessage = 'No cameras found');
        return;
      }
      
      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      
      await _cameraController!.initialize();
      if (mounted) setState(() => _isCameraReady = true);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Camera error: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _captureAndScan() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    
    setState(() {
      _isProcessing = true;
      _result = null;
      _rawText = null;
      _errorMessage = null;
    });
    
    try {
      final xFile = await _cameraController!.takePicture();
      await _processImage(File(xFile.path));
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Capture failed: $e';
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile == null) return;
    
    setState(() {
      _isProcessing = true;
      _result = null;
      _rawText = null;
      _errorMessage = null;
    });
    
    await _processImage(File(xFile.path));
  }

  Future<void> _processImage(File imageFile) async {
    try {
      // Step 1: OCR
      final rawText = await CodeLensService.extractText(imageFile);
      
      if (rawText.trim().isEmpty) {
        setState(() {
          _isProcessing = false;
          _errorMessage = 'No text found in image. Try a clearer photo.';
        });
        return;
      }
      
      setState(() => _rawText = rawText);
      
      // Step 2: AI cleanup
      final result = await CodeLensService.cleanCode(rawText);
      
      setState(() {
        _result = result;
        _isProcessing = false;
      });
      
      if (result.error != null) {
        _showWarning(result.error!);
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Processing failed: $e';
      });
    }
  }

  void _showWarning(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.orange.shade800,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _copyCode() {
    final text = _result?.cleanedCode ?? _rawText ?? '';
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Code copied to clipboard!'),
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _resetScan() {
    setState(() {
      _result = null;
      _rawText = null;
      _errorMessage = null;
      _showRawOCR = false;
    });
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
            const Icon(Icons.qr_code_scanner_rounded, color: Colors.cyanAccent, size: 22),
            const SizedBox(width: 8),
            Text(
              'Code Lens',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: _result != null || _rawText != null
          ? _buildResultView()
          : _buildScannerView(),
    );
  }

  Widget _buildScannerView() {
    return Column(
      children: [
        // Tab bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: Colors.cyanAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
            ),
            labelColor: Colors.cyanAccent,
            unselectedLabelColor: Colors.grey,
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
            tabs: const [
              Tab(icon: Icon(Icons.camera_alt_rounded, size: 18), text: 'Camera', height: 44),
              Tab(icon: Icon(Icons.photo_library_rounded, size: 18), text: 'Gallery', height: 44),
            ],
          ),
        ),
        
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCameraTab(),
              _buildGalleryTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCameraTab() {
    if (_isProcessing) return _buildProcessingOverlay();
    
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade400, size: 64),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() => _errorMessage = null);
                  _initCamera();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
                child: Text('Retry', style: GoogleFonts.poppins(color: Colors.black)),
              ),
            ],
          ),
        ),
      );
    }
    
    if (!_isCameraReady) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.cyanAccent),
      );
    }
    
    return Stack(
      children: [
        // Camera preview
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CameraPreview(_cameraController!),
            ),
          ),
        ),
        
        // Scan frame overlay
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: CustomPaint(
              painter: _ScanFramePainter(),
            ),
          ),
        ),
        
        // Capture button
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: _captureAndScan,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.cyanAccent, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.cyanAccent,
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.black, size: 28),
                ),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
                .shimmer(duration: 2000.ms, color: Colors.cyanAccent.withOpacity(0.3)),
          ),
        ),
        
        // Hint
        Positioned(
          top: 30,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Point at code & tap capture',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGalleryTab() {
    if (_isProcessing) return _buildProcessingOverlay();
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.cyanAccent.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.cyanAccent.withOpacity(0.4), width: 2),
              ),
              child: const Icon(Icons.photo_library_rounded, color: Colors.cyanAccent, size: 56),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 1500.ms),
            const SizedBox(height: 24),
            Text(
              'Pick from Gallery',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a photo of code from your\ngallery to scan and clean',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 14),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _pickFromGallery,
              icon: const Icon(Icons.image_search_rounded),
              label: Text('Choose Image', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 8,
                shadowColor: Colors.cyanAccent.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const CircularProgressIndicator(
                  color: Colors.cyanAccent,
                  strokeWidth: 3,
                ),
                Icon(
                  _rawText == null ? Icons.text_snippet_outlined : Icons.auto_fix_high,
                  color: Colors.cyanAccent,
                  size: 32,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _rawText == null ? 'Extracting text...' : 'AI is cleaning code...',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            _rawText == null ? 'Running OCR on image' : 'Fixing syntax & formatting',
            style: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 13),
          ),
        ],
      ).animate().fadeIn(duration: 300.ms),
    );
  }

  Widget _buildResultView() {
    final displayText = _showRawOCR
        ? (_rawText ?? '')
        : (_result?.cleanedCode ?? _rawText ?? '');
    
    return Column(
      children: [
        // Header bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF111118),
            border: Border(
              bottom: BorderSide(color: Colors.cyanAccent.withOpacity(0.2)),
            ),
          ),
          child: Row(
            children: [
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (_result?.isRaw ?? true)
                      ? Colors.orange.withOpacity(0.2)
                      : Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (_result?.isRaw ?? true)
                        ? Colors.orange.withOpacity(0.5)
                        : Colors.green.withOpacity(0.5),
                  ),
                ),
                child: Text(
                  (_result?.isRaw ?? true) ? 'Raw OCR' : 'AI Cleaned',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: (_result?.isRaw ?? true) ? Colors.orange : Colors.green,
                  ),
                ),
              ),
              const Spacer(),
              // Toggle raw/cleaned
              if (_result != null && !_result!.isRaw && _rawText != null)
                TextButton.icon(
                  onPressed: () => setState(() => _showRawOCR = !_showRawOCR),
                  icon: Icon(
                    _showRawOCR ? Icons.auto_fix_high : Icons.text_snippet_outlined,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                  label: Text(
                    _showRawOCR ? 'Show Cleaned' : 'Show Raw',
                    style: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
        
        // Code display
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(4),
            child: HighlightView(
              displayText,
              language: 'c',
              theme: monokaiSublimeTheme,
              padding: const EdgeInsets.all(16),
              textStyle: GoogleFonts.sourceCodePro(fontSize: 14, height: 1.6),
            ),
          ),
        ),
        
        // Action buttons
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF111118),
            border: Border(
              top: BorderSide(color: Colors.cyanAccent.withOpacity(0.2)),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _copyCode,
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: Text('Copy Code', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                ),
                child: IconButton(
                  onPressed: _resetScan,
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
                  tooltip: 'Scan Again',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Paints a scan frame overlay with corner brackets
class _ScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    const cornerLength = 30.0;
    const radius = 16.0;
    final rect = Rect.fromLTWH(20, 20, size.width - 40, size.height - 40);
    
    // Top-left corner
    canvas.drawPath(
      Path()
        ..moveTo(rect.left, rect.top + cornerLength)
        ..lineTo(rect.left, rect.top + radius)
        ..quadraticBezierTo(rect.left, rect.top, rect.left + radius, rect.top)
        ..lineTo(rect.left + cornerLength, rect.top),
      paint,
    );
    
    // Top-right corner
    canvas.drawPath(
      Path()
        ..moveTo(rect.right - cornerLength, rect.top)
        ..lineTo(rect.right - radius, rect.top)
        ..quadraticBezierTo(rect.right, rect.top, rect.right, rect.top + radius)
        ..lineTo(rect.right, rect.top + cornerLength),
      paint,
    );
    
    // Bottom-left corner
    canvas.drawPath(
      Path()
        ..moveTo(rect.left, rect.bottom - cornerLength)
        ..lineTo(rect.left, rect.bottom - radius)
        ..quadraticBezierTo(rect.left, rect.bottom, rect.left + radius, rect.bottom)
        ..lineTo(rect.left + cornerLength, rect.bottom),
      paint,
    );
    
    // Bottom-right corner
    canvas.drawPath(
      Path()
        ..moveTo(rect.right - cornerLength, rect.bottom)
        ..lineTo(rect.right - radius, rect.bottom)
        ..quadraticBezierTo(rect.right, rect.bottom, rect.right, rect.bottom - radius)
        ..lineTo(rect.right, rect.bottom - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
