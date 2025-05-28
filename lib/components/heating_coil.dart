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

  void _fetchAndShowTemperature() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await HeatingCoilService().fetchHeatingCoilData();

      if (!mounted) return;

      setState(() {
        _temperatureValues = data.map((item) => item.temperature).toList();
      });

      _showTemperatureDialog();
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

  void _showTemperatureDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Heating Coil Temperature Readings'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _temperatureValues.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                  '${_temperatureValues[index].toStringAsFixed(2)} °C',
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

        // T1 and T2 Buttons Container
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
              // T1 Button (Top Half)
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _fetchAndShowTemperature,
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
              // T2 Button (Bottom Half)
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _fetchAndShowTemperature, // Same functionality for both
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