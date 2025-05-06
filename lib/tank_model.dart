/*
import 'package:flutter/material.dart';
import 'package:my_app/tank_page.dart';
import 'header_bar.dart';
import 'piping_system.dart';
import 'tank.dart';
import 'heat_exchanger.dart';
import 'valve.dart';
import 'chiller.dart';
import 'heating_coil.dart';
import 'homogenizer.dart';
import 'pump_control.dart';

class IndustrialControlPanel extends StatefulWidget {
  const IndustrialControlPanel({Key? key}) : super(key: key);

  @override
  _IndustrialControlPanelState createState() => _IndustrialControlPanelState();
}

class _IndustrialControlPanelState extends State<IndustrialControlPanel>
    with TickerProviderStateMixin {
  late AnimationController _flowAnimation;
  late AnimationController _mixerAnimation;
  late AnimationController _homogenizerAnimation;
  bool pump1Active = true;
  bool pump2Active = true;
  double valve1Position = 50.0;

  final Map<String, Map<String, dynamic>> tankData = {
    'tank1': {
      'temperature': 5.0,
      'flowRate': 10.0,
      'level': 80.0,
      'color': Colors.blue,
    },
    'tank2': {
      'temperature': 80.0,
      'flowRate': 15.0,
      'level': 70.0,
      'color': Colors.red,
    },
    'output': {
      'temperature': 80.0,
      'flowRate': 15.0,
      'level': 70.0,
      'color': Colors.pink,
    },
    'mix': {
      'temperature': 80.0,
      'flowRate': 15.0,
      'level': 70.0,
      'color': Colors.purple,
    },
  };

  @override
  void initState() {
    super.initState();
    _flowAnimation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _mixerAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat();
    _homogenizerAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat();
  }

  @override
  void dispose() {
    _flowAnimation.dispose();
    _mixerAnimation.dispose();
    _homogenizerAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blueGrey[800],
        child: Column(
          children: [
            HeaderBar(tankData: tankData),
            Expanded(child: _buildControlSystem()),
          ],
        ),
      ),
    );
  }

  Widget _buildControlSystem() {
    return Container(
      color: Colors.blue[700],
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          PipingSystem(flowAnimation: _flowAnimation),
          Positioned(
            right: 55,
            top: 150,
            child: Tank(
              color: tankData['tank1']!['color'],
              mixerAnimation: _mixerAnimation,
              fillLevel: tankData['tank1']!['level'] / 100,
            ),
          ),
          Positioned(
            right: 260,
            top: 150,
            child: Tank(
              color: tankData['tank2']!['color'],
              mixerAnimation: _mixerAnimation,
              fillLevel: tankData['tank2']!['level'] / 100,
            ),
          ),
          Positioned(right: 265, bottom: 8, child: HeatExchanger()),
          Positioned(left: 100, bottom: 150, child: HeatExchanger()),
          Positioned(right: 60, bottom: 8, child: Chiller()),
          Positioned(right: 60, top: 20, child: Chiller()),
          Positioned(left: 100, bottom: 20, child: Chiller()),
          Positioned(right: 400, top: 200, child: HeatingCoil()),
          Positioned(left: 630, top: 200, child: NonReturningValve()),
          Positioned(left: 550, bottom: 8, child: NonReturningValve()),
          Positioned(
            left: 100,
            top: 200,
            child: Homogenizer(animation: _homogenizerAnimation),
          ),
          Positioned(left: 470, top: 230, child: Valve()),
          Positioned(left: 470, bottom: 50, child: Valve()),
          Positioned(left: 570, bottom: 180, child: Valve()),
          Positioned(
            right: 60,
            bottom: 100,
            child: PumpControl(
              pumpNumber: 1,
              isActive: pump1Active,
              onToggle: (value) => setState(() => pump1Active = value),
            ),
          ),
          Positioned(
            right: 265,
            bottom: 100,
            child: PumpControl(
              pumpNumber: 2,
              isActive: pump2Active,
              onToggle: (value) => setState(() => pump2Active = value),
            ),
          ),
        ],
      ),
    );
  }
}
*/