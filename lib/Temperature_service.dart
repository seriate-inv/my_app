import 'dart:convert';
import 'dart:async'; // For TimeoutException
import 'package:http/http.dart' as http;

class TemperatureService {
  // Use 10.0.2.2 for Android emulator to access localhost
  static const String apiUrl = 'http://127.0.0.1:5000/api/temperature';

  Future<List<TemperatureData>> fetchTemperatureData() async {
    try {
      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 10)); // Add timeout

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => TemperatureData.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load temperature data: ${response.statusCode}',
        );
      }
    } on TimeoutException {
      throw Exception('Request timed out. Please try again later.');
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }
}


class TemperatureData {
  final DateTime time;
  final double temperature;

  TemperatureData({required this.time, required this.temperature});

  factory TemperatureData.fromJson(Map<String, dynamic> json) {
    return TemperatureData(
      time: DateTime.parse(json['time']),
      temperature: (json['temperature'] ?? 0).toDouble(),
    );
  }

  get value => null;
}
