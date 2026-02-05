import 'dart:math';
import 'package:flutter/material.dart';

/// Enhanced Draggable Tool Widget with Rotation Controls
class DraggableToolWidget extends StatefulWidget {
  final Widget child;
  final String toolName;
  final VoidCallback? onClose;
  
  const DraggableToolWidget({
    super.key,
    required this.child,
    required this.toolName,
    this.onClose,
  });
  
  @override
  State<DraggableToolWidget> createState() => _DraggableToolWidgetState();
}

class _DraggableToolWidgetState extends State<DraggableToolWidget> {
  Offset _offset = const Offset(100, 100);
  double _scale = 1.0;
  double _rotation = 0.0; // Rotation in radians
  bool _isLocked = false;
  bool _showControls = true;
  
  // Snap angles in radians
  final List<double> _snapAngles = [
    0, // 0°
    pi / 12, // 15°
    pi / 6, // 30°
    pi / 4, // 45°
    pi / 3, // 60°
    pi / 2, // 90°
    2 * pi / 3, // 120°
    3 * pi / 4, // 135°
    5 * pi / 6, // 150°
    pi, // 180°
  ];
  
  double get _rotationDegrees => _rotation * 180 / pi;
  
  void _snapToNearestAngle() {
    double nearestAngle = _snapAngles.reduce((a, b) => 
      (a - _rotation).abs() < (b - _rotation).abs() ? a : b
    );
    
    setState(() {
      _rotation = nearestAngle;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The Tool
        Positioned(
          left: _offset.dx,
          top: _offset.dy,
          child: GestureDetector(
            onScaleUpdate: _isLocked ? null : (details) {
              setState(() {
                _offset += details.focalPointDelta;
                _scale = (_scale * details.scale).clamp(0.5, 3.0);
              });
            },
            child: Transform(
              transform: Matrix4.identity()
                ..scale(_scale)
                ..rotateZ(_rotation),
              alignment: Alignment.center,
              child: Opacity(
                opacity: 0.7,
                child: widget.child,
              ),
            ),
          ),
        ),
        
        // Control Panel
        if (_showControls)
          Positioned(
            left: _offset.dx,
            top: _offset.dy - 120,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tool Name
                  Row(
                    children: [
                      Text(
                        widget.toolName,
                        style: const TextStyle(
                          color: Colors.cyanAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Close button
                      if (widget.onClose != null)
                        InkWell(
                          onTap: widget.onClose,
                          child: const Icon(Icons.close, color: Colors.red, size: 16),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Rotation Slider
                  Row(
                    children: [
                      const Icon(Icons.rotate_right, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 150,
                        child: Slider(
                          value: _rotation,
                          min: 0,
                          max: 2 * pi,
                          activeColor: Colors.cyanAccent,
                          inactiveColor: Colors.grey,
                          onChanged: _isLocked ? null : (value) {
                            setState(() {
                              _rotation = value;
                            });
                          },
                        ),
                      ),
                      Text(
                        '${_rotationDegrees.toInt()}°',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                  
                  // Control Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Snap to Angle
                      _buildControlButton(
                        icon: Icons.grid_on,
                        label: 'Snap',
                        onTap: _snapToNearestAngle,
                      ),
                      
                      // Lock Rotation
                      _buildControlButton(
                        icon: _isLocked ? Icons.lock : Icons.lock_open,
                        label: _isLocked ? 'Locked' : 'Lock',
                        onTap: () {
                          setState(() {
                            _isLocked = !_isLocked;
                          });
                        },
                      ),
                      
                      // Reset
                      _buildControlButton(
                        icon: Icons.refresh,
                        label: 'Reset',
                        onTap: () {
                          setState(() {
                            _rotation = 0;
                            _scale = 1.0;
                            _offset = const Offset(100, 100);
                            _isLocked = false;
                          });
                        },
                      ),
                      
                      // Hide Controls
                      _buildControlButton(
                        icon: Icons.visibility_off,
                        label: 'Hide',
                        onTap: () {
                          setState(() {
                            _showControls = false;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        
        // Show Controls Button (when hidden)
        if (!_showControls)
          Positioned(
            left: _offset.dx,
            top: _offset.dy - 40,
            child: InkWell(
              onTap: () {
                setState(() {
                  _showControls = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.settings, color: Colors.cyanAccent, size: 20),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.cyanAccent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.cyanAccent, size: 16),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 8),
            ),
          ],
        ),
      ),
    );
  }
}
