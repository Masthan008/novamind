import 'dart:typed_data';
import 'dart:ui' as ui; // Needed for image capture
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // Needed for RepaintBoundary
import 'package:signature/signature.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class DigitalDrafterScreen extends StatefulWidget {
  const DigitalDrafterScreen({super.key});

  @override
  State<DigitalDrafterScreen> createState() => _DigitalDrafterScreenState();
}

class _DigitalDrafterScreenState extends State<DigitalDrafterScreen> {
  // GlobalKey to capture the EXACT screen size (Fixes the Zoom Bug)
  final GlobalKey _canvasKey = GlobalKey();
  
  Uint8List? _backgroundImage; 
  late SignatureController _controller;
  
  double _currentStrokeWidth = 3.0;
  Color _currentColor = Colors.white;
  bool _isUploading = false;
  
  // Tools State
  bool _showGrid = true;
  bool _showRuler = false;
  bool _showCompass = false;
  bool _isEraserMode = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    _controller = SignatureController(
      penStrokeWidth: _currentStrokeWidth,
      penColor: _currentColor,
      exportBackgroundColor: Colors.transparent,
    );
  }

  // 📸 FIX: Capture the widget exactly as it looks (No trimming/zooming)
  Future<void> _bakeCurrentStrokes() async {
    if (_controller.isEmpty) return;

    try {
      // 1. Find the RenderObject of the canvas
      RenderRepaintBoundary? boundary = _canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      // 2. Convert to Image (Pixel Perfect)
      ui.Image image = await boundary.toImage(pixelRatio: 2.0); // 2.0 for High Quality
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        setState(() {
          _backgroundImage = byteData.buffer.asUint8List(); // Set as new background
          _controller.clear(); // Clear active pen
        });
      }
    } catch (e) {
      debugPrint("Error baking strokes: $e");
    }
  }

  Future<void> _saveAndUpload() async {
    // Force bake any active strokes first so they are included
    await _bakeCurrentStrokes();
    
    setState(() => _isUploading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      final String studentName = user?.userMetadata?['name'] ?? "Engineering Student";
      final String regId = user?.userMetadata?['reg_id'] ?? "ID: XXXXX";

      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                // Draw the FULL Combined Image
                if (_backgroundImage != null)
                  pw.Center(child: pw.Image(pw.MemoryImage(_backgroundImage!))),
                
                // Add Watermark
                pw.Center(
                  child: pw.Opacity(
                    opacity: 0.15,
                    child: pw.Transform.rotate(
                      angle: 0.5,
                      child: pw.Column(
                        mainAxisSize: pw.MainAxisSize.min,
                        children: [
                          pw.Text(studentName, style: pw.TextStyle(fontSize: 40, fontWeight: pw.FontWeight.bold, color: PdfColors.grey)),
                          pw.Text(regId, style: pw.TextStyle(fontSize: 30, color: PdfColors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(onLayout: (format) => pdf.save());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text("Drafter Pro 📐", style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E1E1E),
        actions: [
          IconButton(icon: Icon(_showGrid ? Icons.grid_off : Icons.grid_on, color: Colors.cyanAccent), onPressed: () => setState(() => _showGrid = !_showGrid)),
          // 📏 Toggle Draggable Ruler
          IconButton(icon: Icon(Icons.straighten, color: _showRuler ? Colors.yellowAccent : Colors.grey), onPressed: () => setState(() => _showRuler = !_showRuler)),
          // 🧭 Toggle Draggable Compass
          IconButton(icon: Icon(Icons.architecture, color: _showCompass ? Colors.orangeAccent : Colors.grey), onPressed: () => setState(() => _showCompass = !_showCompass)),
          IconButton(icon: const Icon(Icons.upload_file, color: Colors.greenAccent), onPressed: _saveAndUpload),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // 🖌️ THE DRAWING CANVAS (Wrapped in RepaintBoundary)
                RepaintBoundary(
                  key: _canvasKey,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.black, border: Border.all(color: Colors.grey[800]!)),
                    child: Stack(
                      children: [
                        if (_showGrid) Positioned.fill(child: CustomPaint(painter: GridPainter())),
                        
                        // Background Layer (Previous Strokes)
                        if (_backgroundImage != null)
                          Positioned.fill(child: Image.memory(_backgroundImage!, fit: BoxFit.cover)),

                        // Active Layer (Current Pen)
                        Positioned.fill(
                          child: Signature(
                            controller: _controller,
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 🛠️ DRAGGABLE TOOLS LAYER (Sits ON TOP of the canvas)
                // These will NOT be saved in the PDF, they are just guides.
                if (_showRuler)
                  const DraggableToolWidget(
                    child: Icon(Icons.straighten, size: 300, color: Colors.yellowAccent),
                  ),
                if (_showCompass)
                  const DraggableToolWidget(
                    child: Icon(Icons.architecture, size: 250, color: Colors.orangeAccent),
                  ),
              ],
            ),
          ),
          
          // 🎛️ CONTROLS
          Container(
            padding: const EdgeInsets.all(10),
            color: const Color(0xFF1E1E1E),
            child: Row(
              children: [
                // Eraser
                GestureDetector(
                  onTap: () {
                    _bakeCurrentStrokes();
                    setState(() {
                      _isEraserMode = !_isEraserMode;
                      _currentColor = _isEraserMode ? Colors.black : Colors.white;
                      _initializeController(); // Reset with new color
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: _isEraserMode ? Colors.red : Colors.grey[800], borderRadius: BorderRadius.circular(5)),
                    child: const Icon(Icons.cleaning_services, size: 20, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 15),
                
                // Color Palette (Only active if not erasing)
                if (!_isEraserMode) ...[
                  _buildColorBtn(Colors.white),
                  _buildColorBtn(Colors.blueAccent),
                  _buildColorBtn(Colors.yellowAccent),
                ],

                const Spacer(),
                const Text("Size: ", style: TextStyle(color: Colors.grey)),
                SizedBox(
                  width: 120,
                  child: Slider(
                    value: _currentStrokeWidth,
                    min: 1, max: 20,
                    activeColor: _isEraserMode ? Colors.red : Colors.cyanAccent,
                    onChangeEnd: (_) => _bakeCurrentStrokes(), // Bake when done sliding
                    onChanged: (val) {
                      setState(() {
                        _currentStrokeWidth = val;
                        // Recreate controller to apply size
                        _controller = SignatureController(
                          penStrokeWidth: val,
                          penColor: _currentColor,
                          exportBackgroundColor: Colors.transparent,
                          points: _controller.points,
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorBtn(Color color) {
    return GestureDetector(
      onTap: () {
        _bakeCurrentStrokes(); // Save old color layer
        setState(() {
          _currentColor = color;
          _initializeController();
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        width: 30, height: 30,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: _currentColor == color ? 2 : 0)),
      ),
    );
  }
}

// 📏 DRAGGABLE TOOL WIDGET (Move, Rotate, Scale)
class DraggableToolWidget extends StatefulWidget {
  final Widget child;
  const DraggableToolWidget({super.key, required this.child});

  @override
  State<DraggableToolWidget> createState() => _DraggableToolWidgetState();
}

class _DraggableToolWidgetState extends State<DraggableToolWidget> {
  Offset _offset = const Offset(100, 100);
  double _scale = 1.0;
  double _rotation = 0.0;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: GestureDetector(
        onScaleUpdate: (details) {
          setState(() {
            _offset += details.focalPointDelta;
            _scale = (_scale * details.scale).clamp(0.5, 3.0);
            _rotation += details.rotation;
          });
        },
        child: Transform(
          transform: Matrix4.identity()
            ..scale(_scale)
            ..rotateZ(_rotation),
          alignment: Alignment.center,
          child: Opacity(opacity: 0.8, child: widget.child), // Slightly transparent to see lines under it
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white10..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 40) canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (double y = 0; y < size.height; y += 40) canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}