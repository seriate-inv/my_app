import 'package:flutter/material.dart';

class CustomPainterWithRectAndDiagonals extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class NonReturningValveSymbolPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color.fromARGB(255, 255, 255, 255)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    // Draw outer rectangle
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Triangle points
    final triangleStartX = size.width * 0.3;
    final triangleEndX = size.width * 0.7;

    // Draw triangle (valve check direction)
    final trianglePath = Path();
    trianglePath.moveTo(triangleStartX, size.height / 2);
    trianglePath.lineTo(triangleEndX, 0);
    trianglePath.lineTo(triangleEndX, size.height);
    trianglePath.close();
    canvas.drawPath(trianglePath, paint);

    // Draw vertical line to the left of the triangle
    canvas.drawLine(
      Offset(size.width * 0.3, 0),
      Offset(size.width * 0.3, size.height),
      paint,
    );

    // Draw horizontal line through center, skipping the triangle
    final centerY = size.height / 2;
    // Left segment (up to start of triangle)
    canvas.drawLine(Offset(0, centerY), Offset(triangleStartX, centerY), paint);
    // Right segment (after end of triangle)
    canvas.drawLine(
      Offset(triangleEndX, centerY),
      Offset(size.width, centerY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
