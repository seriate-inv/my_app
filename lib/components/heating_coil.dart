import 'package:flutter/material.dart';

class HeatingCoil extends StatelessWidget {
  const HeatingCoil({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isVerySmallScreen = screenWidth < 400;

    // Calculate responsive dimensions
    final width = isVerySmallScreen ? 80 : (isSmallScreen ? 90 : 100);
    final height = isVerySmallScreen ? 50 : (isSmallScreen ? 55 : 60);
    final innerWidth = isVerySmallScreen ? 60 : (isSmallScreen ? 65 : 70);
    final innerHeight = isVerySmallScreen ? 20 : (isSmallScreen ? 22 : 25);
    final fontSize = isVerySmallScreen ? 8 : (isSmallScreen ? 8.5 : 9);

    return Container(
      width: width.toDouble(),
      height: height.toDouble(),
      decoration: BoxDecoration(
        color: Colors.grey[600],
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: const Text(
                'Heating Coil',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: isVerySmallScreen ? 2 : 3),
          Container(
            width: innerWidth.toDouble(),
            height: innerHeight.toDouble(),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(
                2,
              ), // Optional rounded corners
            ),
            alignment: Alignment.center,
          ),
        ],
      ),
    );
  }
}
