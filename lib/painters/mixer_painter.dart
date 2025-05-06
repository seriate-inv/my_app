import 'package:flutter/material.dart';

class MixerPainter extends CustomPainter {
  final Color color;
  
  MixerPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    // Draw mixer blades as a simple cross
    final center = Offset(size.width / 2, size.height / 2);
    
    // Horizontal blade
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center,
          width: size.width - 0.5 * size.width,
          height: 3,
        ),
        const Radius.circular(5),
      ),
      paint,
    );
    
    // Vertical blade
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center,
          width: 3,
          height: size.height - 0.5 * size.height,
        ),
        const Radius.circular(5),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}