import 'dart:math';
import 'package:flutter/material.dart';

/// Custom painter that creates a "water filling up" effect for icons.
/// Uses a sine wave to create a liquid surface that animates as it fills.
class LiquidIconPainter extends CustomPainter {
  final double fillLevel;      // 0.0 (empty) to 1.0 (full)
  final double wavePhase;      // Phase offset for wave animation (0 to 2π)
  final double waveAmplitude;  // Height of waves in pixels
  final Color liquidColor;
  final Color outlineColor;

  LiquidIconPainter({
    required this.fillLevel,
    required this.wavePhase,
    this.waveAmplitude = 4.0,
    required this.liquidColor,
    this.outlineColor = Colors.white54,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    
    // Calculate the base Y position of the water level
    // fillLevel 0 = bottom, fillLevel 1 = top
    final baseY = height * (1 - fillLevel);
    
    // Create the wave path
    final wavePath = Path();
    wavePath.moveTo(0, height);
    
    // Start from bottom-left, go up to wave level
    wavePath.lineTo(0, baseY);
    
    // Draw sine wave across the top
    for (double x = 0; x <= width; x += 1) {
      final waveY = baseY + 
          waveAmplitude * sin((x / width) * 4 * pi + wavePhase) *
          // Reduce wave amplitude near edges for smooth look
          sin((x / width) * pi);
      wavePath.lineTo(x, waveY);
    }
    
    // Complete the path
    wavePath.lineTo(width, height);
    wavePath.close();
    
    // Create gradient for liquid effect
    final liquidPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          liquidColor.withOpacity(0.9),
          liquidColor.withOpacity(0.6),
          liquidColor.withOpacity(0.8),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, width, height));
    
    // Draw the liquid fill
    canvas.drawPath(wavePath, liquidPaint);
    
    // Add a subtle highlight at the top of the liquid
    if (fillLevel > 0.1) {
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      
      final highlightPath = Path();
      highlightPath.moveTo(0, baseY);
      for (double x = 0; x <= width; x += 1) {
        final waveY = baseY + 
            waveAmplitude * sin((x / width) * 4 * pi + wavePhase) *
            sin((x / width) * pi);
        highlightPath.lineTo(x, waveY);
      }
      canvas.drawPath(highlightPath, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(LiquidIconPainter oldDelegate) {
    return oldDelegate.fillLevel != fillLevel ||
           oldDelegate.wavePhase != wavePhase ||
           oldDelegate.liquidColor != liquidColor;
  }
}

/// Clips child widget with a liquid wave effect
class LiquidClipper extends CustomClipper<Path> {
  final double fillLevel;
  final double wavePhase;
  final double waveAmplitude;

  LiquidClipper({
    required this.fillLevel,
    required this.wavePhase,
    this.waveAmplitude = 4.0,
  });

  @override
  Path getClip(Size size) {
    final width = size.width;
    final height = size.height;
    final baseY = height * (1 - fillLevel);
    
    final path = Path();
    path.moveTo(0, height);
    path.lineTo(0, baseY);
    
    for (double x = 0; x <= width; x += 1) {
      final waveY = baseY + 
          waveAmplitude * sin((x / width) * 4 * pi + wavePhase) *
          sin((x / width) * pi);
      path.lineTo(x, waveY);
    }
    
    path.lineTo(width, height);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(LiquidClipper oldClipper) {
    return oldClipper.fillLevel != fillLevel ||
           oldClipper.wavePhase != wavePhase;
  }
}
