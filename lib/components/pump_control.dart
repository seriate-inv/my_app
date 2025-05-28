import 'package:flutter/material.dart';
import 'dart:math' as math;

class PumpControl extends StatelessWidget {
  final int pumpNumber;
  final bool isActive;
  final ValueChanged<bool> onToggle;
  final double speed; // Value between 0.0 and 1.0 to represent the pump speed

  const PumpControl({
    super.key,
    required this.pumpNumber,
    required this.isActive,
    required this.onToggle,
    this.speed = 0.65, // Default speed value
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Pump number header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 3),
            color: Colors.grey[500],
            child: Text(
              'Pump $pumpNumber',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Black background for speedometer
          Container(
            width: 36,
            height: 32,
            padding: const EdgeInsets.all(2),
            margin: const EdgeInsets.only(top: 3, bottom: 2),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(3),
            ),
            child: SpeedometerWidget(value: speed),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Brown indicator
              StatusIndicator(
                color: const Color(0xFF8B4513), // Brown color
                isActive: !isActive,
                label: 'OFF',
                onTap: () => onToggle(false),
              ),
              const SizedBox(width: 8),
              // Green indicator
              StatusIndicator(
                color: Colors.green,
                isActive: isActive,
                label: 'ON',
                onTap: () => onToggle(true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatusIndicator extends StatelessWidget {
  final Color color;
  final bool isActive;
  final String label;
  final VoidCallback onTap;

  const StatusIndicator({
    super.key,
    required this.color,
    required this.isActive,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? color : Colors.grey[400],
              border: Border.all(color: Colors.black54, width: 2),
              boxShadow:
                  isActive
                      ? [
                        BoxShadow(
                          color: color.withOpacity(0.6),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                      : null,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.black87 : Colors.black54,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class SpeedometerWidget extends StatelessWidget {
  final double value; // 0.0 to 1.0

  const SpeedometerWidget({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, double.infinity),
      painter: SpeedometerPainter(value: value),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '${(value * 100).toInt()}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'SPEED',
            style: TextStyle(color: Colors.white70, fontSize: 6),
          ),
        ],
      ),
    );
  }
}

class SpeedometerPainter extends CustomPainter {
  final double value; // 0.0 to 1.0

  SpeedometerPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.85;

    // Draw the arc background
    final bgPaint =
        Paint()
          ..color = Colors.grey
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.8,
      math.pi * 1.4,
      false,
      bgPaint,
    );

    // Draw the value arc
    final valuePaint =
        Paint()
          ..shader = LinearGradient(
            colors: [Colors.blue, Colors.green, Colors.yellow, Colors.red],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.8,
      math.pi * 1.4 * value,
      false,
      valuePaint,
    );

    // Draw tick marks
    final tickPaint =
        Paint()
          ..color = Colors.white70
          ..strokeWidth = 1;

    for (int i = 0; i <= 2; i++) {
      final angle = math.pi * 0.8 + (math.pi * 1.4 * i / 2);
      final outerPoint = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      final innerPoint = Offset(
        center.dx + (radius - 2) * math.cos(angle),
        center.dy + (radius - 2) * math.sin(angle),
      );

      canvas.drawLine(innerPoint, outerPoint, tickPaint);
    }

    // Draw needle
    final needleAngle = math.pi * 0.8 + math.pi * 1.4 * value;
    final needlePaint =
        Paint()
          ..color = Colors.red
          ..strokeWidth = 1;

    final needlePoint = Offset(
      center.dx + (radius - 3) * math.cos(needleAngle),
      center.dy + (radius - 3) * math.sin(needleAngle),
    );

    canvas.drawLine(center, needlePoint, needlePaint);

    // Draw center circle
    final centerPaint = Paint()..color = Colors.white;

    canvas.drawCircle(center, 1.5, centerPaint);
  }

  @override
  bool shouldRepaint(covariant SpeedometerPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}

// Example of how to use this widget:
class PumpControlExample extends StatefulWidget {
  const PumpControlExample({super.key});

  @override
  State<PumpControlExample> createState() => _PumpControlExampleState();
}

class _PumpControlExampleState extends State<PumpControlExample> {
  bool isPumpActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: Center(
        child: PumpControl(
          pumpNumber: 1,
          isActive: isPumpActive,
          onToggle: (value) {
            setState(() {
              isPumpActive = value;
            });
          },
          speed: 0.65, // You can adjust this value (0.0 to 1.0)
        ),
      ),
    );
  }
}
