import 'package:flutter/material.dart';
import 'dart:math' as math;

class PumpGauge extends StatelessWidget {
  final double currentValue;
  final double maxValue;

  const PumpGauge({Key? key, required this.currentValue, required this.maxValue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: PumpGaugePainter(currentValue: currentValue, maxValue: maxValue),
    );
  }
}

class PumpGaugePainter extends CustomPainter {
  final double currentValue;
  final double maxValue;

  PumpGaugePainter({required this.currentValue, required this.maxValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    
    // Draw background arc
    final backgroundPaint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    
    canvas.drawArc(
      Rect.fromCenter(center: center, width: radius * 2, height: radius * 2),
      math.pi * 0.75,
      math.pi * 1.5,
      false,
      backgroundPaint,
    );
    
    // Draw value arc
    final valuePaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    
    double sweepAngle = (currentValue / maxValue) * math.pi * 1.5;
    canvas.drawArc(
      Rect.fromCenter(center: center, width: radius * 2, height: radius * 2),
      math.pi * 0.75,
      sweepAngle,
      false,
      valuePaint,
    );
    
    // Draw indicator needle
    final needlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final needleAngle = math.pi * 0.75 + (currentValue / maxValue) * math.pi * 1.5;
    final needleLength = radius - 5;
    final needlePoint = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );
    
    canvas.drawLine(center, needlePoint, needlePaint);
    
    // Draw center circle
    canvas.drawCircle(center, 4, Paint()..color = Colors.white);
    
    // Draw min/max labels
    final minPainter = TextPainter(
      text: const TextSpan(
        text: '0',
        style: TextStyle(color: Colors.white, fontSize: 8),
      ),
      textDirection: TextDirection.ltr,
    );
    
    minPainter.layout();
    final minPoint = Offset(
      center.dx + (radius - 2) * math.cos(math.pi * 0.75) - minPainter.width / 2,
      center.dy + (radius - 2) * math.sin(math.pi * 0.75) - minPainter.height / 2,
    );
    
    minPainter.paint(canvas, minPoint);
    
    final maxPainter = TextPainter(
      text: TextSpan(
        text: '${maxValue.toInt()}',
        style: TextStyle(color: Colors.white, fontSize: 8),
      ),
      textDirection: TextDirection.ltr,
    );
    
    maxPainter.layout();
    final maxPoint = Offset(
      center.dx + (radius - 2) * math.cos(math.pi * 0.75 + math.pi * 1.5) - maxPainter.width / 2,
      center.dy + (radius - 2) * math.sin(math.pi * 0.75 + math.pi * 1.5) - maxPainter.height / 2,
    );

    maxPainter.paint(canvas, maxPoint);
  }

  @override
  bool shouldRepaint(covariant PumpGaugePainter oldDelegate) {
    return oldDelegate.currentValue != currentValue;
  }
}