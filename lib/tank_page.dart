import 'package:flutter/material.dart';

class HeaderBar extends StatelessWidget {
  final Map<String, Map<String, dynamic>> tankData;

  const HeaderBar({super.key, required this.tankData});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      color: Colors.grey[800],
      child: Row(
        children: [
          Container(
            width: 160,
            color: Colors.amber,
            padding: const EdgeInsets.all(5),
            child: Row(
              children: [
                const SizedBox(width: 5),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SERIATE',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildTankStatusWidget('TANK #1', tankData['tank1']!)),
                Expanded(child: _buildTankStatusWidget('TANK #2', tankData['tank2']!)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTankStatusWidget(String title, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      color: Colors.grey[850],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            width: double.infinity,
            color: Colors.black,
            alignment: Alignment.center,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              children: [
                _buildStatusRow('Temperature:', '${data['temperature']} °C'),
                _buildStatusRow('Flow Rate:', '${data['flowRate']} l/s'),
                _buildStatusRow('Level:', '${data['level']}%'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 10)),
      ],
    );
  }
}