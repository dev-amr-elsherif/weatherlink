import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/iot_bloc.dart';
import 'smart_light_ring.dart';

class ManualControlsPanel extends StatelessWidget {
  final bool isAutoMode;
  final IotState state;

  const ManualControlsPanel({
    super.key,
    required this.isAutoMode,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IgnorePointer(
      ignoring: isAutoMode,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        // Custom explicit alpha modulation via AnimatedOpacity native property
        opacity: isAutoMode ? 0.4 : 1.0,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          children: [
            _buildMinimalHeader(context, 'Hardware Actuation Matrix'),
            
            if (isAutoMode)
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0x26FF1744), // Strictly Hex with Alpha channel
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0x66FF1744)), // Strictly Hex with Alpha channel
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline_rounded, color: Color(0xFFFF1744), size: 18),
                      SizedBox(width: 8),
                      Text(
                        'MANUAL CONTROLS LOCKED IN AUTO MODE',
                        style: TextStyle(
                          color: Color(0xFFFF1744),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Minimalist solid premium controls container matching SensorCard layout system
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E24),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0x1AFFFFFF), width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x80000000), // Subtle minimal dark shadow
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Awning Slider
                  _buildSliderRow(
                    context,
                    label: 'AWNING POSITION',
                    value: state.awningPosition,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    valueLabel: '${state.awningPosition.toInt()}%',
                    icon: Icons.roofing_rounded,
                    reinforcementIcon: Icons.percent_rounded,
                    onChanged: (val) {
                      context.read<IotBloc>().add(
                            UpdateManualControlsEvent(awningPosition: val),
                          );
                    },
                    onChangeEnd: (val) {
                      context.read<IotBloc>().add(
                            UpdateManualControlEvent(pin: 'V4', value: val),
                          );
                    },
                  ),
                  const SizedBox(height: 32),
                  
                  // Fan Slider
                  _buildSliderRow(
                    context,
                    label: 'FAN VELOCITY',
                    value: state.fanSpeed,
                    min: 0,
                    max: 255,
                    divisions: 255,
                    valueLabel: state.fanSpeed.toInt().toString(),
                    icon: Icons.air_rounded,
                    reinforcementIcon: Icons.wind_power_rounded,
                    onChanged: (val) {
                      context.read<IotBloc>().add(
                            UpdateManualControlsEvent(fanSpeed: val),
                          );
                    },
                    onChangeEnd: (val) {
                      context.read<IotBloc>().add(
                            UpdateManualControlEvent(pin: 'V5', value: val),
                          );
                    },
                  ),
                  const SizedBox(height: 40),
                  
                  // Smart Light Ring Visualizer Section
                  Text(
                    'NEOPIXEL MATRIX ARRAY',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      fontSize: 13,
                      color: colorScheme.secondary,
                      shadows: [
                        Shadow(color: const Color(0x409D00FF), blurRadius: 4), // Refined soft shadow
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SmartLightRing(activePairs: state.smartLightsLevel.toInt()),
                  const SizedBox(height: 32),
                  
                  // Smart Lights Slider
                  _buildSliderRow(
                    context,
                    label: 'SMART LIGHTS ACTIVE PAIRS',
                    value: state.smartLightsLevel,
                    min: 0,
                    max: 8,
                    divisions: 8,
                    valueLabel: '${state.smartLightsLevel.toInt()} / 8',
                    icon: Icons.lightbulb_rounded,
                    reinforcementIcon: Icons.lightbulb_outline_rounded,
                    onChanged: (val) {
                      context.read<IotBloc>().add(
                            UpdateManualControlsEvent(smartLightsLevel: val),
                          );
                    },
                    onChangeEnd: (val) {
                      context.read<IotBloc>().add(
                            UpdateManualControlEvent(pin: 'V6', value: val),
                          );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalHeader(BuildContext context, String text) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 20, top: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x4000E5FF), // Subtle minimal accent reflection
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text.toUpperCase(),
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              color: primaryColor,
              shadows: const [
                Shadow(color: Color(0x4000E5FF), blurRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow(
    BuildContext context, {
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String valueLabel,
    required IconData icon,
    IconData? reinforcementIcon,
    required ValueChanged<double> onChanged,
    required ValueChanged<double> onChangeEnd,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: colorScheme.secondary, size: 20),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  valueLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: colorScheme.primary,
                    shadows: const [
                      Shadow(color: Color(0x6600E5FF), blurRadius: 2), // Refined strict hex shadow
                    ],
                  ),
                ),
                if (reinforcementIcon != null) ...[
                  const SizedBox(width: 4),
                  Icon(reinforcementIcon, size: 14, color: const Color(0xCC00E5FF)),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            showValueIndicator: ShowValueIndicator.always,
            valueIndicatorTextStyle: const TextStyle(
              color: Color(0xFF000000),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            label: valueLabel,
            activeColor: colorScheme.primary,
            inactiveColor: const Color(0x14FFFFFF), // Strictly Hex with Alpha channel
            onChanged: isAutoMode ? null : onChanged,
            onChangeEnd: isAutoMode ? null : onChangeEnd,
          ),
        ),
      ],
    );
  }
}
