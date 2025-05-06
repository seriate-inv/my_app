import 'package:flutter/material.dart';
import 'dart:math' as math;

class FlowMeter extends StatelessWidget {
  final double flowRate;

  const FlowMeter({Key? key, required this.flowRate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey, width: 1),
              ),
              child: CustomPaint(
                painter: FlowMeterPainter(currentValue: flowRate, maxValue: 30),
              ),
            ),
          ),
          const Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'FLOW',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                flowRate.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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