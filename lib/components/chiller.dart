import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:my_app/temperature_service.dart';

class Chiller extends StatefulWidget {
  final List<String> buttonLabels;
  final String? topLabel;
  final String chillerName;

  const Chiller({
    super.key,
    required this.buttonLabels,
    this.topLabel,
    required this.chillerName,
  });

  @override
  State<Chiller> createState() => _ChillerState();
}

class _ChillerState extends State<Chiller> {
  bool _isLoading = false;
  String? _error;
  List<double> _temperatureValues = [];
  Map<int, double> _updatedValues = {};
  Map<String, Map<int, double>> _allUpdatedValues =
      {}; // Stores updates for all labels

  final Set<String> _updatableButtons = {'TI1', 'TI7', 'TI22'};
  final Set<String> _readOnlyButtons = {'TI2', 'TI9', 'TI21'}; // Added TI2

  final Map<String, String> _temperatureMapping = {
    'TI1': 'TI101',
    'TI7': 'TI107',
    'TI22': 'TI122',
    'TI2': 'TI102', // Added for TI2
    'TI9': 'TI109',
    'TI21': 'TI121',
  };
  Future<void> _fetchAndShowTemperature(String label) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await TemperatureService().fetchTemperatureData();
      if (!mounted) return;

      // For updatable buttons, fetch the updated values from MySQL
      if (_updatableButtons.contains(label)) {
        final updatedValues = await _fetchUpdatedValues(label);
        setState(() {
          _updatedValues = updatedValues;
        });
      }
      // For read-only buttons, fetch the corresponding updated values
      else if (_readOnlyButtons.contains(label)) {
        final sourceLabel = _getSourceLabelForReadOnly(label);
        if (sourceLabel != null) {
          final updatedValues = await _fetchUpdatedValues(sourceLabel);
          setState(() {
            _allUpdatedValues[label] = updatedValues;
          });
        }
      }

      setState(() {
        _temperatureValues = data.map((item) => item.temperature).toList();
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

  // Gets the source label for read-only buttons (TI7 for TI9, TI22 for TI21)

  String? _getSourceLabelForReadOnly(String readOnlyLabel) {
    switch (readOnlyLabel) {
      case 'TI2':
        return 'TI1'; // TI2 will show TI1's updates
      case 'TI9':
        return 'TI7';
      case 'TI21':
        return 'TI22';
      default:
        return null;
    }
  }

  Future<Map<int, double>> _fetchUpdatedValues(String label) async {
    final apiUrl = 'http://127.0.0.1:5000/api/get_updated_values';
    final mappedLabel = _temperatureMapping[label] ?? label;

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'table_name': '${mappedLabel}_chiller'}),
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

  Future<void> _saveUpdatedValueToDatabase(
    String label,
    double value,
    int index,
  ) async {
    final apiUrl = 'http://127.0.0.1:5000/api/save_temperature';
    final mappedLabel = _temperatureMapping[label] ?? label;
    final tableName = '${mappedLabel}_chiller';

    final payload = {
      'table_name': tableName,
      'value': value,
      'index': index,
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Saved to database!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showManualInputDialog(int index, String label) {
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
                onPressed: () {
                  final value = double.tryParse(controller.text);
                  if (value != null) {
                    setState(() {
                      _updatedValues[index] = value;
                    });
                    Navigator.of(context).pop();
                    _saveUpdatedValueToDatabase(label, value, index);
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
    final chillerHeight = width * 0.6;
    final buttonCount = widget.buttonLabels.length;
    final dynamicButtonFontSize = fontSize * (buttonCount > 2 ? 0.7 : 0.9);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.topLabel != null)
          Text(
            widget.topLabel!,
            style: TextStyle(
              fontSize: fontSize * 0.9,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: width * 0.7,
              height: chillerHeight,
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
                    widget.chillerName,
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
            Container(
              width: width * 0.3,
              height: chillerHeight,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 243, 244, 245),
                border: Border.all(color: Colors.black),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(5),
                  bottomRight: Radius.circular(5),
                ),
              ),
              child: Column(
                children:
                    widget.buttonLabels.map((label) {
                      return Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _fetchAndShowTemperature(label),
                            child: Center(
                              child: Text(
                                label,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: dynamicButtonFontSize,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showTemperatureDialog(String label) {
    final isUpdatable = _updatableButtons.contains(label);
    final isReadOnly = _readOnlyButtons.contains(label);
    String mappedLabel = _temperatureMapping[label] ?? label;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              '${widget.chillerName} - $label${isUpdatable ? ' → $mappedLabel' : ''}',
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _temperatureValues.length,
                itemBuilder: (context, index) {
                  if (isReadOnly) {
                    // Only for read-only buttons (TI9/TI21) - show left and right columns
                    return Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: ListTile(
                            title: Text(
                              '${_temperatureValues[index].toStringAsFixed(2)} °C',
                            ),
                          ),
                        ),
                        const VerticalDivider(width: 1.5, color: Colors.black),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Text(
                              (_allUpdatedValues[label]?.containsKey(index) ??
                                      false)
                                  ? '${_allUpdatedValues[label]?[index]!.toStringAsFixed(2)} °C'
                                  : '--',
                              style: TextStyle(
                                color:
                                    (_allUpdatedValues[label]?.containsKey(
                                              index,
                                            ) ??
                                            false)
                                        ? Colors.green
                                        : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else if (isUpdatable) {
                    // For updatable buttons (TI7/TI22) - show only left column with Update button
                    return ListTile(
                      title: Text(
                        '${_temperatureValues[index].toStringAsFixed(2)} °C',
                      ),
                      trailing: TextButton(
                        onPressed: () => _showManualInputDialog(index, label),
                        child: const Text('Update'),
                      ),
                    );
                  } else {
                    // For all other buttons - simple display
                    return ListTile(
                      title: Text(
                        '${_temperatureValues[index].toStringAsFixed(2)} °C',
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
}
