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

  // Updated button labels to match the desired layout
  final List<String> leftColumnLabels;
  final List<String> rightColumnLabels;
  final Map<String, Offset> temperatureButtonOffsets;
  final double buttonSpacing; // Space between buttons

  const Tank({
    Key? key,
    required this.color,
    required this.mixerAnimation,
    required this.fillLevel,
    this.showTemperatureButtons = true,
    this.leftColumnLabels = const ['10', '2'], // Left column labels
    this.rightColumnLabels = const ['11', '3'], // Right column labels
    this.temperatureButtonOffsets = const {},
    this.buttonSpacing = 20.0, // Default spacing
  }) : super(key: key);

  @override
  _TankState createState() => _TankState();
}

class _TankState extends State<Tank> {
  bool _isLoading = false;
  String? _error;
  List<double> _tempValues = [];

  Future<void> _fetchTemperature() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await TankService().fetchTankData();
      if (!mounted) return;

      setState(() {
        _tempValues = data.map((item) => item.temperature).toList();
      });

      _showTemperatureDialog();
    } catch (e) {
      setState(() => _error = e.toString());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showTemperatureDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tank Temperature'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _tempValues.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('${_tempValues[index].toStringAsFixed(2)} °C'),
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
          // Tank structure
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

          // Temperature buttons - positioned in two columns
          if (widget.showTemperatureButtons) ...[
            // Left column (10 and 2)
            Positioned(
              top: 28,
              left:10,
              child: SizedBox(
                width: 50,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    for (var label in widget.leftColumnLabels)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildTemperatureButton(label: label),
                      ),
                  ],
                ),
              ),
            ),
            // Right column (11 and 3)
            Positioned(
              top: 10,
              left: 30,
              child: SizedBox(
                width: 50,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    for (var label in widget.rightColumnLabels)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
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
          onTap: _fetchTemperature,
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
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