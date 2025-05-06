import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(
    const MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: HomogenizerWrapper()),
      ),
    ),
  );
}

// Wrapper to handle animation controller (since Homogenizer needs it)
class HomogenizerWrapper extends StatefulWidget {
  const HomogenizerWrapper({Key? key}) : super(key: key);

  @override
  _HomogenizerWrapperState createState() => _HomogenizerWrapperState();
}

class _HomogenizerWrapperState extends State<HomogenizerWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(); // Loop forever
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Homogenizer(animation: _controller);
  }
}

// Your updated Homogenizer widget with rotating "X"
class Homogenizer extends StatelessWidget {
  final AnimationController animation;

  const Homogenizer({Key? key, required this.animation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[600],
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Homogenizer',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 60,
            height: 20,
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: CrossPainter(angle: animation.value * 2 * pi),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter to draw a rotating "X"
class CrossPainter extends CustomPainter {
  final double angle;

  CrossPainter({required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round;

    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(angle);

    final double length = min(size.width, size.height) / 2;

    // Draw an X (two lines intersecting)
    canvas.drawLine(Offset(-length, -length), Offset(length, length), paint);
    canvas.drawLine(Offset(length, -length), Offset(-length, length), paint);
  }

  @override
  bool shouldRepaint(CrossPainter oldDelegate) {
    return oldDelegate.angle != angle;
  }
}
