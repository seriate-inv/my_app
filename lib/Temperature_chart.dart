/*import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'temperature_service.dart';

class TemperatureChart extends StatelessWidget {
  final List<TemperatureData> data;

  const TemperatureChart({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      title: ChartTitle(text: 'Temperature Over Time'),
      legend: Legend(isVisible: true),
      tooltipBehavior: TooltipBehavior(enable: true),
      primaryXAxis: DateTimeAxis(
        title: AxisTitle(text: 'Time'),
        intervalType: DateTimeIntervalType.hours,
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: 'Temperature (°C)'),
        numberFormat: NumberFormat('#,###°C'),
      ),
      series: <LineSeries<TemperatureData, DateTime>>[
        LineSeries<TemperatureData, DateTime>(
          dataSource: data,
          xValueMapper: (TemperatureData temp, _) => temp.time,
          yValueMapper: (TemperatureData temp, _) => temp.value,
          name: 'Temperature',
          markerSettings: const MarkerSettings(isVisible: true),
          dataLabelSettings: const DataLabelSettings(
            isVisible: false,
          ),
          color: Colors.blue,
          width: 3,
        )
      ],
    );
  }
}
*/