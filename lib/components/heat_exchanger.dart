import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'homogenizer.dart';

class HeatExchanger extends StatefulWidget {
  final String title;
  final List<String> buttonLabels;
  final String? bottomButtonLabel;

  const HeatExchanger({
    super.key,
    required this.title,
    required this.buttonLabels,
    this.bottomButtonLabel,
  });

  @override
  State<HeatExchanger> createState() => _HeatExchangerState();
}

class _HeatExchangerState extends State<HeatExchanger> {
  bool _isLoading = false;
  String? _error;
  List<double> _speedValues = [];
  List<double> _tempValues = [];

  // Track updated TI5 values
  Map<int, double> _updatedValues = {};
  // For TI6: show stored values from MySQL
  Map<int, double> _storedTI5Values = {};

  final Map<String, String> _temperatureMapping = {'TC': 'TH', 'TI5': 'TI6'};

  Future<void> _fetchAndShowData(String label) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await HomogenizerService().fetchHomogenizerData();
      if (!mounted) return;

      // Special handling for TI5 and TI6
      if (label == 'TI5' || label == 'TI6') {
        final updates = await _fetchTI5UpdatedValues();
        setState(() {
          if (label == 'TI5') {
            _updatedValues = updates;
          } else if (label == 'TI6') {
            _storedTI5Values = updates;
          }
        });
      }

      setState(() {
        _speedValues = data.map((item) => item.speed).toList();
        _tempValues = data.map((item) => item.temperature).toList();
      });

      _showDataDialog(label);
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

  Future<Map<int, double>> _fetchTI5UpdatedValues() async {
    final apiUrl = 'http://127.0.0.1:5000/api/ti5_heat_exchanger';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Map<int, double> result = {};
        for (var item in data) {
          if (item['entry_index'] != null && item['temperature'] != null) {
            result[item['entry_index']] = item['temperature'].toDouble();
          }
        }
        return result;
      }
      return {};
    } catch (e) {
      print('Error fetching TI6 values: $e');
      return {};
    }
  }

  void _showDataDialog(String label) {
    final isTI5 = label == 'TI5';
    final isTI6 = label == 'TI6';
    String? mappedLabel = _temperatureMapping[label];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Readings from $label${mappedLabel != null ? ' → $mappedLabel' : ''}',
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _speedValues.length,
                itemBuilder: (context, index) {
                  if (isTI5 || isTI6) {
                    final rightValue =
                        isTI5 ? _updatedValues[index] : _storedTI5Values[index];

                    return Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: ListTile(
                            title: Text(
                              'Speed: ${_speedValues[index].toStringAsFixed(2)} RPM',
                            ),
                            subtitle: Text(
                              'Temp: ${_tempValues[index].toStringAsFixed(2)} °C',
                            ),
                            trailing:
                                isTI5
                                    ? TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Future.delayed(
                                          Duration(milliseconds: 100),
                                          () {
                                            _showManualInputDialog(index);
                                          },
                                        );
                                      },
                                      child: const Text('Update'),
                                    )
                                    : null,
                          ),
                        ),
                        const VerticalDivider(width: 1.5, color: Colors.black),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Text(
                              rightValue != null
                                  ? '${rightValue.toStringAsFixed(2)} °C'
                                  : '--',
                              style: TextStyle(
                                color:
                                    rightValue != null
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
                      title: Text(
                        'Speed: ${_speedValues[index].toStringAsFixed(2)} RPM',
                      ),
                      subtitle: Text(
                        'Temp: ${_tempValues[index].toStringAsFixed(2)} °C',
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
          ),
    );
  }

  void _showManualInputDialog(int index) {
    TextEditingController controller = TextEditingController(
      text:
          _updatedValues.containsKey(index)
              ? _updatedValues[index]!.toStringAsFixed(2)
              : _tempValues[index].toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Enter Value Manually'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: 'Enter temperature value',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  final value = double.tryParse(controller.text);
                  if (value != null) {
                    setState(() {
                      _updatedValues[index] = value;
                    });
                    Navigator.of(context).pop();

                    try {
                      final response = await http.post(
                        Uri.parse(
                          'http://127.0.0.1:5000/api/ti5_heat_exchanger',
                        ),
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode({
                          'entry_index': index,
                          'temperature': value,
                        }),
                      );

                      if (response.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Value saved to TI5_heat_exchanger'),
                          ),
                        );
                      } else {
                        throw Exception('Failed to save: ${response.body}');
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error saving: $e')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invalid number entered')),
                    );
                  }
                },
                child: const Text('Submit'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final containerWidth = screenSize.width * 0.25;
    final width = containerWidth.clamp(50.0, 120.0);
    final fontSize = width * 0.12;
    final buttonHeight = width * 0.18;
    final totalButtons =
        widget.buttonLabels.length + (widget.bottomButtonLabel != null ? 1 : 0);
    final mainBodyHeight = buttonHeight * totalButtons;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: width * 0.3,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.black),
                ),
                child: Column(
                  children:
                      widget.buttonLabels.map((label) {
                        return SizedBox(
                          height: buttonHeight,
                          child: InkWell(
                            onTap: () => _fetchAndShowData(label),
                            child: Center(
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontSize * 0.8,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
              if (widget.bottomButtonLabel != null)
                Container(
                  width: width * 0.3,
                  height: buttonHeight,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.black),
                  ),
                  child: InkWell(
                    onTap: () => _fetchAndShowData(widget.bottomButtonLabel!),
                    child: Center(
                      child: Text(
                        widget.bottomButtonLabel!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize * 0.8,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Container(
            width: width * 1.1,
            height: mainBodyHeight,
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
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Container(width: 50, height: 2, color: Colors.blue),
                const SizedBox(height: 3),
                Container(width: 50, height: 2, color: Colors.red),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 6.0),
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                else if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text('Error', style: TextStyle(color: Colors.white)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
