import 'package:flutter/material.dart';
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

  final Map<String, String> mapping = {'TC': 'TH', 'TI5': 'TI16'};

  Map<int, double> updatedValues = {}; // Index-wise updated data

  void _fetchAndShowData(String label) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await HomogenizerService().fetchHomogenizerData();
      if (!mounted) return;

      setState(() {
        _speedValues = data.map((item) => item.speed).toList();
        _tempValues = data.map((item) => item.temperature).toList();
        if (label == 'TI5') {
          updatedValues.clear(); // clear old updates only for TI5
        }
      });

      _showDataDialog(label);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showDataDialog(String label) {
    String? mappedLabel = mapping[label];
    final isUpdatable = label == 'TI5'; // Only TI5 is updatable

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Readings from $label${mappedLabel != null ? ' → $mappedLabel' : ''}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _speedValues.length,
            itemBuilder: (context, index) {
              if (isUpdatable) {
                return Row(
                  children: [
                    // Original Readings & Update Button (only for TI5)
                    Expanded(
                      flex: 2,
                      child: ListTile(
                        title: Text(
                          'Speed: ${_speedValues[index].toStringAsFixed(2)} RPM',
                        ),
                        subtitle: Text(
                          'Temp: ${_tempValues[index].toStringAsFixed(2)} °C',
                        ),
                        trailing: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Future.delayed(Duration(milliseconds: 100), () {
                              _showManualInputDialog(index);
                            });
                          },
                          child: const Text('Update'),
                        ),
                      ),
                    ),
                    // Vertical Divider
                    const VerticalDivider(width: 1.5, color: Colors.black),
                    // Updated Value Display (only for TI5)
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Text(
                          updatedValues.containsKey(index)
                              ? '${updatedValues[index]!.toStringAsFixed(2)} °C'
                              : '--',
                          style: TextStyle(
                            color: updatedValues.containsKey(index)
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
                // Read-only display for all other buttons
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
      text: updatedValues.containsKey(index)
          ? updatedValues[index]!.toStringAsFixed(2)
          : _tempValues[index].toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null) {
                setState(() {
                  updatedValues[index] = value;
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Manual value updated')),
                );
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
    final double minWidth = 50;
    final double maxWidth = 120;
    final width = containerWidth.clamp(minWidth, maxWidth);
    final fontSize = width * 0.12;
    final buttonHeight = width * 0.18;
    final totalButtons =
        widget.buttonLabels.length + (widget.bottomButtonLabel != null ? 1 : 0);
    final mainBodyHeight = buttonHeight * totalButtons;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Buttons
          Column(
            children: [
              Container(
                width: width * 0.3,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.black),
                ),
                child: Column(
                  children: widget.buttonLabels.map((label) {
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

          // Panel
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