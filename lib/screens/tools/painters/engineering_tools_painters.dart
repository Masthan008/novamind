import 'dart:math';
import 'package:flutter/material.dart';

/// Painter for 45-45-90 Set Square (Isosceles Right Triangle)
class SetSquare4545Painter extends CustomPainter {
  final double rotation;
  
  SetSquare4545Painter({this.rotation = 0});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellowAccent.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final markingsPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    // Save canvas state
    canvas.save();
    
    // Rotate around center
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(rotation);
    canvas.translate(-size.width / 2, -size.height / 2);
    
    // Triangle dimensions (200x200 right triangle)
    final triangleSize = 200.0;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Define triangle path (right angle at bottom-left)
    final path = Path()
      ..moveTo(centerX - triangleSize / 2, centerY + triangleSize / 2) // Bottom-left (90°)
      ..lineTo(centerX + triangleSize / 2, centerY + triangleSize / 2) // Bottom-right (45°)
      ..lineTo(centerX - triangleSize / 2, centerY - triangleSize / 2) // Top-left (45°)
      ..close();
    
    // Draw filled triangle
    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
    
    // Draw measurement markings (every 20 pixels)
    for (double i = 0; i <= triangleSize; i += 20) {
      // Horizontal markings (bottom edge)
      canvas.drawLine(
        Offset(centerX - triangleSize / 2 + i, centerY + triangleSize / 2),
        Offset(centerX - triangleSize / 2 + i, centerY + triangleSize / 2 - 5),
        markingsPaint,
      );
      
      // Vertical markings (left edge)
      canvas.drawLine(
        Offset(centerX - triangleSize / 2, centerY + triangleSize / 2 - i),
        Offset(centerX - triangleSize / 2 + 5, centerY + triangleSize / 2 - i),
        markingsPaint,
      );
    }
    
    // Draw angle markers
    _drawAngleMarker(canvas, Offset(centerX - triangleSize / 2, centerY + triangleSize / 2), '90°');
    _drawAngleMarker(canvas, Offset(centerX + triangleSize / 2, centerY + triangleSize / 2), '45°');
    _drawAngleMarker(canvas, Offset(centerX - triangleSize / 2, centerY - triangleSize / 2), '45°');
    
    canvas.restore();
  }
  
  void _drawAngleMarker(Canvas canvas, Offset position, String label) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    
    textPainter.paint(canvas, position - Offset(textPainter.width / 2, textPainter.height / 2));
  }
  
  @override
  bool shouldRepaint(SetSquare4545Painter oldDelegate) => rotation != oldDelegate.rotation;
}

/// Painter for 30-60-90 Set Square
class SetSquare3060Painter extends CustomPainter {
  final double rotation;
  
  SetSquare3060Painter({this.rotation = 0});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orangeAccent.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final markingsPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(rotation);
    canvas.translate(-size.width / 2, -size.height / 2);
    
    final base = 200.0;
    final height = base * sqrt(3) / 2; // 30-60-90 triangle height
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Define triangle path
    final path = Path()
      ..moveTo(centerX - base / 2, centerY + height / 2) // Bottom-left (90°)
      ..lineTo(centerX + base / 2, centerY + height / 2) // Bottom-right (30°)
      ..lineTo(centerX - base / 2, centerY - height / 2) // Top (60°)
      ..close();
    
    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
    
    // Draw measurement markings
    for (double i = 0; i <= base; i += 20) {
      canvas.drawLine(
        Offset(centerX - base / 2 + i, centerY + height / 2),
        Offset(centerX - base / 2 + i, centerY + height / 2 - 5),
        markingsPaint,
      );
    }
    
    // Angle markers
    _drawAngleMarker(canvas, Offset(centerX - base / 2, centerY + height / 2), '90°');
    _drawAngleMarker(canvas, Offset(centerX + base / 2, centerY + height / 2), '30°');
    _drawAngleMarker(canvas, Offset(centerX - base / 2, centerY - height / 2), '60°');
    
    canvas.restore();
  }
  
  void _drawAngleMarker(Canvas canvas, Offset position, String label) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    
    textPainter.paint(canvas, position - Offset(textPainter.width / 2, textPainter.height / 2));
  }
  
  @override
  bool shouldRepaint(SetSquare3060Painter oldDelegate) => rotation != oldDelegate.rotation;
}

/// Painter for Compass (Circle Drawing Tool)
class CompassPainter extends CustomPainter {
  final double rotation;
  final double radius;
  
  CompassPainter({this.rotation = 0, this.radius = 80});
  
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    canvas.save();
    canvas.translate(centerX, centerY);
    canvas.rotate(rotation);
    canvas.translate(-centerX, -centerY);
    
    // Draw compass body (two legs)
    final bodyPaint = Paint()
      ..color = Colors.blueGrey.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    // Left leg (fixed)
    canvas.drawLine(
      Offset(centerX, centerY - 20),
      Offset(centerX - 10, centerY + 60),
      bodyPaint,
    );
    
    // Right leg (adjustable)
    final angle = pi / 6; // 30 degrees
    final legLength = 80.0;
    canvas.drawLine(
      Offset(centerX, centerY - 20),
      Offset(centerX + legLength * sin(angle), centerY - 20 + legLength * cos(angle)),
      bodyPaint,
    );
    
    // Draw circle preview (translucent)
    final circlePaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawCircle(Offset(centerX - 10, centerY + 60), radius, circlePaint);
    
    // Center point marker
    final centerPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(centerX - 10, centerY + 60), 4, centerPaint);
    
    // Radius label
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'R: ${radius.toInt()}px',
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    
    textPainter.paint(canvas, Offset(centerX + 20, centerY));
    
    canvas.restore();
  }
  
  @override
  bool shouldRepaint(CompassPainter oldDelegate) => 
    rotation != oldDelegate.rotation || radius != oldDelegate.radius;
}
