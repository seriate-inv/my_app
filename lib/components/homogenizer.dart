import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class HomogenizerService {
  static const String apiUrl = 'http://127.0.0.1:5000/api/homogenizer';

  Future<List<HomogenizerData>> fetchHomogenizerData() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => HomogenizerData.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load homogenizer data: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }
}

class HomogenizerData {
  final DateTime time;
  final double speed;
  final double temperature;

  HomogenizerData({
    required this.time,
    required this.speed,
    required this.temperature,
  });

  factory HomogenizerData.fromJson(Map<String, dynamic> json) {
    return HomogenizerData(
      time: DateTime.parse(json['time']),
      speed: (json['speed'] ?? 0).toDouble(),
      temperature: (json['temperature'] ?? 0).toDouble(),
    );
  }
}

class Homogenizer extends StatefulWidget {
  final AnimationController animation;
  const Homogenizer({super.key, required this.animation});

  @override
  State<Homogenizer> createState() => _HomogenizerState();
}

class _HomogenizerState extends State<Homogenizer> {
  bool _isLoading = false;
  String? _error;
  List<double> _tempValues = [];

  Future<void> _fetchAndShowData(BuildContext context, String title) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await HomogenizerService().fetchHomogenizerData();

      if (!mounted) return;

      setState(() {
        _tempValues = data.map((item) => item.temperature).toList();
      });

      _showDataDialog(context, title);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showDataDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$title Readings'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _tempValues.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                  'Temp: ${_tempValues[index].toStringAsFixed(2)} °C',
                ),
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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final containerWidth = screenSize.width * 0.25;
    final double minWidth = 50;
    final double maxWidth = 120;
    final width = containerWidth.clamp(minWidth, maxWidth);
    final fontSize = width * 0.12;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TI15 Button
            Container(
              width: width * 0.3,
              height: width * 0.2,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 243, 244, 245),
                border: Border.all(color: Colors.black),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _fetchAndShowData(context, 'TI15'),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(5),
                  ),
                  child: Center(
                    child: Text(
                      'TI15',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize * 0.8,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // TI16 Button
            Container(
              width: width * 0.3,
              height: width * 0.2,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 243, 244, 245),
                border: Border.all(color: Colors.black),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _fetchAndShowData(context, 'TI16'),
                  child: Center(
                    child: Text(
                      'TI16',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize * 0.8,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // TI17 Button
            Container(
              width: width * 0.3,
              height: width * 0.2,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 243, 244, 245),
                border: Border.all(color: Colors.black),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(5),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _fetchAndShowData(context, 'TI17'),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(5),
                    bottomRight: Radius.circular(5),
                  ),
                  child: Center(
                    child: Text(
                      'TI17',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize * 0.8,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Container(
          width: width * 0.7,
          height: width * 0.6,
          decoration: BoxDecoration(
            color: Colors.grey[600],
            border: Border.all(color: Colors.black),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(5),
              bottomRight: Radius.circular(5),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Homogenizer',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 40,
                height: 40,
                child: AnimatedBuilder(
                  animation: widget.animation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: widget.animation.value * 2 * pi,
                      child: CustomPaint(painter: FanPainter()),
                    );
                  },
                ),
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              else if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Error',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize * 0.4,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class FanPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    final Paint bladePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 3; i++) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(2 * pi * i / 3);
      Path blade = Path()
        ..moveTo(0, 0)
        ..lineTo(radius, -8)
        ..lineTo(radius, 8)
        ..close();
      canvas.drawPath(blade, bladePaint);
      canvas.restore();
    }

    final Paint centerPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 5, centerPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}