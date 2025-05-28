// temperature_manager.dart
import 'temperature_service.dart';

class TemperatureManager {
  static final TemperatureManager _instance = TemperatureManager._internal();
  factory TemperatureManager() => _instance;
  TemperatureManager._internal();

  List<TemperatureData> _cachedData = [];

  bool get isEmpty => _cachedData.isEmpty;

  Future<void> fetchAndCacheTemperatures() async {
    _cachedData = await TemperatureService().fetchTemperatureData();
  }

  List<TemperatureData> get allData => _cachedData;

  TemperatureData? getLatest() => _cachedData.isNotEmpty ? _cachedData.last : null;
}
