import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  // Key for the RepaintBoundary (Captures drawing ONLY)
  final GlobalKey _canvasKey = GlobalKey();
  
  // Layers
  Uint8List? _bakedImage; // Old strokes
  late SignatureController _controller;
  
  // Settings
  double _currentStrokeWidth = 3.0;
  Color _currentColor = Colors.white;
  bool _isUploading = false;
  
  // Tools
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
      exportBackgroundColor: Colors.transparent, // Important!
    );
  }

  // 📸 BAKE: Only captures the drawing layers, NOT the grid
  Future<void> _bakeCurrentStrokes() async {
    if (_controller.isEmpty) return;

    try {
      // 1. Capture the specific boundary (The Stroke Stack)
      RenderRepaintBoundary? boundary = _canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      // 2. High Res Capture
      ui.Image image = await boundary.toImage(pixelRatio: 3.0); 
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        setState(() {
          _bakedImage = byteData.buffer.asUint8List(); // Save as new base
          _controller.clear(); // Clear active lines
        });
      }
    } catch (e) {
      debugPrint("Bake error: $e");
    }
  }

  // 🖨️ EXPORT: Handles White-on-Black PDF
  Future<void> _saveAndUpload() async {
    await _bakeCurrentStrokes(); // Finalize drawing
    
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
            return pw.Container(
              color: PdfColors.black, // 🟢 FIX: Make PDF Background Black
              child: pw.Stack(
                children: [
                  // The Drawing
                  if (_bakedImage != null)
                     pw.Center(child: pw.Image(pw.MemoryImage(_bakedImage!))),
                  
                  // The Watermark (Inverted color)
                  pw.Center(
                    child: pw.Opacity(
                      opacity: 0.15,
                      child: pw.Transform.rotate(
                        angle: 0.5,
                        child: pw.Column(
                          mainAxisSize: pw.MainAxisSize.min,
                          children: [
                            pw.Text(studentName, style: pw.TextStyle(fontSize: 40, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                            pw.Text(regId, style: pw.TextStyle(fontSize: 30, color: PdfColors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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

  // 🧼 ERASER LOGIC
  void _toggleEraser() {
    _bakeCurrentStrokes();
    setState(() {
      _isEraserMode = !_isEraserMode;
      // Eraser paints Black (to match background)
      _currentColor = _isEraserMode ? Colors.black : Colors.white;
      _initializeController();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text("Drafter Pro 📐", style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E1E1E),
        actions: [
          IconButton(
            icon: Icon(_showGrid ? Icons.grid_off : Icons.grid_on, color: Colors.cyanAccent), 
            onPressed: () => setState(() => _showGrid = !_showGrid)
          ),
          IconButton(
            icon: Icon(Icons.upload_file, color: Colors.greenAccent), 
            onPressed: _saveAndUpload
          ),
        ],
      ),
      body: Column(
        children: [
          // 🎨 CANVAS AREA
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black, // Background is strictly Black
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: Stack(
                children: [
                  // 1. GRID LAYER (Bottom, Visual Only)
                  // This is OUTSIDE the RepaintBoundary so it never gets saved!
                  if (_showGrid) Positioned.fill(child: CustomPaint(painter: GridPainter())),

                  // 2. DRAWING LAYER (The part we capture)
                  Positioned.fill(
                    child: RepaintBoundary(
                      key: _canvasKey,
                      child: Stack(
                        children: [
                          // Baked Image (Previous Strokes)
                          if (_bakedImage != null)
                            Positioned.fill(child: Image.memory(_bakedImage!, fit: BoxFit.cover)),

                          // Active Pen (Current Stroke)
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

                  // 📏 REAL RULER (Draggable)
                  if (_showRuler)
                    DraggableToolWidget(
                      child: CustomPaint(
                        size: const Size(300, 80),
                        painter: RulerPainter(),
                      ),
                    ),

                  // 📐 REAL PROTRACTOR (Draggable)
                  if (_showCompass)
                    DraggableToolWidget(
                      child: CustomPaint(
                        size: const Size(200, 200),
                        painter: ProtractorPainter(),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // 🎛️ TOOLBAR
          Container(
            padding: const EdgeInsets.all(10),
            color: const Color(0xFF1E1E1E),
            child: Row(
              children: [
                 // TOOLS TOGGLES
                _buildToggleBtn(Icons.straighten, _showRuler, () => setState(() => _showRuler = !_showRuler)),
                const SizedBox(width: 8),
                _buildToggleBtn(Icons.architecture, _showCompass, () => setState(() => _showCompass = !_showCompass)),
                
                const SizedBox(width: 20),
                
                // ERASER
                GestureDetector(
                  onTap: _toggleEraser,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _isEraserMode ? Colors.red : Colors.grey[800],
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: const Icon(Icons.cleaning_services, size: 20, color: Colors.white),
                  ),
                ),
                
                const SizedBox(width: 20),
                
                // COLORS (Hidden if erasing)
                if (!_isEraserMode) ...[
                  _buildColorBtn(Colors.white),
                  _buildColorBtn(Colors.blueAccent),
                  _buildColorBtn(Colors.yellowAccent),
                ],

                const Spacer(),
                
                // SLIDER
                SizedBox(
                  width: 100,
                  child: Slider(
                    value: _currentStrokeWidth,
                    min: 1, max: 20,
                    activeColor: _isEraserMode ? Colors.red : Colors.cyanAccent,
                    onChangeEnd: (_) => _bakeCurrentStrokes(),
                    onChanged: (val) {
                      setState(() {
                        _currentStrokeWidth = val;
                        // Refresh Controller
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

  Widget _buildToggleBtn(IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? Colors.cyanAccent.withOpacity(0.2) : Colors.transparent,
          border: Border.all(color: isActive ? Colors.cyanAccent : Colors.grey),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Icon(icon, size: 20, color: isActive ? Colors.cyanAccent : Colors.grey),
      ),
    );
  }

  Widget _buildColorBtn(Color color) {
    return GestureDetector(
      onTap: () {
        _bakeCurrentStrokes();
        setState(() {
          _isEraserMode = false;
          _currentColor = color;
          _initializeController();
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: color, 
          shape: BoxShape.circle, 
          border: Border.all(color: Colors.white, width: _currentColor == color ? 2 : 0)
        ),
      ),
    );
  }
}

// 📏 DRAGGABLE TOOL WIDGET
class DraggableToolWidget extends StatefulWidget {
  final Widget child;
  const DraggableToolWidget({super.key, required this.child});
  @override
  State<DraggableToolWidget> createState() => _DraggableToolWidgetState();
}

class _DraggableToolWidgetState extends State<DraggableToolWidget> {
  Offset _offset = const Offset(100, 100);
  double _scale = 1.0;

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
            // Rotation removed to prevent spinning
          });
        },
        child: Transform(
          transform: Matrix4.identity()..scale(_scale),
          alignment: Alignment.center,
          child: Opacity(opacity: 0.7, child: widget.child),
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

// 📏 PAINTER: Yellow Engineering Ruler
class RulerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Yellow Plastic Body (Transparent)
    final bodyPaint = Paint()
      ..color = Colors.yellowAccent.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = Colors.yellowAccent.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));

    canvas.drawRRect(rrect, bodyPaint);
    canvas.drawRRect(rrect, borderPaint);

    // 2. Ticks (Markings)
    final tickPaint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..strokeWidth = 1.5;

    // Draw Ticks every 10 pixels (simulating mm/cm)
    for (double i = 10; i < size.width; i += 10) {
      double height = (i % 50 == 0) ? 25.0 : 12.0; // Long tick every 5th
      canvas.drawLine(Offset(i, 0), Offset(i, height), tickPaint);
      canvas.drawLine(Offset(i, size.height), Offset(i, size.height - height), tickPaint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 📐 PAINTER: Engineering Protractor
class ProtractorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    // 1. Body
    final bodyPaint = Paint()
      ..color = Colors.orangeAccent.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.14159, 3.14159, false, bodyPaint,
    );

    // 2. Border
    final borderPaint = Paint()
      ..color = Colors.orangeAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.14159, 3.14159, false, borderPaint,
    );
    
    // 3. Angle Lines
    final linePaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..strokeWidth = 1.5;

    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), borderPaint);
    canvas.drawLine(center, center - const Offset(0, 20), linePaint); // 90 degree mark
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}