import 'package:flutter/material.dart';

class Chiller extends StatelessWidget {
  const Chiller({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen size information
    final screenSize = MediaQuery.of(context).size;

    // Calculate responsive dimensions
    // Base the width on a percentage of screen width
    final containerWidth = screenSize.width * 0.25; // 25% of screen width
    final containerHeight = containerWidth * 0.6; // Maintain aspect ratio

    // Define minimum and maximum sizes to ensure usability on all devices
    final double minWidth = 80;
    final double maxWidth = 120;
    final width = containerWidth.clamp(minWidth, maxWidth);

    // Scale the inner container and font sizes proportionally
    final innerContainerWidth = width * 0.7; // 70% of the parent width
    final fontSize = width * 0.09; // Scale font with container width

    return Container(
      width: width,
      height: width * 0.6, // Maintain the same aspect ratio
      decoration: BoxDecoration(
        color: Colors.grey[600],
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Chiller',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
          SizedBox(height: width * 0.03), // Responsive spacing
          Container(
            width: innerContainerWidth,
            height: width * 0.25, // 25% of parent width
            color: Colors.blue,
            alignment: Alignment.center,
          ),
        ],
      ),
    );
  }
}
