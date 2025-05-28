import 'package:flutter/material.dart';
import 'dart:math' as math;

// Custom painters and widgets for industrial control components

class MixerPainter extends CustomPainter {
  final Color color;

  MixerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    // Draw mixer blades as a simple cross
    final center = Offset(size.width / 2, size.height / 2);

    // Horizontal blade
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center,
          width: size.width - 0.5 * size.width,
          height: 3,
        ),
        const Radius.circular(5),
      ),
      paint,
    );

    // Vertical blade
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center,
          width: 3,
          height: size.height - 0.5 * size.height,
        ),
        const Radius.circular(5),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
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
    final backgroundPaint =
        Paint()
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
    final valuePaint =
        Paint()
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
    final needlePaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    final needleAngle =
        math.pi * 0.75 + (currentValue / maxValue) * math.pi * 1.5;
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
      center.dx +
          (radius - 2) * math.cos(math.pi * 0.75) -
          minPainter.width / 2,
      center.dy +
          (radius - 2) * math.sin(math.pi * 0.75) -
          minPainter.height / 2,
    );
    minPainter.paint(canvas, minPoint);

    final maxPainter = TextPainter(
      text: TextSpan(
        text: '${maxValue.toInt()}',
        style: const TextStyle(color: Colors.white, fontSize: 8),
      ),
      textDirection: TextDirection.ltr,
    );

    maxPainter.layout();
    final maxPoint = Offset(
      center.dx +
          (radius - 2) * math.cos(math.pi * 0.75 + math.pi * 1.5) -
          maxPainter.width / 2,
      center.dy +
          (radius - 2) * math.sin(math.pi * 0.75 + math.pi * 1.5) -
          maxPainter.height / 2,
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
    final tickPaint =
        Paint()
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
    final needlePaint =
        Paint()
          ..color = Colors.red
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    final needleAngle =
        math.pi * 1.25 + (currentValue / maxValue) * (math.pi * 0.75);
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

class _NonReturningValveSymbolPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
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

// Widget functions for creating components

Widget buildTank({
  required Color color,
  required AnimationController mixerAnimation,
  required double fillLevel,
  required BuildContext context,
}) {
  final size = MediaQuery.of(context).size;
  final isSmallScreen = size.width < 600;

  return SizedBox(
    width: isSmallScreen ? 80 : 100,
    height: isSmallScreen ? 120 : 150,
    child: Stack(
      children: [
        // Tank outline
        Container(
          width: isSmallScreen ? 70 : 90,
          height: isSmallScreen ? 120 : 150,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            border: Border.all(color: Colors.black, width: 3),
            borderRadius: BorderRadius.circular(10),
          ),
        ),

        // Fluid in tank
        Positioned(
          bottom: 0,
          child: Container(
            width: isSmallScreen ? 70 : 90,
            height: (isSmallScreen ? 120 : 150) * fillLevel,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.only(
                bottomLeft: const Radius.circular(8),
                bottomRight: const Radius.circular(8),
                topLeft: Radius.circular(fillLevel > 0.95 ? 8 : 0),
                topRight: Radius.circular(fillLevel > 0.95 ? 8 : 0),
              ),
            ),
          ),
        ),

        // Level indicator
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: Container(
            width: 5,
            height: isSmallScreen ? 120 : 150,
            color: Colors.grey[900],
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 5,
                height: (isSmallScreen ? 120 : 150) * fillLevel,
                color: Colors.lightGreenAccent,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buildHeatExchanger(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final isSmallScreen = size.width < 600;

  return Container(
    width: isSmallScreen ? 80 : 100,
    height: isSmallScreen ? 50 : 60,
    decoration: BoxDecoration(
      color: Colors.grey[600],
      border: Border.all(color: Colors.black),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Heat Exchanger',
          style: TextStyle(
            color: const Color.fromARGB(255, 250, 250, 250),
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 7 : 9,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: isSmallScreen ? 50 : 60,
          height: 5,
          color: Colors.blue,
          alignment: Alignment.center,
        ),
        const SizedBox(height: 4),
        Container(
          width: isSmallScreen ? 50 : 60,
          height: 5,
          color: Colors.red,
          alignment: Alignment.center,
        ),
      ],
    ),
  );
}

Widget buildValve(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final isSmallScreen = size.width < 600;

  return Container(
    width: isSmallScreen ? 50 : 60,
    height: isSmallScreen ? 80 : 100,
    decoration: BoxDecoration(
      color: Colors.grey[600],
      border: Border.all(color: Colors.black),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Valve',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 7 : 9,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: isSmallScreen ? 25 : 30,
          height: isSmallScreen ? 40 : 50,
          child: CustomPaint(painter: CustomPainterWithRectAndDiagonals()),
        ),
      ],
    ),
  );
}

Widget buildNonReturningValve(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final isSmallScreen = size.width < 600;

  return Container(
    width: isSmallScreen ? 80 : 100,
    height: isSmallScreen ? 50 : 60,
    decoration: BoxDecoration(
      color: Colors.grey[600],
      border: Border.all(color: Colors.black),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Non-returning Val',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 7 : 9,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: isSmallScreen ? 50 : 60,
          height: isSmallScreen ? 15 : 20,
          child: CustomPaint(painter: _NonReturningValveSymbolPainter()),
        ),
      ],
    ),
  );
}

