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

  // Track updates by label and index position
  Map<String, Map<int, double>> _chillerUpdates = {}; 

  // Mapping between chiller sources and tank display labels
  final Map<String, String> _chillerToTankMapping = {
    'TI101': 'TI2',  // TI101 (TI1) updates will show in TI2
    'TI107': 'TI9',  // TI107 (TI7) updates will show in TI9
    'TI122': 'TI21', // TI122 (TI22) updates will show in TI21
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

      // For mapped labels, fetch updates from corresponding chiller tables
      if (_chillerToTankMapping.containsValue(label)) {
        final chillerLabel = _chillerToTankMapping.entries
            .firstWhere((entry) => entry.value == label)
            .key;
        final updates = await _fetchChillerUpdates(chillerLabel);
        setState(() {
          _chillerUpdates[label] = updates;
        });
      }

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

  Future<Map<int, double>> _fetchChillerUpdates(String chillerLabel) async {
    final apiUrl = 'http://127.0.0.1:5000/api/get_updated_values';
    
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'table_name': '${chillerLabel}_chiller'}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Map<int, double> result = {};
        for (var item in data) {
          result[item['index_position']] = item['value'].toDouble();
        }
        return result;
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  void _showTemperatureDialog(String label) {
    final hasChillerUpdates = _chillerToTankMapping.containsValue(label);
    final updates = hasChillerUpdates ? _chillerUpdates[label] : null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$label Temperature Readings'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _tempValues.length,
            itemBuilder: (context, index) {
              final original = _tempValues[index];
              final updatedValue = updates?[index];

              return Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ListTile(
                      title: Text('${original.toStringAsFixed(2)} °C'),
                    ),
                  ),
                  if (updatedValue != null) ...[
                    const VerticalDivider(width: 1.5, color: Colors.black),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Text(
                          '${updatedValue.toStringAsFixed(2)} °C',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
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
            child: _isLoading && _currentLabel == label
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : Text(
                    label, // Always show just the label (TI2, TI9, etc.)
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