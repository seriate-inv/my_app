import 'package:flutter/material.dart';
import 'dart:math';
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
      });

      _showDataDialog(label);
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

  void _showDataDialog(String label) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reading from $label'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _speedValues.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('Speed: ${_speedValues[index].toStringAsFixed(2)} RPM'),
                subtitle: Text('Temp: ${_tempValues[index].toStringAsFixed(2)} °C'),
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
    final buttonHeight = width * 0.18;
    final totalButtons = widget.buttonLabels.length + (widget.bottomButtonLabel != null ? 1 : 0);
    final mainBodyHeight = buttonHeight * totalButtons;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Scrollable Buttons Column
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Buttons
                  Container(
                    width: width * 0.3,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 243, 244, 245),
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(5),
                        topRight: widget.bottomButtonLabel == null ? const Radius.circular(5) : Radius.zero,
                        bottomLeft: widget.bottomButtonLabel == null ? const Radius.circular(5) : Radius.zero,
                        bottomRight: widget.bottomButtonLabel == null ? const Radius.circular(5) : Radius.zero,
                      ),
                    ),
                    child: Column(
                      children: widget.buttonLabels.map((label) {
                        return SizedBox(
                          height: buttonHeight,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _fetchAndShowData(label),
                              child: Center(
                                child: Text(
                                  label,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontSize * 0.8,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  // Bottom Button
                  if (widget.bottomButtonLabel != null)
                    Container(
                      width: width * 0.3,
                      height: buttonHeight,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 243, 244, 245),
                        border: Border.all(color: Colors.black),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.zero,
                          topRight: Radius.zero,
                          bottomLeft: Radius.circular(5),
                          bottomRight: Radius.circular(5),
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _fetchAndShowData(widget.bottomButtonLabel!),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.zero,
                            topRight: Radius.zero,
                            bottomLeft: Radius.circular(5),
                            bottomRight: Radius.circular(5),
                          ),
                          child: Center(
                            child: Text(
                              widget.bottomButtonLabel!,
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
            ),
          ),

          // Main Body
          Container(
            width: width * 0.9,
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
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 50,
                  height: 4,
                  color: Colors.blue,
                ),
                const SizedBox(height: 3),
                Container(
                  width: 50,
                  height: 4,
                  color: Colors.red,
                ),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 6.0),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 1.5,
                    ),
                  )
                else if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      'Error',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize * 0.35,
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
}
