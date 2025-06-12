import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TankService {
  static const String apiUrl = 'http://127.0.0.1:5000/api/tank';

  Future<List<TankData>> fetchTankData() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => TankData.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load tank data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }
}

class TankData {
  final DateTime time;
  final double temperature;

  TankData({required this.time, required this.temperature});

  factory TankData.fromJson(Map<String, dynamic> json) {
    return TankData(
      time: DateTime.parse(json['time']),
      temperature: (json['temperature'] ?? 0).toDouble(),
    );
  }
}

class Tank extends StatefulWidget {
  final Color color;
  final AnimationController mixerAnimation;
  final double fillLevel;
  final bool showTemperatureButtons;
  final List<String> leftColumnLabels;
  final List<String> rightColumnLabels;
  final Map<String, Offset> temperatureButtonOffsets;
  final double buttonSpacing;

  const Tank({
    super.key,
    required this.color,
    required this.mixerAnimation,
    required this.fillLevel,
    this.showTemperatureButtons = true,
    this.leftColumnLabels = const [],
    this.rightColumnLabels = const [],
    this.temperatureButtonOffsets = const {},
    this.buttonSpacing = 20.0,
  });

  @override
  _TankState createState() => _TankState();
}

class _TankState extends State<Tank> {
  bool _isLoading = false;
  String? _error;
  List<double> _tempValues = [];
  String _currentLabel = "";

  Map<String, double> _latestValue = {};
  Map<String, String> _mappedLabels = {
    'TI1': 'TI2',
    'TI7': 'TI9',
    'TI15': 'TI16',
    'TI22': 'TI21',
    'TC': 'TH',
  };

  Map<String, String> _reverseMappedLabels = {
    'TI2': 'TI1',
    'TI9': 'TI7',
    'TI16': 'TI15',
    'TI21': 'TI22',
    'TH': 'TC',
  };

  Future<void> _fetchTemperature(String label) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _currentLabel = label;
    });

    try {
      final data = await TankService().fetchTankData();
      if (!mounted) return;

      setState(() {
        _tempValues = data.map((item) => item.temperature).toList();
      });

      _showTemperatureDialog(label);
    } catch (e) {
      setState(() => _error = e.toString());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching $label temperature: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showTemperatureDialog(String label) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('$label Tank Temperature Readings'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _tempValues.length,
                itemBuilder: (context, index) {
                  final original = _tempValues[index];
                  return ListTile(
                    title: Text('Original: ${original.toStringAsFixed(2)} °C'),
                    trailing: ElevatedButton(
                      child: const Text('Update'),
                      onPressed: () {
                        _updateTemperature(label, original);
                        Navigator.of(context).pop();
                      },
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

  void _updateTemperature(String label, double originalTemp) {
    final mapped = _mappedLabels[label];
    if (mapped != null) {
      setState(() {
        _latestValue[mapped] = originalTemp + 3.0; // simulate updated value
      });
    }
  }

  String? _getMappedDisplay(String label) {
    if (_reverseMappedLabels.containsKey(label)) {
      final source = _reverseMappedLabels[label]!;
      final updated = _latestValue[label];
      if (updated != null) {
        return '${source}: ${updated.toStringAsFixed(2)} °C';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 60,
            child: Container(
              width: 90,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                border: Border.all(color: Colors.black, width: 3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Positioned(
            left: 60,
            bottom: 0,
            child: Container(
              width: 90,
              height: 150 * widget.fillLevel,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.only(
                  bottomLeft: const Radius.circular(8),
                  bottomRight: const Radius.circular(8),
                  topLeft: Radius.circular(widget.fillLevel > 0.95 ? 8 : 0),
                  topRight: Radius.circular(widget.fillLevel > 0.95 ? 8 : 0),
                ),
              ),
            ),
          ),
          Positioned(
            left: 60 + 85,
            top: 0,
            bottom: 0,
            child: Container(
              width: 5,
              height: 150,
              color: Colors.grey[900],
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 5,
                  height: 150 * widget.fillLevel,
                  color: Colors.lightGreenAccent,
                ),
              ),
            ),
          ),
          if (widget.showTemperatureButtons) ...[
            Positioned(
              top: 28,
              left: 10,
              child: SizedBox(
                width: 50,
                child: Column(
                  children: [
                    for (var label in widget.leftColumnLabels)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 76),
                        child: _buildTemperatureButton(label: label),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 28,
              right: 10,
              child: SizedBox(
                width: 50,
                child: Column(
                  children: [
                    for (var label in widget.rightColumnLabels)
                      if (label.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 76),
                          child: _buildTemperatureButton(label: label),
                        ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTemperatureButton({required String label}) {
    final mappedDisplay = _getMappedDisplay(label);

    return Container(
      width: 50,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _fetchTemperature(label),
          child: Center(
            child:
                _isLoading && _currentLabel == label
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                    : mappedDisplay != null
                    ? Text(
                      mappedDisplay,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 8,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                    : Text(
                      label,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}
