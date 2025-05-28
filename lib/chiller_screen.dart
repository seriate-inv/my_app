import 'package:flutter/material.dart';
import 'temperature_manager.dart';

class ChillerScreen extends StatelessWidget {
  const ChillerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final latest = TemperatureManager().getLatest();

    return Scaffold(
      appBar: AppBar(title: const Text('Chiller')),
      body: Center(
        child: latest == null
            ? const Text("No data available")
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Latest Chiller Temperature:"),
                  Text(
                    "${latest.value.toStringAsFixed(2)}°C",
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }
}
