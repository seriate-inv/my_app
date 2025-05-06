import 'package:flutter/material.dart';
import 'dart:math' as math;

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

class FlowMeterPainter extends CustomPainter {
  final double currentValue;
  final double maxValue;
  
  FlowMeterPainter({required this.currentValue, required this.maxValue});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Draw ticks
    final tickPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
      
    for (int i = 0; i <= 6; i++) {
      final angle = math.pi * 1.25 + i * (math.pi * 0.75) / 6;
      final outerPoint = Offset(
        center.dx + (radius - 2) * math.cos(angle),
        center.dy + (radius - 2) * math.sin(angle),
      );
      final innerPoint = Offset(
        center.dx + (radius - 8) * math.cos(angle),
        center.dy + (radius - 8) * math.sin(angle),
      );
      canvas.drawLine(innerPoint, outerPoint, tickPaint);
      
      // Draw labels
      if (i % 2 == 0) {
        final value = (i * maxValue / 6).round();
        final textPainter = TextPainter(
          text: TextSpan(
            text: '$value',
            style: const TextStyle(color: Colors.black, fontSize: 7),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        final textPoint = Offset(
          center.dx + (radius - 14) * math.cos(angle) - textPainter.width / 2,
          center.dy + (radius - 14) * math.sin(angle) - textPainter.height / 2,
        );
        textPainter.paint(canvas, textPoint);
      }
    }
    
    // Draw needle
    final needlePaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
      
    final needleAngle = math.pi * 1.25 + (currentValue / maxValue) * (math.pi * 0.75);
    final needleLength = radius - 10;
    final needlePoint = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );
    
    canvas.drawLine(center, needlePoint, needlePaint);
    
    // Draw center circle
    canvas.drawCircle(center, 3, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant FlowMeterPainter oldDelegate) {
    return oldDelegate.currentValue != currentValue;
  }
}