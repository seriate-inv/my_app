import 'package:flutter/material.dart';
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
  Map<int, double> _updatedValues =
      {}; // Stores updated temperature values by index

  // Define which buttons should have update functionality
  final Set<String> _updatableButtons = {'TI1', 'TI7', 'TI22'};

  // Define your mapping here (e.g., TI1 → TI101, TI7 → TI107, etc.)
  final Map<String, String> _temperatureMapping = {
    'TI1': 'TI101',
    'TI7': 'TI107',
    'TI22': 'TI122',
  };

  void _fetchAndShowTemperature(String label) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await TemperatureService().fetchTemperatureData();
      if (!mounted) return;

      setState(() {
        _temperatureValues = data.map((item) => item.temperature).toList();
        // Only clear updates if we're viewing an updatable button
        if (_updatableButtons.contains(label)) {
          _updatedValues.clear();
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
    final isUpdatable = _updatableButtons.contains(label);
    String? mappedLabel = _temperatureMapping[label] ?? label;

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
                  if (isUpdatable) {
                    return Row(
                      children: [
                        // Original temperature value
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
                    // Read-only display for non-updatable buttons
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
            // Left Chiller Box
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

            // Right Side Buttons
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
}
