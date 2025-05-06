import 'package:flutter/material.dart';

class Tank extends StatelessWidget {
  final Color color;
  final AnimationController mixerAnimation;
  final double fillLevel;

  const Tank({
    Key? key,
    required this.color,
    required this.mixerAnimation,
    required this.fillLevel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 150,
      child: Stack(
        children: [
          Container(
            width: 90,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              border: Border.all(color: Colors.black, width: 3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: 90,
              height: 150 * fillLevel,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                  bottomLeft: const Radius.circular(8),
                  bottomRight: const Radius.circular(8),
                  topLeft: Radius.circular(fillLevel > 0.95 ? 8 : 0),
                  topRight: Radius.circular(fillLevel > 0.95 ? 8 : 0),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
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
                  height: 150 * fillLevel,
                  color: Colors.lightGreenAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
