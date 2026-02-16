import 'dart:math';
import 'package:flutter/material.dart';

/// Custom painter that creates a glowing light source effect.
/// The glow follows finger position and spills to neighboring areas.
class GlowPainter extends CustomPainter {
  final double lightX;           // Horizontal position of light center
  final double lightY;           // Vertical position of light center
  final double intensity;        // Brightness 0.0-1.0
  final double radius;           // Glow spread radius
  final Color glowColor;
  final List<double>? neighborIntensities; // Intensity for each tab position

  GlowPainter({
    required this.lightX,
    this.lightY = 0,
    required this.intensity,
    this.radius = 80.0,
    required this.glowColor,
    this.neighborIntensities,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0) return;
    
    // Main glow at finger position
    _drawGlow(canvas, lightX, size.height / 2, intensity, radius);
    
    // Draw neighbor glows if provided
    if (neighborIntensities != null) {
      final itemWidth = size.width / neighborIntensities!.length;
      for (int i = 0; i < neighborIntensities!.length; i++) {
        if (neighborIntensities![i] > 0.05) {
          final centerX = (i + 0.5) * itemWidth;
          _drawGlow(
            canvas, 
            centerX, 
            size.height / 2, 
            neighborIntensities![i] * 0.5, // Reduced intensity for neighbors
            radius * 0.7,
          );
        }
      }
    }
  }

  void _drawGlow(Canvas canvas, double x, double y, double glowIntensity, double glowRadius) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          glowColor.withOpacity(0.6 * glowIntensity),
          glowColor.withOpacity(0.3 * glowIntensity),
          glowColor.withOpacity(0.1 * glowIntensity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.6, 1.0],
      ).createShader(
        Rect.fromCircle(center: Offset(x, y), radius: glowRadius),
      );
    
    canvas.drawCircle(Offset(x, y), glowRadius, paint);
    
    // Add an inner bright core
    final corePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          Colors.white.withOpacity(0.4 * glowIntensity),
          glowColor.withOpacity(0.2 * glowIntensity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(
        Rect.fromCircle(center: Offset(x, y), radius: glowRadius * 0.4),
      );
    
    canvas.drawCircle(Offset(x, y), glowRadius * 0.4, corePaint);
  }

  @override
  bool shouldRepaint(GlowPainter oldDelegate) {
    return oldDelegate.lightX != lightX ||
           oldDelegate.intensity != intensity ||
           oldDelegate.glowColor != glowColor ||
           oldDelegate.neighborIntensities != neighborIntensities;
  }
}

/// Painter for the background ambient glow effect
class AmbientGlowPainter extends CustomPainter {
  final double phase;
  final Color primaryColor;
  final Color secondaryColor;

  AmbientGlowPainter({
    required this.phase,
    required this.primaryColor,
    this.secondaryColor = Colors.purple,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Subtle pulsing ambient glow
    final opacity = 0.1 + 0.05 * sin(phase);
    
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          primaryColor.withOpacity(opacity),
          secondaryColor.withOpacity(opacity * 0.5),
          primaryColor.withOpacity(opacity),
        ],
        stops: [
          0.0,
          0.5 + 0.2 * sin(phase * 2),
          1.0,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(AmbientGlowPainter oldDelegate) {
    return oldDelegate.phase != phase;
  }
}