Widget buildChiller(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final isSmallScreen = size.width < 600;

  return Container(
    width: isSmallScreen ? 80 : 100,
    height: isSmallScreen ? 50 : 60,
    decoration: BoxDecoration(
      color: Colors.grey[600],
      border: Border.all(color: Colors.black),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Chiller',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 7 : 9,
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: isSmallScreen ? 60 : 70,
          height: isSmallScreen ? 20 : 25,
          color: Colors.blue,
          alignment: Alignment.center,
        ),
      ],
    ),
  );
}

Widget buildHeatingCoil(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final isSmallScreen = size.width < 600;

  return Container(
    width: isSmallScreen ? 80 : 100,
    height: isSmallScreen ? 50 : 60,
    decoration: BoxDecoration(
      color: Colors.grey[600],
      border: Border.all(color: Colors.black),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Heating Coil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 7 : 9,
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: isSmallScreen ? 60 : 70,
          height: isSmallScreen ? 20 : 25,
          color: Colors.red,
          alignment: Alignment.center,
        ),
      ],
    ),
  );
}

Widget buildHomogenizer(
  AnimationController homogenizerAnimation,
  BuildContext context,
) {
  final size = MediaQuery.of(context).size;
  final isSmallScreen = size.width < 600;

  return Container(
    width: isSmallScreen ? 80 : 100,
    height: isSmallScreen ? 50 : 60,
    decoration: BoxDecoration(
      color: Colors.grey[600],
      border: Border.all(color: Colors.black),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Homogenizer',
          style: TextStyle(
            color: const Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 7 : 9,
          ),
        ),
        const SizedBox(height: 5),
        AnimatedBuilder(
          animation: homogenizerAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: homogenizerAnimation.value * 2 * math.pi,
              child: SizedBox(
                width: isSmallScreen ? 30 : 40,
                height: isSmallScreen ? 30 : 40,
                child: CustomPaint(painter: MixerPainter(color: Colors.lime)),
              ),
            );
          },
        ),
      ],
    ),
  );
}

Widget buildPumpControl(int pumpNumber, bool isActive, BuildContext context) {
  final size = MediaQuery.of(context).size;
  final isSmallScreen = size.width < 600;

  return Container(
    width: isSmallScreen ? 80 : 100,
    height: isSmallScreen ? 60 : 80,
    decoration: BoxDecoration(
      color: Colors.grey[800],
      border: Border.all(color: Colors.black),
      borderRadius: BorderRadius.circular(3),
    ),
    child: Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.grey[700],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(2),
              topRight: Radius.circular(2),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            'Pump $pumpNumber',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 8 : 10,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Container(
              width: isSmallScreen ? 50 : 70,
              height: isSmallScreen ? 20 : 30,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(3),
              ),
              child: CustomPaint(
                painter: PumpGaugePainter(
                  currentValue: pumpNumber == 1 ? 42 : 27,
                  maxValue: 60,
                ),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildIndicatorLight(Colors.red, !isActive, isSmallScreen),
            buildIndicatorLight(Colors.green, isActive, isSmallScreen),
          ],
        ),
        const SizedBox(height: 5),
      ],
    ),
  );
}

