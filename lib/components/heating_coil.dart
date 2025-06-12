import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HeatingCoilData {
  final DateTime time;
  final double temperature;

  HeatingCoilData({required this.time, required this.temperature});

  factory HeatingCoilData.fromJson(Map<String, dynamic> json) {
    return HeatingCoilData(
      time: DateTime.parse(json['time']),
      temperature: (json['temperature'] ?? 0).toDouble(),
    );
  }
}

class HeatingCoilService {
  static const String apiUrl = 'http://127.0.0.1:5000/api/temperature';

  Future<List<HeatingCoilData>> fetchHeatingCoilData() async {
    try {
      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => HeatingCoilData.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load heating coil data: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }
}

class HeatingCoil extends StatefulWidget {
  const HeatingCoil({super.key});

  @override
  State<HeatingCoil> createState() => _HeatingCoilState();
}

class _HeatingCoilState extends State<HeatingCoil> {
  bool _isLoading = false;
  String? _error;
  List<double> _temperatureValues = [];
  Map<int, double> _updatedValues = {}; // Stores updated temperature values by index

  // Mapping for TC to TH
  final Map<String, String> _temperatureMapping = {
    'TC': 'TH',
  };

  void _fetchAndShowTemperature(String label) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await HeatingCoilService().fetchHeatingCoilData();

      if (!mounted) return;

      setState(() {
        _temperatureValues = data.map((item) => item.temperature).toList();
        // Only clear updates if we're viewing TC (updatable)
        if (label == 'TC') {
          _updatedValues.clear();
        }
      });

      _showTemperatureDialog(label);
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

  void _showTemperatureDialog(String label) {
    final isUpdatable = label == 'TC';
    String? mappedLabel = _temperatureMapping[label];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Heating Coil - $label${isUpdatable ? ' → $mappedLabel' : ''}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _temperatureValues.length,
            itemBuilder: (context, index) {
              if (isUpdatable) {
                return Row(
                  children: [
                    // Original temperature value
                    Expanded(
                      flex: 2,
                      child: ListTile(
                        title: Text('${_temperatureValues[index].toStringAsFixed(2)} °C'),
                        trailing: TextButton(
                          onPressed: () => _showManualInputDialog(index),
                          child: const Text('Update'),
                        ),
                      ),
                    ),
                    
                    // Vertical divider
                    const VerticalDivider(width: 1.5, color: Colors.black),
                    
                    // Updated value display
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Text(
                          _updatedValues.containsKey(index)
                              ? '${_updatedValues[index]!.toStringAsFixed(2)} °C'
                              : '--',
                          style: TextStyle(
                            color: _updatedValues.containsKey(index)
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
                // Read-only display for TH
                return ListTile(
                  title: Text('${_temperatureValues[index].toStringAsFixed(2)} °C'),
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
      text: _updatedValues.containsKey(index)
          ? _updatedValues[index]!.toStringAsFixed(2)
          : _temperatureValues[index].toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null) {
                setState(() {
                  _updatedValues[index] = value;
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Value updated successfully!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid number')),
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
        // Main Heating Coil Container
        Container(
          width: width * 0.7,
          height: width * 0.6,
          decoration: BoxDecoration(
            color: Colors.grey[600],
            border: Border.all(color: Colors.black),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(5),
              bottomLeft: Radius.circular(5),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Heating Coil',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
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

        // TC and TH Buttons Container
        Container(
          width: width * 0.3,
          height: width * 0.6,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 243, 244, 245),
            border: Border.all(color: Colors.black),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(5),
              bottomRight: Radius.circular(5),
            ),
          ),
          child: Column(
            children: [
              // TC Button (Top Half) - Updatable
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _fetchAndShowTemperature('TC'),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        'TC',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 14, 14, 14),
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Divider between buttons
              Container(
                height: 1,
                color: Colors.black,
              ),
              // TH Button (Bottom Half) - Read only
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _fetchAndShowTemperature('TH'),
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        'TH',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 14, 14, 14),
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize,
                        ),
                      ),
                    ),
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