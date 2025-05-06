import 'package:flutter/material.dart';

class Valve extends StatelessWidget {
  const Valve({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(15, 0), // Shift 5mm (~19px) to the right
      child: SizedBox(
        width: 30,
        height: 60,
        child: CustomPaint(painter: _ValveSymbolPainter()),
      ),
    );
  }
}

class _ValveSymbolPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color.fromARGB(255, 253, 253, 253)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    // Draw the outer rectangle
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Shift the X horizontally by ~3mm (≈ 11 pixels)
    final shiftX = 29.0;

    canvas.drawLine(
      Offset(0 + shiftX, 0), // Top-left shifted right
      Offset(size.width - shiftX, size.height), // Bottom-right
      paint,
    );
    canvas.drawLine(
      Offset(size.width - shiftX, 0), // Top-right shifted left
      Offset(0 + shiftX, size.height), // Bottom-left shifted right
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class NonReturningValve extends StatelessWidget {
  const NonReturningValve({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, 10), // Move upward by ~3mm
      child: SizedBox(
        width: 70,
        height: 25,
        child: CustomPaint(painter: _NonReturningValveSymbolPainter()),
      ),
    );
  }
}

class _NonReturningValveSymbolPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color.fromARGB(255, 255, 255, 255)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final triangleStartX = size.width * 0.3;
    final triangleEndX = size.width * 0.7;

    final trianglePath = Path();
    trianglePath.moveTo(triangleStartX, size.height / 2);
    trianglePath.lineTo(triangleEndX, 0);
    trianglePath.lineTo(triangleEndX, size.height);
    trianglePath.close();
    canvas.drawPath(trianglePath, paint);

    canvas.drawLine(
      Offset(size.width * 0.3, 0),
      Offset(size.width * 0.3, size.height),
      paint,
    );

    final centerY = size.height / 2;
    canvas.drawLine(Offset(0, centerY), Offset(triangleStartX, centerY), paint);
    canvas.drawLine(
      Offset(triangleEndX, centerY),
      Offset(size.width, centerY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
