import 'package:flutter/material.dart';

class HeatExchanger extends StatelessWidget {
  const HeatExchanger({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[600],
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Heat Exchanger',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 60,
            height: 5,
            color: Colors.blue,
            alignment: Alignment.center,
          ),
          const SizedBox(height: 4),
          Container(
            width: 60,
            height: 5,
            color: Colors.red,
            alignment: Alignment.center,
          ),
        ],
      ),
    );
  }
}