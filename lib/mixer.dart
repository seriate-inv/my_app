import 'package:flutter/material.dart';

class Mixer extends StatelessWidget {
  final Color color;

  const Mixer({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: MixerPainter(color: color),
    );
  }
}

class MixerPainter extends CustomPainter {
  final Color color;

  MixerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
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