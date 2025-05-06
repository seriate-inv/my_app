import 'package:flutter/material.dart';

class IndicatorLight extends StatelessWidget {
  final Color color;
  final bool isOn;

  const IndicatorLight({Key? key, required this.color, required this.isOn})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isOn ? color : color.withOpacity(0.3),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: isOn
            ? [
                BoxShadow(
                  color: color.withOpacity(0.6),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
    );
  }
}