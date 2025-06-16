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
  
  Future<Map<int, double>> fetchUpdatedTemperaturesFromMySQL() async {
    const url = 'http://127.0.0.1:5000/api/fetch_updated_temperatures';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return {
          for (var item in data)
            item['index'] as int: (item['temperature'] as num).toDouble(),
        };
      } else {
        throw Exception('Failed to fetch updated MySQL data');
      }
    } catch (e) {
      throw Exception('Error: $e');
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
  Map<int, double> _updatedValues = {};

  final Map<String, String> _temperatureMapping = {'TC': 'TH'};

  void _fetchAndShowTemperature(String label) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await HeatingCoilService().fetchHeatingCoilData();

      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _temperatureValues = data.map((item) => item.temperature).toList();
          if (label == 'TC') {
            _updatedValues.clear();
          }
        });
        _showTemperatureDialog(label);
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _error = e.toString();
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      });
    } finally {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _isLoading = false;
          });
        });
      }
    }
  }

  void _showTemperatureDialog(String label) {
    final isUpdatable = label == 'TC';
    String? mappedLabel = _temperatureMapping[label];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) {
          if (label == 'TH') {
            return _buildThDialog();
          } else {
            return _buildTcDialog(label, mappedLabel, isUpdatable);
          }
        },
      );
    });
  }

  AlertDialog _buildTcDialog(String label, String? mappedLabel, bool isUpdatable) {
    return AlertDialog(
      title: Text('Heating Coil - $label${isUpdatable ? ' → $mappedLabel' : ''}'),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
          minWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_temperatureValues.length, (index) {
              return Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ListTile(
                      title: Text(
                        '${_temperatureValues[index].toStringAsFixed(2)} °C',
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
            }),
          ),
        ),
      ),
      actions: [
        if (isUpdatable)
          TextButton(
            onPressed: () {
              _submitUpdatedTemperatures();
              Navigator.of(context).pop();
            },
            child: const Text('Submit'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  AlertDialog _buildThDialog() {
    return AlertDialog(
      title: const Text('Heating Coil - TH'),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
          minWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: FutureBuilder<Map<int, double>>(
          future: HeatingCoilService().fetchUpdatedTemperaturesFromMySQL(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final updatedMap = snapshot.data!;
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_temperatureValues.length, (index) {
                    final originalTemp = _temperatureValues[index];
                    final updatedTemp = updatedMap[index];

                    return Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: Text(
                              'Original: ${originalTemp.toStringAsFixed(2)} °C',
                            ),
                          ),
                        ),
                        const VerticalDivider(
                          color: Colors.black,
                          thickness: 1,
                        ),
                        Expanded(
                          child: ListTile(
                            title: Text(
                              updatedTemp != null
                                  ? 'Updated: ${updatedTemp.toStringAsFixed(2)} °C'
                                  : 'Updated: --',
                              style: TextStyle(
                                color: updatedTemp != null
                                    ? Colors.green
                                    : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
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
    );
  }

  void _showManualInputDialog(int index) {
    TextEditingController controller = TextEditingController(
      text: _updatedValues.containsKey(index)
          ? _updatedValues[index]!.toStringAsFixed(2)
          : _temperatureValues[index].toStringAsFixed(2),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
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
                    const SnackBar(
                      content: Text('Value updated successfully!'),
                    ),
                  );
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final containerWidth = screenSize.width * 0.25;
    final double minWidth = 50;
    final double maxWidth = 120;
    final width = containerWidth.clamp(minWidth, maxWidth);
    final fontSize = width * 0.12;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minWidth,
        maxWidth: maxWidth,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Heating Coil',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize,
                      ),
                    ),
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
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Error',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSize * 0.4,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _fetchAndShowTemperature('TC'),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(5),
                      ),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
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
                ),
                Container(height: 1, color: Colors.black),
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _fetchAndShowTemperature('TH'),
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(5),
                      ),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitUpdatedTemperatures() async {
    final url = Uri.parse('http://127.0.0.1:5000/api/update_tc_temperatures');
    final payload = {
      'temperatures': _updatedValues.entries
          .map((e) => {'index': e.key, 'temperature': e.value})
          .toList(),
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Submitted successfully to MySQL!')),
        );
      } else {
        throw Exception('Failed with status: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting data: $e')));
    }
  }
}