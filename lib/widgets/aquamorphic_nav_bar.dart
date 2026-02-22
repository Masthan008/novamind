import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Aquamorphic Liquid Navigation Bar
/// Inspired by Oppo ColorOS 13/14 design language
/// Enhanced version with VISIBLE liquid and glow effects
class AquamorphicNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Color glowColor;

  const AquamorphicNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.glowColor = Colors.cyanAccent,
  });

  @override
  State<AquamorphicNavBar> createState() => _AquamorphicNavBarState();
}

class _AquamorphicNavBarState extends State<AquamorphicNavBar>
    with TickerProviderStateMixin {
  
  // === Animation Controllers ===
  late AnimationController _waveController;      // Sine wave animation
  late AnimationController _fillController;      // Water fill level
  late AnimationController _glowPulseController; // Glow pulse effect
  late AnimationController _snapController;      // Elastic snap
  
  // === State Variables ===
  double _dragPosition = 0.0;
  bool _isDragging = false;
  int _tentativeIndex = 0;
  List<double> _neighborIntensities = [0, 0, 0, 0];
  
  // === Nav Items Configuration ===
  final List<NavItem> _items = [
    NavItem(Icons.calendar_today_outlined, Icons.calendar_today, "Timetable", Colors.cyanAccent),
    NavItem(Icons.chat_bubble_outline, Icons.chat_bubble, "ChatHub", Colors.pinkAccent),
    NavItem(Icons.schedule_outlined, Icons.schedule, "Routine", Colors.orangeAccent),
    NavItem(Icons.book_outlined, Icons.book, "Diary", Colors.purpleAccent),
  ];

  @override
  void initState() {
    super.initState();
    
    // Wave animation - continuous sine wave for liquid effect
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    
    // Fill animation - water level rising
    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      value: 1.0, // Start filled
    );
    
    // Glow pulse - breathing effect for selected item
    _glowPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    // Elastic snap controller
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    _fillController.dispose();
    _glowPulseController.dispose();
    _snapController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AquamorphicNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      // Animate fill effect for new selection
      _fillController.forward(from: 0);
    }
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _dragPosition = details.localPosition.dx;
      _updateTentativeIndex();
    });
    HapticFeedback.lightImpact();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final width = context.size?.width ?? 300;
    setState(() {
      _dragPosition = details.localPosition.dx.clamp(0, width);
      _updateTentativeIndex();
      _updateNeighborIntensities(width);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final width = context.size?.width ?? 300;
    final itemWidth = width / _items.length;
    final targetX = (_tentativeIndex + 0.5) * itemWidth;
    
    // Create elastic snap animation
    final startPos = _dragPosition;
    _snapController.reset();
    _snapController.addListener(() {
      if (mounted) {
        final t = Curves.elasticOut.transform(_snapController.value);
        setState(() {
          _dragPosition = startPos + (targetX - startPos) * t;
          _updateNeighborIntensities(width);
        });
      }
    });
    
    _snapController.forward().then((_) {
      if (mounted) {
        setState(() {
          _isDragging = false;
          _neighborIntensities = List.filled(_items.length, 0.0);
        });
      }
    });
    
    // Select the tab
    if (_tentativeIndex != widget.currentIndex) {
      widget.onTap(_tentativeIndex);
      HapticFeedback.mediumImpact();
    }
  }

  void _updateTentativeIndex() {
    final width = context.size?.width ?? 300;
    final itemWidth = width / _items.length;
    _tentativeIndex = (_dragPosition / itemWidth).floor().clamp(0, _items.length - 1);
  }

  void _updateNeighborIntensities(double totalWidth) {
    final itemWidth = totalWidth / _items.length;
    
    for (int i = 0; i < _items.length; i++) {
      final iconCenter = (i + 0.5) * itemWidth;
      final distance = (iconCenter - _dragPosition).abs();
      final maxSpillDistance = itemWidth * 1.5;
      
      if (distance > maxSpillDistance) {
        _neighborIntensities[i] = 0.0;
      } else {
        _neighborIntensities[i] = 1.0 - (distance / maxSpillDistance);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
      height: 85,
      child: Stack(
        children: [
          // === Outer Glow Effect ===
          AnimatedBuilder(
            animation: _glowPulseController,
            builder: (context, _) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: _items[widget.currentIndex].color.withOpacity(
                        0.5 + 0.3 * _glowPulseController.value
                      ),
                      blurRadius: 25 + 15 * _glowPulseController.value,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              );
            },
          ),
          
          // === Main Container ===
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0A0A),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: widget.glowColor.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // === Selection Indicator (Glowing Background) ===
                      AnimatedBuilder(
                        animation: Listenable.merge([_glowPulseController, _fillController]),
                        builder: (context, _) {
                          return AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            left: _getItemPosition(widget.currentIndex),
                            top: 8,
                            child: Container(
                              width: _getItemWidth() - 8,
                              height: 69,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    _items[widget.currentIndex].color.withOpacity(
                                      0.30 + 0.15 * _glowPulseController.value
                                    ),
                                    _items[widget.currentIndex].color.withOpacity(0.15),
                                  ],
                                ),
                                border: Border.all(
                                  color: _items[widget.currentIndex].color.withOpacity(0.7),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _items[widget.currentIndex].color.withOpacity(0.6),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      
                      // === Drag Light Trail ===
                      if (_isDragging)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _LightTrailPainter(
                              position: _dragPosition,
                              color: widget.glowColor,
                              intensities: _neighborIntensities,
                              itemCount: _items.length,
                            ),
                          ),
                        ),
                      
                      // === Navigation Items ===
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(_items.length, (index) {
                          return _buildNavItem(index);
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getItemWidth() {
    final screenWidth = MediaQuery.of(context).size.width - 32; // Account for margins
    return screenWidth / _items.length;
  }

  double _getItemPosition(int index) {
    return index * _getItemWidth() + 4;
  }

  Widget _buildNavItem(int index) {
    final item = _items[index];
    final isSelected = widget.currentIndex == index;
    final isHovered = _isDragging && _tentativeIndex == index;
    final glowIntensity = _neighborIntensities[index];
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!_isDragging) {
            widget.onTap(index);
            HapticFeedback.lightImpact();
          }
        },
        child: Container(
          height: 85,
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // === Icon with Liquid Fill Effect ===
              AnimatedBuilder(
                animation: Listenable.merge([_waveController, _fillController, _glowPulseController]),
                builder: (context, child) {
                  return Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: item.color.withOpacity(0.8),
                                blurRadius: 16 + 8 * _glowPulseController.value,
                                spreadRadius: 3,
                              ),
                            ]
                          : isHovered
                              ? [
                                  BoxShadow(
                                    color: item.color.withOpacity(0.6 * glowIntensity),
                                    blurRadius: 14,
                                  ),
                                ]
                              : null,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // === Outline Icon (Background) ===
                        Icon(
                          item.outlineIcon,
                          size: 26,
                          color: isSelected
                              ? item.color.withOpacity(0.4)
                              : isHovered
                                  ? item.color.withOpacity(0.3 * glowIntensity)
                                  : Colors.white38,
                        ),
                        
                        // === Liquid Fill Effect (Selected Only) ===
                        if (isSelected)
                          ClipPath(
                            clipper: _WaveClipper(
                              fillLevel: _fillController.value,
                              wavePhase: _waveController.value * 2 * pi,
                              waveAmplitude: 6,
                            ),
                            child: ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  item.color,
                                  item.color.withOpacity(0.7),
                                  item.color,
                                ],
                              ).createShader(bounds),
                              child: Icon(
                                item.filledIcon,
                                size: 26,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        
                        // === Glowing Ring for Selected ===
                        if (isSelected)
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: item.color.withOpacity(
                                  0.5 + 0.4 * sin(_waveController.value * 2 * pi)
                                ),
                                width: 2.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 4),
              
              // === Label with Glow ===
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? item.color
                      : isHovered
                          ? item.color.withOpacity(glowIntensity)
                          : Colors.white54,
                  shadows: isSelected
                      ? [
                          Shadow(
                            color: item.color.withOpacity(1.0),
                            blurRadius: 12,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  item.label,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Data class for navigation items
class NavItem {
  final IconData outlineIcon;
  final IconData filledIcon;
  final String label;
  final Color color;

  NavItem(this.outlineIcon, this.filledIcon, this.label, this.color);
}

/// Custom clipper for wave/liquid fill effect
class _WaveClipper extends CustomClipper<Path> {
  final double fillLevel;
  final double wavePhase;
  final double waveAmplitude;

  _WaveClipper({
    required this.fillLevel,
    required this.wavePhase,
    this.waveAmplitude = 4.0,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final baseY = size.height * (1 - fillLevel);
    
    path.moveTo(0, size.height);
    path.lineTo(0, baseY);
    
    // Create wave pattern
    for (double x = 0; x <= size.width; x += 1) {
      final waveY = baseY + 
          waveAmplitude * sin((x / size.width) * 4 * pi + wavePhase) *
          sin((x / size.width) * pi);
      path.lineTo(x, waveY);
    }
    
    path.lineTo(size.width, size.height);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(_WaveClipper oldClipper) {
    return oldClipper.fillLevel != fillLevel || oldClipper.wavePhase != wavePhase;
  }
}

/// Painter for light trail effect during drag
class _LightTrailPainter extends CustomPainter {
  final double position;
  final Color color;
  final List<double> intensities;
  final int itemCount;

  _LightTrailPainter({
    required this.position,
    required this.color,
    required this.intensities,
    required this.itemCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Main glow at finger position
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(0.9),
          color.withOpacity(0.5),
          color.withOpacity(0.2),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.6, 1.0],
      ).createShader(
        Rect.fromCircle(
          center: Offset(position, size.height / 2),
          radius: 90,
        ),
      );
    
    canvas.drawCircle(Offset(position, size.height / 2), 90, paint);
    
    // Inner bright core
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.8),
          color.withOpacity(0.5),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(position, size.height / 2),
          radius: 40,
        ),
      );
    
    canvas.drawCircle(Offset(position, size.height / 2), 40, corePaint);
  }

  @override
  bool shouldRepaint(_LightTrailPainter oldDelegate) {
    return oldDelegate.position != position;
  }
}
