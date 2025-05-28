import 'package:flutter/material.dart';
import 'dart:math' as math;

class PipingSystem extends StatelessWidget {
  final double animationValue;
  final Color redFluid;
  final Color blueFluid;
  final Color pinkFluid;
  final Color purpleFluid;
  final double valvePosition;

  const PipingSystem({
    super.key,
    required this.animationValue,
    required this.redFluid,
    required this.blueFluid,
    required this.pinkFluid,
    required this.purpleFluid,
    required this.valvePosition,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, double.infinity),
      painter: PipingSystemPainter(
        animationValue: animationValue,
        redFluid: redFluid,
        blueFluid: blueFluid,
        pinkFluid: pinkFluid,
        purpleFluid: purpleFluid,
        valvePosition: valvePosition,
      ),
    );
  }
}

class PipingSystemPainter extends CustomPainter {
  final double animationValue;
  final Color redFluid;
  final Color blueFluid;
  final Color pinkFluid;
  final Color purpleFluid;
  final double valvePosition;

  PipingSystemPainter({
    required this.animationValue,
    required this.redFluid,
    required this.blueFluid,
    required this.pinkFluid,
    required this.purpleFluid,
    required this.valvePosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pipePaint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;
    
    // Main pipe paths
    //o/p of blue tank
    final path1 = Path()
      ..moveTo(1140, 200)
      ..lineTo(1140, 400)
      ..lineTo(1050, 400)
      ..lineTo(1050, 480)
      ..lineTo(950, 480)
      ..lineTo(950, 500)
      ..lineTo(600, 500)
      ..lineTo(500, 500)
      ..lineTo(500, 450);
    
    //o/p of red tank
    final path2 = Path()
      ..moveTo(935, 200)
      ..lineTo(935, 430)
      ..lineTo(935, 400)
      ..lineTo(800, 400)
      ..lineTo(800, 220)
      ..lineTo(600, 220)
      ..lineTo(500, 220)
      ..lineTo(500, 300);
    
    //chiller-heat-exchanger1
    final path3 = Path()
      ..moveTo(950, 500)
      ..lineTo(1140, 500)
      ..lineTo(1050, 500);
    
    //chiller-heat-exchanger2
    final path4 = Path()
      ..moveTo(1140, 520)
      ..lineTo(1050, 520)
      ..lineTo(950, 520);
    
    //op of homogenizer
    final path5 = Path()
      ..moveTo(150, 220)
      ..lineTo(150, 380);
    
    //chiller-tank1
    final path6 = Path()
      ..moveTo(1150, 50)
      ..lineTo(1150, 150);
    
    //tank1-chiller
    final path7 = Path()
      ..moveTo(1125, 150)
      ..lineTo(1125, 50);
    
    //chiller3-sshe2
    final path8 = Path()
      ..moveTo(175, 500)
      ..lineTo(175, 380);
    
    //sshe2-chiller3
    final path9 = Path()
      ..moveTo(125, 380)
      ..lineTo(125, 500);
    
    //valves mix
    final path10 = Path()
      ..moveTo(500, 300)
      ..lineTo(500, 450);
    
    //valves-homogenizer
    final path11 = Path()
      ..moveTo(500, 360)
      ..lineTo(300, 360)
      ..lineTo(300, 230)
      ..lineTo(200, 230);
    
    //sampling
    final path12 = Path()
      ..moveTo(600, 220)
      ..lineTo(600, 400);
    
    // Draw pipe outlines
    canvas.drawPath(path1, pipePaint);
    canvas.drawPath(path2, pipePaint);
    canvas.drawPath(path3, pipePaint);
    canvas.drawPath(path4, pipePaint);
    canvas.drawPath(path5, pipePaint);
    canvas.drawPath(path6, pipePaint);
    canvas.drawPath(path7, pipePaint);
    canvas.drawPath(path8, pipePaint);
    canvas.drawPath(path9, pipePaint);
    canvas.drawPath(path10, pipePaint);
    canvas.drawPath(path11, pipePaint);
    canvas.drawPath(path12, pipePaint);
    
    // Tank 1 output (blue)
    final fluidPaint1 = Paint()
      ..color = blueFluid
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path1, fluidPaint1);

    // Tank 2 output (red)
    final fluidPaint2 = Paint()
      ..color = redFluid
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round;

    // outlet fluid (pink)
    final fluidPaint3 = Paint()
      ..color = pinkFluid
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round;

    // mix fluid (purple)
    final fluidPaint4 = Paint()
      ..color = purpleFluid
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path2, fluidPaint2);
    canvas.drawPath(path3, fluidPaint1);
    canvas.drawPath(path4, fluidPaint1);
    canvas.drawPath(path5, fluidPaint3);
    canvas.drawPath(path6, fluidPaint1);
    canvas.drawPath(path7, fluidPaint1);
    canvas.drawPath(path8, fluidPaint3);
    canvas.drawPath(path9, fluidPaint3);
    canvas.drawPath(path10, fluidPaint4);
    canvas.drawPath(path11, fluidPaint4);
    canvas.drawPath(path12, fluidPaint2);

    // Draw flow animation (arrows)
    _drawFlowArrows(canvas, path1, blueFluid);
    _drawFlowArrows(canvas, path2, redFluid);
    _drawFlowArrows(canvas, path3, blueFluid);
    _drawFlowArrows(canvas, path4, blueFluid);
    _drawFlowArrows(canvas, path5, pinkFluid);
    _drawFlowArrows(canvas, path6, blueFluid);
    _drawFlowArrows(canvas, path7, blueFluid);
    _drawFlowArrows(canvas, path8, pinkFluid);
    _drawFlowArrows(canvas, path9, pinkFluid);
    _drawFlowArrows(canvas, path11, purpleFluid);
    _drawFlowArrows(canvas, path12, redFluid);
  }

  void _drawFlowArrows(Canvas canvas, Path pipePath, Color color) {
    final arrowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final pathMetrics = pipePath.computeMetrics().toList();
    for (var metric in pathMetrics) {
      // Place arrows along the path based on animation value
      for (double i = 0; i < 1.0; i += 0.2) {
        final position = (i + animationValue) % 1.0;
        final tangent = metric.getTangentForOffset(metric.length * position);

        if (tangent != null) {
          final arrowPath = Path();
          // Create arrow shape
          final angle = math.atan2(tangent.vector.dy, tangent.vector.dx);
          final arrowSize = 8.0;

          final point1 = Offset(
            tangent.position.dx - arrowSize * math.cos(angle - math.pi / 6),
            tangent.position.dy - arrowSize * math.sin(angle - math.pi / 6),
          );

          final point2 = Offset(
            tangent.position.dx - arrowSize * math.cos(angle + math.pi / 6),
            tangent.position.dy - arrowSize * math.sin(angle + math.pi / 6),
          );

          arrowPath.moveTo(tangent.position.dx, tangent.position.dy);
          arrowPath.lineTo(point1.dx, point1.dy);
          arrowPath.lineTo(point2.dx, point2.dy);
          arrowPath.close();

          canvas.drawPath(arrowPath, arrowPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant PipingSystemPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.valvePosition != valvePosition;
  }
}