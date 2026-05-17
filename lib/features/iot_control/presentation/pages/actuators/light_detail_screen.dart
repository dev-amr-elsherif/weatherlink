import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weatherlink/features/iot_control/presentation/bloc/iot_bloc.dart';

import '../../widgets/smart_light_ring.dart';

class LightDetailScreen extends StatelessWidget {
  const LightDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF00E5FF)),
          onPressed: () => Navigator.pop(context),
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            "${'smart_lights'.tr().toUpperCase()} OVERRIDE",
            style: TextStyle(
              fontSize: (screenWidth * 0.045).clamp(16.0, 22.0),
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
      body: BlocBuilder<IotBloc, IotState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top massive Hero Icon
                Center(
                  child: Hero(
                    tag: 'hero_light_icon',
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0x1A00E5FF),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x4000E5FF),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.lightbulb_rounded,
                        size: (screenWidth * 0.16).clamp(48.0, 80.0),
                        color: const Color(0xFF00E5FF),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: (screenHeight * 0.03).clamp(16.0, 32.0)),

                // Front and center SmartLightRing visualizer taking up dominant screen space
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: SmartLightRing(
                        activePairs: state.smartLightsLevel.toInt(),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: (screenHeight * 0.03).clamp(16.0, 32.0)),

                // Auto mode alert or 0-8 active slider track
                if (state.isAutoMode)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x26FF1744),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0x66FF1744)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock_outline_rounded,
                          color: Color(0xFFFF1744),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              'SYSTEM LOCKED IN AUTO MODE',
                              style: TextStyle(
                                color: Color(0xFFFF1744),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x1AFFFFFF),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: const Color(0x33FFFFFF),
                          width: 1,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A00E5FF),
                            blurRadius: 40,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 20.0,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 24.0,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 40.0,
                          ),
                          showValueIndicator: ShowValueIndicator.always,
                          valueIndicatorTextStyle: const TextStyle(
                            color: Color(0xFF000000),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        child: Slider(
                          value: state.smartLightsLevel.clamp(0, 8),
                          min: 0,
                          max: 8,
                          divisions: 8,
                          label: '${state.smartLightsLevel.toInt()} / 8',
                          activeColor: colorScheme.primary,
                          inactiveColor: const Color(0x1AFFFFFF),
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
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
