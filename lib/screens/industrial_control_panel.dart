import 'package:flutter/material.dart';
import 'package:my_app/components/chiller.dart';
import 'package:my_app/components/heat_exchanger.dart';
import 'package:my_app/components/heating_coil.dart';
import 'package:my_app/components/homogenizer.dart';
import 'package:my_app/components/valve.dart';
import 'package:my_app/components/header_bar.dart';
import 'package:my_app/components/piping_system.dart' as piping;
import 'package:my_app/components/pump_control.dart' as pump;
import 'package:my_app/components/tank.dart';

class IndustrialControlPanel extends StatefulWidget {
  const IndustrialControlPanel({super.key});

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
          piping.PipingSystem(
            flowAnimation: _flowAnimation,
            redFluid: Colors.red,
            blueFluid: Colors.blue,
            pinkFluid: Colors.pink,
            purpleFluid: Colors.purple,
            valvePosition: valve1Position,
          ),
          // Tank 1
          Positioned(
            right: 55,
            top: 150,
            child: Tank(
              color: tankData['tank1']!['color'],
              mixerAnimation: _mixerAnimation,
              fillLevel: tankData['tank1']!['level'] / 100,
              leftColumnLabels: ['TI2', 'TI3'],
              rightColumnLabels: [
                'TI11',
                'TI12',
              ], // ✅ Separate into right column
            ),
          ),
          // Tank 2
          Positioned(
            right: 260,
            top: 150,
            child: Tank(
              color: tankData['tank2']!['color'],
              mixerAnimation: _mixerAnimation,
              fillLevel: tankData['tank2']!['level'] / 100,
              //leftColumnLabels: ['u'],
              //rightColumnLabels: ['v'],
            ),
          ),
          Positioned(
            right: 302,
            top: 460,
            child: HeatExchanger(
              title: 'Heat Exchanger 1',
              buttonLabels: ['TI5', 'TI6', 'TI8'], // Added TI8 as an example
              //bottomButtonLabel: '',
            ),
          ),
          Positioned(
            left: 80,
            bottom: 130,
            child: HeatExchanger(
              title: 'Heat Exchanger 2',
              buttonLabels: ['TI18'],
              bottomButtonLabel: 'TI20',
            ),
          ),
          Positioned(
            right: 60,
            bottom: 8,
            child: Chiller(
              buttonLabels: ['TI4', 'TI7', 'TI9'],
              topLabel: '',
              chillerName: 'Chiller 2',
            ),
          ),
          Positioned(
            right: 60,
            top: 20,
            child: Chiller(buttonLabels: ['TI1'], chillerName: 'Chiller 1'),
          ),
          Positioned(
            left: 100,
            bottom: 20,
            child: Chiller(
              buttonLabels: ['TI19', 'TI21', 'TI22'], // Added TI19 here
              chillerName: 'Chiller 3',
            ),
          ),
          Positioned(right: 400, top: 200, child: HeatingCoil()),
          Positioned(left: 630, top: 200, child: NonReturningValve()),
          Positioned(left: 550, bottom: 32, child: NonReturningValve()),
          // Homogenizer with TI15, TI16, TI17
          Positioned(
            left: 100,
            top: 180,
            child: Homogenizer(animation: _homogenizerAnimation),
          ),
          Positioned(left: 470, top: 230, child: Valve(showTempButton: false)),
          Positioned(
            left: 470,
            bottom: 50,
            child: Valve(showTempButton: false),
          ),
          Positioned(
            left: 570,
            bottom: 180,
            child: Valve(showTempButton: true),
          ),
          Positioned(
            right: 60,
            bottom: 100,
            child: pump.PumpControl(
              pumpNumber: 1,
              isActive: pump1Active,
              onToggle: (value) => setState(() => pump1Active = value),
            ),
          ),
          Positioned(
            right: 265,
            bottom: 100,
            child: pump.PumpControl(
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
