import 'package:flutter/material.dart';

class PipingSystem extends StatelessWidget {
  final AnimationController flowAnimation;

  const PipingSystem({Key? key, required this.flowAnimation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PipingPainter(flowAnimation: flowAnimation),
      size: Size.infinite,
    );
  }
}

class _PipingPainter extends CustomPainter {
  final Animation<double> flowAnimation;

  _PipingPainter({required AnimationController flowAnimation})
      : flowAnimation = Tween(begin: 0.0, end: 1.0).animate(flowAnimation),
        super(repaint: flowAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    // Implement your piping system painting logic here
    // (Same as in your original _buildPipingSystem method)
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}