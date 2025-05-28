import 'package:flutter/material.dart';
import 'package:my_app/temperature_service.dart'; // Ensure this import path is correct

class TankWidget extends StatefulWidget {
  final Color color;
  final AnimationController mixerAnimation;
  final double initialFillLevel;
  final ValueChanged<double>? onFillLevelChanged;
  final String? temperatureButtonLabel; // Optional label for the temp button

  const TankWidget({
    super.key,
    required this.color,
    required this.mixerAnimation,
    this.initialFillLevel = 0.5,
    this.onFillLevelChanged,
    this.temperatureButtonLabel,
  });

  @override
  _TankWidgetState createState() => _TankWidgetState();
}

class _TankWidgetState extends State<TankWidget> {
  late double _fillLevel;
  bool _isDragging = false;
  bool _isLoadingTemp = false;
  String? _tempError;

  @override
  void initState() {
    super.initState();
    _fillLevel = widget.initialFillLevel;
  }

  // Temperature fetch logic (reused from Chiller)
  Future<void> _fetchTemperature() async {
    setState(() {
      _isLoadingTemp = true;
      _tempError = null;
    });

    try {
      final data = await TemperatureService().fetchTemperatureData();
      if (!mounted) return;

      final temps = data.map((item) => item.temperature).toList();
      _showTemperatureDialog(temps);
    } catch (e) {
      setState(() => _tempError = e.toString());
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoadingTemp = false);
      }
    }
  }

  void _showTemperatureDialog(List<double> temps) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Tank Temperature'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: temps.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('${temps[index].toStringAsFixed(2)} °C'),
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

  // Existing tank logic
  void _updateFillLevel(double newLevel) {
    setState(() {
      _fillLevel = newLevel.clamp(0.0, 1.0);
    });
    widget.onFillLevelChanged?.call(_fillLevel);
  }

  void _handleDragStart(DragStartDetails details) =>
      setState(() => _isDragging = true);
  void _handleDragEnd(DragEndDetails _) => setState(() => _isDragging = false);

  void _handleDragUpdate(DragUpdateDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final localPos = box.globalToLocal(details.globalPosition);
    _updateFillLevel((box.size.height - localPos.dy) / box.size.height);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main Tank
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragStart: _handleDragStart,
          onVerticalDragUpdate: _handleDragUpdate,
          onVerticalDragEnd: _handleDragEnd,
          child: SizedBox(
            width: 100,
            height: 150,
            child: Stack(
              children: [
                // Tank outline
                Container(
                  width: 90,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    border: Border.all(color: Colors.black, width: 3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // Fluid
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: 90,
                    height: 150 * _fillLevel,
                    decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius: BorderRadius.only(
                        bottomLeft: const Radius.circular(8),
                        bottomRight: const Radius.circular(8),
                        topLeft: Radius.circular(_fillLevel > 0.95 ? 8 : 0),
                        topRight: Radius.circular(_fillLevel > 0.95 ? 8 : 0),
                      ),
                    ),
                  ),
                ),
                // Level indicator
                Positioned(
                  right: 0,
                  child: Container(
                    width: 5,
                    height: 150,
                    color: _isDragging ? Colors.grey[700] : Colors.grey[900],
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: 5,
                            height: 150 * _fillLevel,
                            color:
                                _isDragging
                                    ? Colors.lightGreen
                                    : Colors.lightGreenAccent,
                          ),
                        ),
                        if (_isDragging)
                          Positioned(
                            bottom: 150 * _fillLevel - 8,
                            left: -7.5,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Temperature button (positioned at top-right corner)
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: _fetchTemperature,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: BorderRadius.circular(4),
              ),
              child:
                  _isLoadingTemp
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : Text(
                        widget.temperatureButtonLabel ?? 'Temp',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ),
        ),
      ],
    );
  }
}
