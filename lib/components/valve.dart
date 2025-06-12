import 'package:flutter/material.dart';
import 'package:my_app/temperature_service.dart';

class Valve extends StatefulWidget {
  final bool showTempButton;
  const Valve({super.key, this.showTempButton = false});

  @override
  State<Valve> createState() => _ValveState();
}

class _ValveState extends State<Valve> {
  bool _isLoadingT1 = false;
  bool _isLoadingT2 = false;
  bool _isLoadingT3 = false;
  String? _error;
  List<double> _temperatureValuesT1 = [];
  List<double> _temperatureValuesT2 = [];
  List<double> _temperatureValuesT3 = [];

  Future<void> _fetchTemperature(String type) async {
    setState(() {
      if (type == 'TI12') {
        _isLoadingT1 = true;
      } else if (type == 'TI13') {
        _isLoadingT2 = true;
      } else {
        _isLoadingT3 = true;
      }
      _error = null;
    });

    try {
      final data = await TemperatureService().fetchTemperatureData();

      if (!mounted) return;

      setState(() {
        if (type == 'TI12') {
          _temperatureValuesT1 = data.map((item) => item.temperature).toList();
        } else if (type == 'TI13') {
          _temperatureValuesT2 = data.map((item) => item.temperature).toList();
        } else {
          _temperatureValuesT3 = data.map((item) => item.temperature).toList();
        }
      });

      _showTemperatureDialog(type);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() {
          if (type == 'TI12') {
            _isLoadingT1 = false;
          } else if (type == 'TI13') {
            _isLoadingT2 = false;
          } else {
            _isLoadingT3 = false;
          }
        });
      }
    }
  }

  void _showTemperatureDialog(String type) {
    final values =
        type == 'TI12'
            ? _temperatureValuesT1
            : type == 'TI13'
            ? _temperatureValuesT2
            : _temperatureValuesT3;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('$type Temperature Readings'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: values.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('${values[index].toStringAsFixed(2)} °C'),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildTempButton(
    String label,
    VoidCallback onPressed,
    bool isLoading,
    Offset offset,
  ) {
    return Positioned(
      right: offset.dx,
      top: offset.dy,
      child: Container(
        width: 25, // Increased width to fit "TI12"
        height: 20,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 243, 244, 245),
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(4),
            child: Center(
              child:
                  isLoading
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.black,
                        ),
                      )
                      : Text(
                        label,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Original valve widget
        Transform.translate(
          offset: const Offset(15, 0),
          child: SizedBox(
            width: 30,
            height: 80, // Increased height to accommodate third button
            child: CustomPaint(painter: _ValveSymbolPainter()),
          ),
        ),

        if (widget.showTempButton) ...[
          _buildTempButton(
            'T12',
            () => _fetchTemperature('T12'),
            _isLoadingT1,
            const Offset(10, 5),
          ),
          _buildTempButton(
            'T13',
            () => _fetchTemperature('T13'),
            _isLoadingT2,
            const Offset(10, 35),
          ),
          _buildTempButton(
            'T14',
            () => _fetchTemperature('T14'),
            _isLoadingT3,
            const Offset(10, 65),
          ),
        ],
      ],
    );
  }
}

class _ValveSymbolPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color.fromARGB(255, 253, 253, 253)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final shiftX = 29.0;
    canvas.drawLine(
      Offset(shiftX, 0),
      Offset(size.width - shiftX, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - shiftX, 0),
      Offset(shiftX, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class NonReturningValve extends StatelessWidget {
  const NonReturningValve({super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, 10),
      child: SizedBox(
        width: 70,
        height: 25,
        child: CustomPaint(painter: _NonReturningValveSymbolPainter()),
      ),
    );
  }
}

class _NonReturningValveSymbolPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color.fromARGB(255, 255, 255, 255)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final triangleStartX = size.width * 0.3;
    final triangleEndX = size.width * 0.7;

    final trianglePath = Path();
    trianglePath.moveTo(triangleStartX, size.height / 2);
    trianglePath.lineTo(triangleEndX, 0);
    trianglePath.lineTo(triangleEndX, size.height);
    trianglePath.close();
    canvas.drawPath(trianglePath, paint);

    canvas.drawLine(
      Offset(size.width * 0.3, 0),
      Offset(size.width * 0.3, size.height),
      paint,
    );

    final centerY = size.height / 2;
    canvas.drawLine(Offset(0, centerY), Offset(triangleStartX, centerY), paint);
    canvas.drawLine(
      Offset(triangleEndX, centerY),
      Offset(size.width, centerY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
