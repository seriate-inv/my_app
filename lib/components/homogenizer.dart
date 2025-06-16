import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class HomogenizerService {
  static const String apiUrl = 'http://127.0.0.1:5000/api/temperature';

  Future<List<HomogenizerData>> fetchHomogenizerData() async {
    try {
      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 10));

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

  Future<void> postHomogenizerData({
    required int entryIndex,
    required double temperature,
    double speed = 0,
  }) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/api/homogenizer'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'temperature': temperature,
        'speed': speed,
        'entry_index': entryIndex,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to save homogenizer data: ${response.body}');
    }
  }

  postTI5DataToMySQL({required int entryIndex, required double temperature}) {}
}

class HomogenizerData {
  final DateTime time;
  final double speed;
  final double temperature;
  final int entryIndex;

  HomogenizerData({
    required this.time,
    required this.speed,
    required this.temperature,
    required this.entryIndex,
  });

  factory HomogenizerData.fromJson(Map<String, dynamic> json) {
    return HomogenizerData(
      time: DateTime.parse(json['time'] ?? DateTime.now().toIso8601String()),
      speed: (json['speed'] ?? 0).toDouble(),
      temperature: (json['temperature'] ?? 0).toDouble(),
      entryIndex: json['entry_index'] ?? 0,
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
  List<double> _temperatureValues = [];
  Map<int, double> _updatedValues =
      {}; // Stores updated temperature values by index

  // Mapping for TI to corresponding label (if needed)
  final Map<String, String> _temperatureMapping = {
    'TI15': 'TI15',
    'TI16': 'TI16',
    'TI17': 'TI17',
  };

  void _fetchAndShowTemperature(String label) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await HomogenizerService().fetchHomogenizerData();

      if (!mounted) return;

      setState(() {
        _temperatureValues = data.map((item) => item.temperature).toList();

        // 👇 Overlay updated values into TI16 when fetched
        if (label == 'TI16') {
          _updatedValues.forEach((index, value) {
            if (index >= 0 && index < _temperatureValues.length) {
              _temperatureValues[index] = value;
            }
          });
        }

        if (label == 'TI15') {
          // Clear old updates if you want fresh session every time:
          // _updatedValues.clear();
          // Or keep updates as is if you want to show in TI16
        }
      });

      _showTemperatureDialog(label);
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
          _isLoading = false;
        });
      }
    }
  }

  void _showTemperatureDialog(String label) {
    final isUpdatable = label == 'TI15';
    String? mappedLabel = _temperatureMapping[label];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Homogenizer - $label'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _temperatureValues.length,
                itemBuilder: (context, index) {
                  double valueToDisplay = _temperatureValues[index];

                  // ✅ If viewing TI16, override with updated TI15 values if they exist
                  if (label == 'TI16' && _updatedValues.containsKey(index)) {
                    valueToDisplay = _updatedValues[index]!;
                  }

                  if (isUpdatable) {
                    return Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: ListTile(
                            title: Text(
                              '${valueToDisplay.toStringAsFixed(2)} °C',
                            ),
                            trailing: TextButton(
                              onPressed: () => _showManualInputDialog(index),
                              child: const Text('Update'),
                            ),
                          ),
                        ),
                        const VerticalDivider(width: 1.5, color: Colors.black),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Text(
                              _updatedValues.containsKey(index)
                                  ? '${_updatedValues[index]!.toStringAsFixed(2)} °C'
                                  : '--',
                              style: TextStyle(
                                color:
                                    _updatedValues.containsKey(index)
                                        ? Colors.green
                                        : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return ListTile(
                      title: Text('${valueToDisplay.toStringAsFixed(2)} °C'),
                    );
                  }
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

  void _showManualInputDialog(int index) {
    TextEditingController controller = TextEditingController(
      text:
          _updatedValues.containsKey(index)
              ? _updatedValues[index]!.toStringAsFixed(2)
              : _temperatureValues[index].toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Update Temperature Value'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Enter new temperature (°C)',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final value = double.tryParse(controller.text);
                  if (value != null) {
                    setState(() {
                      _updatedValues[index] = value;
                    });
                    try {
                      await HomogenizerService().postHomogenizerData(
                        entryIndex: index,
                        temperature: value,
                      );
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Value updated and saved to database!'),
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to save: $e')),
                      );
                    }
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid number'),
                      ),
                    );
                  }
                },
                child: const Text('Save'),
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
            // TI15 Button (Updatable)
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
                  onTap: () => _fetchAndShowTemperature('TI15'),
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
            // TI16 Button (Read-only)
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
                  onTap: () => _fetchAndShowTemperature('TI16'),
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
            // TI17 Button (Read-only)
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
                  onTap: () => _fetchAndShowTemperature('TI17'),
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
        // Main Homogenizer Container
        Container(
          width: width * 0.9,
          height: width * 0.61,
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
                  fontSize: fontSize,
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

Future<void> _sendToDatabase(double tempValue) async {
  try {
    final url = Uri.parse('http://127.0.0.1:5000/api/homogenizer');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'temperature': tempValue,
        'speed': 0, // Optional, modify if you collect speed
      }),
    );

    if (response.statusCode == 201) {
      debugPrint('Data sent successfully');
    } else {
      debugPrint('Failed to send data: ${response.body}');
    }
  } catch (e) {
    debugPrint('Error sending to DB: $e');
  }
}

class FanPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    final Paint bladePaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    for (int i = 0; i < 3; i++) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(2 * pi * i / 3);
      Path blade =
          Path()
            ..moveTo(0, 0)
            ..lineTo(radius, -8)
            ..lineTo(radius, 8)
            ..close();
      canvas.drawPath(blade, bladePaint);
      canvas.restore();
    }

    final Paint centerPaint =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 5, centerPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