Widget buildIndicatorLight(Color color, bool isOn, bool isSmallScreen) {
  return Container(
    width: isSmallScreen ? 20 : 25,
    height: isSmallScreen ? 20 : 25,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: isOn ? color : color.withOpacity(0.3),
      border: Border.all(color: Colors.black, width: 2),
      boxShadow:
          isOn
              ? [
                BoxShadow(
                  color: color.withOpacity(0.6),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
              : null,
    ),
  );
}

Widget buildFlowMeter(double flowRate, BuildContext context) {
  final size = MediaQuery.of(context).size;
  final isSmallScreen = size.width < 600;

  return Container(
    width: isSmallScreen ? 50 : 70,
    height: isSmallScreen ? 50 : 70,
    decoration: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.black, width: 2),
    ),
    child: Stack(
      children: [
        Center(
          child: Container(
            width: isSmallScreen ? 40 : 60,
            height: isSmallScreen ? 40 : 60,
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
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'FLOW',
              style: TextStyle(
                fontSize: isSmallScreen ? 8 : 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              flowRate.toStringAsFixed(1),
              style: TextStyle(
                fontSize: isSmallScreen ? 8 : 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buildStopButton(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final isSmallScreen = size.width < 600;

  return GestureDetector(
    onTap: () {
      // Handle stop functionality
    },
    child: Container(
      width: isSmallScreen ? 100 : 140,
      height: isSmallScreen ? 50 : 70,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Center(
        child: Text(
          'STOP',
          style: TextStyle(
            color: Colors.black,
            fontSize: isSmallScreen ? 20 : 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}

Widget buildTankStatusWidget(
  String title,
  Map<String, dynamic> data,
  BuildContext context,
) {
  final size = MediaQuery.of(context).size;
  final isSmallScreen = size.width < 600;

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 2),
    color: Colors.grey[850],
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          width: double.infinity,
          color: Colors.black,
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 10 : 12,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            children: [
              buildStatusRow(
                'Temperature:',
                '${data['temperature']} °C',
                isSmallScreen,
              ),
              buildStatusRow(
                'Flow Rate:',
                '${data['flowRate']} l/s',
                isSmallScreen,
              ),
              buildStatusRow('Level:', '${data['level']}%', isSmallScreen),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget buildStatusRow(String label, String value, bool isSmallScreen) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(color: Colors.white, fontSize: isSmallScreen ? 8 : 10),
      ),
      Text(
        value,
        style: TextStyle(color: Colors.white, fontSize: isSmallScreen ? 8 : 10),
      ),
    ],
  );
}

Widget buildValveControl(
  double valvePosition,
  Function(double) onValvePositionChanged,
  BuildContext context,
) {
  final size = MediaQuery.of(context).size;
  final isSmallScreen = size.width < 600;

  return Column(
    children: [
      Text(
        'VALVE CONTROL',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: isSmallScreen ? 10 : 12,
        ),
      ),
      const SizedBox(height: 5),
      Container(
        width: isSmallScreen ? 60 : 80,
        height: isSmallScreen ? 30 : 40,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                onValvePositionChanged(math.max(0, valvePosition - 5));
              },
              child: Container(
                width: isSmallScreen ? 20 : 30,
                height: isSmallScreen ? 20 : 30,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: isSmallScreen ? 14 : 18,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                onValvePositionChanged(math.min(100, valvePosition + 5));
              },
              child: Container(
                width: isSmallScreen ? 20 : 30,
                height: isSmallScreen ? 20 : 30,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: isSmallScreen ? 14 : 18,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

// Example usage in a responsive layout
class IndustrialControlPanel extends StatefulWidget {
  const IndustrialControlPanel({super.key});

  @override
  State<IndustrialControlPanel> createState() => _IndustrialControlPanelState();
}

class _IndustrialControlPanelState extends State<IndustrialControlPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _mixerAnimationController;
  late AnimationController _homogenizerAnimationController;
  double _valvePosition = 50;
  final double _flowRate = 15.5;
  final bool _pump1Active = true;
  final bool _pump2Active = false;

  @override
  void initState() {
    super.initState();
    _mixerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _homogenizerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
  }

  @override
  void dispose() {
    _mixerAnimationController.dispose();
    _homogenizerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final isPortrait = size.height > size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Industrial Control Panel'),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Container(
        color: Colors.grey[900],
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child:
              isSmallScreen || isPortrait
                  ? _buildMobileLayout()
                  : _buildDesktopLayout(),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Top row with tanks
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildTank(
              color: Colors.blue,
              mixerAnimation: _mixerAnimationController,
              fillLevel: 0.75,
              context: context,
            ),
            buildTank(
              color: Colors.green,
              mixerAnimation: _mixerAnimationController,
              fillLevel: 0.45,
              context: context,
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Middle row with controls
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildPumpControl(1, _pump1Active, context),
            buildPumpControl(2, _pump2Active, context),
            buildFlowMeter(_flowRate, context),
          ],
        ),

        const SizedBox(height: 10),

        // Valve control and stop button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildValveControl(_valvePosition, (value) {
              setState(() {
                _valvePosition = value;
              });
            }, context),
            buildStopButton(context),
          ],
        ),

        const SizedBox(height: 10),

        // Equipment row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              buildHeatExchanger(context),
              const SizedBox(width: 10),
              buildValve(context),
              const SizedBox(width: 10),
              buildNonReturningValve(context),
              const SizedBox(width: 10),
              buildChiller(context),
              const SizedBox(width: 10),
              buildHeatingCoil(context),
              const SizedBox(width: 10),
              buildHomogenizer(_homogenizerAnimationController, context),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Status widgets
        Column(
          children: [
            buildTankStatusWidget('Tank 1 Status', {
              'temperature': 45.2,
              'flowRate': 12.5,
              'level': 75,
            }, context),
            const SizedBox(height: 5),
            buildTankStatusWidget('Tank 2 Status', {
              'temperature': 32.7,
              'flowRate': 8.3,
              'level': 45,
            }, context),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      children: [
        // Top section with tanks and controls
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column with tanks
            Column(
              children: [
                buildTank(
                  color: Colors.blue,
                  mixerAnimation: _mixerAnimationController,
                  fillLevel: 0.75,
                  context: context,
                ),
                const SizedBox(height: 20),
                buildTank(
                  color: Colors.green,
                  mixerAnimation: _mixerAnimationController,
                  fillLevel: 0.45,
                  context: context,
                ),
              ],
            ),

            const SizedBox(width: 20),

            // Center column with controls
            Column(
              children: [
                Row(
                  children: [
                    buildPumpControl(1, _pump1Active, context),
                    const SizedBox(width: 10),
                    buildPumpControl(2, _pump2Active, context),
                  ],
                ),
                const SizedBox(height: 20),
                buildFlowMeter(_flowRate, context),
                const SizedBox(height: 20),
                buildValveControl(_valvePosition, (value) {
                  setState(() {
                    _valvePosition = value;
                  });
                }, context),
              ],
            ),

            const SizedBox(width: 20),

            // Right column with status and stop button
            Column(
              children: [
                buildTankStatusWidget('Tank 1 Status', {
                  'temperature': 45.2,
                  'flowRate': 12.5,
                  'level': 75,
                }, context),
                const SizedBox(height: 10),
                buildTankStatusWidget('Tank 2 Status', {
                  'temperature': 32.7,
                  'flowRate': 8.3,
                  'level': 45,
                }, context),
                const SizedBox(height: 20),
                buildStopButton(context),
              ],
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Equipment row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              buildHeatExchanger(context),
              const SizedBox(width: 10),
              buildValve(context),
              const SizedBox(width: 10),
              buildNonReturningValve(context),
              const SizedBox(width: 10),
              buildChiller(context),
              const SizedBox(width: 10),
              buildHeatingCoil(context),
              const SizedBox(width: 10),
              buildHomogenizer(_homogenizerAnimationController, context),
            ],
          ),
        ),
      ],
    );
  }
}
