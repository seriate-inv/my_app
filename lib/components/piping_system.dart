import 'package:flutter/material.dart';
import 'dart:math' as math;

class PipingSystemPainter extends CustomPainter {
  final double animationValue;
  final Color redFluid;
  final Color blueFluid;
  final Color pinkFluid;
  final Color purpleFluid;
  final double valvePosition;
  
  // Optional parameters to control flow rates
  final double blueFlowRate;
  final double redFlowRate;
  final double pinkFlowRate;
  final double purpleFlowRate;
  
  // Optional parameter to disable specific paths
  final Map<String, bool> activePaths;

  PipingSystemPainter({
    required this.animationValue,
    required this.redFluid,
    required this.blueFluid,
    required this.pinkFluid,
    required this.purpleFluid,
    required this.valvePosition,
    this.blueFlowRate = 1.0,
    this.redFlowRate = 1.0,
    this.pinkFlowRate = 1.0,
    this.purpleFlowRate = 1.0,
    this.activePaths = const {
      'tank1Output': true,
      'tank2Output': true,
      'chillerHeatExchanger1': true,
      'chillerHeatExchanger2': true,
      'homogenizerOutput': true,
      'chillerTank1': true,
      'tank1Chiller': true,
      'chillerSshe2': true,
      'sshe2Chiller': true,
      'valvesMix': true,
      'valvesHomogenizer': true,
      'sampling': true,
    },
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Define pipe style
    final pipePaint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;

    // Main pipe paths
    final Map<String, Path> paths = {
      // Output of blue tank (tank1)
      'tank1Output': Path()
        ..moveTo(1140, 200)
        ..lineTo(1140, 400)
        ..lineTo(1050, 400)
        ..lineTo(1050, 480)
        ..lineTo(950, 480)
        ..lineTo(950, 500)
        ..lineTo(600, 500)
        ..lineTo(500, 500)
        ..lineTo(500, 450),
      
      // Output of red tank (tank2)
      'tank2Output': Path()
        ..moveTo(935, 200)
        ..lineTo(935, 430)
        ..lineTo(935, 400)
        ..lineTo(800, 400)
        ..lineTo(800, 220)
        ..lineTo(600, 220)
        ..lineTo(500, 220)
        ..lineTo(500, 300),
      
      // Chiller-heat-exchanger1
      'chillerHeatExchanger1': Path()
        ..moveTo(950, 500)
        ..lineTo(1140, 500)
        ..lineTo(1050, 500),
      
      // Chiller-heat-exchanger2
      'chillerHeatExchanger2': Path()
        ..moveTo(1140, 520)
        ..lineTo(1050, 520)
        ..lineTo(950, 520),
      
      // Output of homogenizer
      'homogenizerOutput': Path()
        ..moveTo(150, 220)
        ..lineTo(150, 380),
      
      // Chiller-tank1
      'chillerTank1': Path()
        ..moveTo(1150, 50)
        ..lineTo(1150, 150),
      
      // Tank1-chiller
      'tank1Chiller': Path()
        ..moveTo(1125, 150)
        ..lineTo(1125, 50),
      
      // Chiller3-sshe2
      'chillerSshe2': Path()
        ..moveTo(175, 500)
        ..lineTo(175, 380),
      
      // Sshe2-chiller3
      'sshe2Chiller': Path()
        ..moveTo(125, 380)
        ..lineTo(125, 500),
      
      // Valves mix
      'valvesMix': Path()
        ..moveTo(500, 300)
        ..lineTo(500, 450),
      
      // Valves-homogenizer
      'valvesHomogenizer': Path()
        ..moveTo(500, 360)
        ..lineTo(300, 360)
        ..lineTo(300, 230)
        ..lineTo(200, 230),
      
      // Sampling
      'sampling': Path()
        ..moveTo(600, 220)
        ..lineTo(600, 400),
    };

    // Define fluid paint styles
    final Map<String, Paint> fluidPaints = {
      'blue': Paint()
        ..color = blueFluid
        ..style = PaintingStyle.stroke
        ..strokeWidth = 11
        ..strokeCap = StrokeCap.round,
      
      'red': Paint()
        ..color = redFluid
        ..style = PaintingStyle.stroke
        ..strokeWidth = 11
        ..strokeCap = StrokeCap.round,
      
      'pink': Paint()
        ..color = pinkFluid
        ..style = PaintingStyle.stroke
        ..strokeWidth = 11
        ..strokeCap = StrokeCap.round,
      
      'purple': Paint()
        ..color = purpleFluid
        ..style = PaintingStyle.stroke
        ..strokeWidth = 11
        ..strokeCap = StrokeCap.round,
    };

    // Path-to-fluid mapping
    final Map<String, String> pathFluidMap = {
      'tank1Output': 'blue',
      'tank2Output': 'red',
      'chillerHeatExchanger1': 'blue',
      'chillerHeatExchanger2': 'blue',
      'homogenizerOutput': 'pink',
      'chillerTank1': 'blue',
      'tank1Chiller': 'blue',
      'chillerSshe2': 'pink',
      'sshe2Chiller': 'pink',
      'valvesMix': 'purple',
      'valvesHomogenizer': 'purple',
      'sampling': 'red',
    };

    // Flow rate mapping
    final Map<String, double> fluidFlowRateMap = {
      'blue': blueFlowRate,
      'red': redFlowRate,
      'pink': pinkFlowRate,
      'purple': purpleFlowRate,
    };

    // Draw pipe outlines for active paths
    paths.forEach((pathName, path) {
      if (activePaths[pathName] == true) {
        canvas.drawPath(path, pipePaint);
      }
    });

    // Draw fluid inside pipes for active paths
    paths.forEach((pathName, path) {
      if (activePaths[pathName] == true) {
        final fluidType = pathFluidMap[pathName];
        if (fluidType != null) {
          canvas.drawPath(path, fluidPaints[fluidType]!);
        }
      }
    });

    // Draw flow arrows for active paths
    paths.forEach((pathName, path) {
      if (activePaths[pathName] == true) {
        final fluidType = pathFluidMap[pathName];
        if (fluidType != null) {
          final fluidColor = fluidPaints[fluidType]!.color;
          final flowRate = fluidFlowRateMap[fluidType] ?? 1.0;
          _drawFlowArrows(canvas, path, fluidColor, flowRate);
        }
      }
    });
  }

  void _drawFlowArrows(Canvas canvas, Path pipePath, Color color, double flowRate) {
    final arrowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final pathMetrics = pipePath.computeMetrics().toList();
    
    for (var metric in pathMetrics) {
      // Adjust arrow spacing based on flow rate
      final arrowSpacing = 0.2 / flowRate;
      // Make animation speed proportional to flow rate
      final adjustedAnimationValue = (animationValue * flowRate) % 1.0;
      
      // Place arrows along the path based on animation value
      for (double i = 0; i < 1.0; i += arrowSpacing) {
        final position = (i + adjustedAnimationValue) % 1.0;
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
        oldDelegate.valvePosition != valvePosition ||
        oldDelegate.blueFlowRate != blueFlowRate ||
        oldDelegate.redFlowRate != redFlowRate ||
        oldDelegate.pinkFlowRate != pinkFlowRate ||
        oldDelegate.purpleFlowRate != purpleFlowRate ||
        oldDelegate.blueFluid != blueFluid ||
        oldDelegate.redFluid != redFluid ||
        oldDelegate.pinkFluid != pinkFluid ||
        oldDelegate.purpleFluid != purpleFluid ||
        _mapsDiffer(oldDelegate.activePaths, activePaths);
  }

  bool _mapsDiffer(Map<String, bool> map1, Map<String, bool> map2) {
    if (map1.length != map2.length) return true;
    
    for (final key in map1.keys) {
      if (map1[key] != map2[key]) return true;
    }
    
    return false;
  }
}

// Class for a reusable piping system widget
class PipingSystem extends StatelessWidget {
  final Animation<double> flowAnimation;
  final Color redFluid;
  final Color blueFluid;
  final Color pinkFluid;
  final Color purpleFluid;
  final double valvePosition;
  final double blueFlowRate;
  final double redFlowRate;
  final double pinkFlowRate;
  final double purpleFlowRate;
  final Map<String, bool> activePaths;
  final Size? size;

  const PipingSystem({
    super.key,
    required this.flowAnimation,
    required this.redFluid,
    required this.blueFluid,
    required this.pinkFluid,
    required this.purpleFluid,
    required this.valvePosition,
    this.blueFlowRate = 1.0,
    this.redFlowRate = 1.0,
    this.pinkFlowRate = 1.0,
    this.purpleFlowRate = 1.0,
    this.size,
    this.activePaths = const {
      'tank1Output': true,
      'tank2Output': true,
      'chillerHeatExchanger1': true,
      'chillerHeatExchanger2': true,
      'homogenizerOutput': true,
      'chillerTank1': true,
      'tank1Chiller': true,
      'chillerSshe2': true,
      'sshe2Chiller': true,
      'valvesMix': true,
      'valvesHomogenizer': true,
      'sampling': true,
    },
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: flowAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: size ?? const Size(double.infinity, double.infinity),
          painter: PipingSystemPainter(
            animationValue: flowAnimation.value,
            redFluid: redFluid,
            blueFluid: blueFluid,
            pinkFluid: pinkFluid,
            purpleFluid: purpleFluid,
            valvePosition: valvePosition / 100,
            blueFlowRate: blueFlowRate,
            redFlowRate: redFlowRate,
            pinkFlowRate: pinkFlowRate,
            purpleFlowRate: purpleFlowRate,
            activePaths: activePaths,
          ),
        );
      },
    );
  }
}

// Sample usage:
// PipingSystem(
//   flowAnimation: _flowAnimation,
//   redFluid: Colors.red,
//   blueFluid: Colors.blue,
//   pinkFluid: Colors.pink,
//   purpleFluid: Colors.purple,
//   valvePosition: 50.0,
// )
