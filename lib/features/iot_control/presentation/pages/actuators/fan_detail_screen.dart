import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weatherlink/features/iot_control/presentation/bloc/iot_bloc.dart';

class FanDetailScreen extends StatelessWidget {
  const FanDetailScreen({super.key});

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
            "${'fan'.tr().toUpperCase()} OVERRIDE",
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
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Hero(
                    tag: 'hero_fan_icon',
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0x1A00E5FF),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x4000E5FF),
                            blurRadius: 30,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.air_rounded,
                        size: (screenWidth * 0.25).clamp(80.0, 120.0),
                        color: const Color(0xFF00E5FF),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: (screenHeight * 0.05).clamp(24.0, 64.0)),

                Text(
                  'speed'.tr().toUpperCase(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.5,
                    color: colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.fanSpeed.toInt().toString(),
                  style: TextStyle(
                    fontSize: (screenWidth * 0.12).clamp(36.0, 64.0),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFFFFF),
                    shadows: const [
                      Shadow(color: Color(0x8000E5FF), blurRadius: 12),
                    ],
                  ),
                ),
                SizedBox(height: (screenHeight * 0.05).clamp(24.0, 64.0)),

                if (state.isAutoMode)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0x26FF1744),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0x66FF1744)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_outline_rounded, color: Color(0xFFFF1744), size: 20),
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
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0x1AFFFFFF),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(color: const Color(0x33FFFFFF), width: 1),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1A00E5FF),
                              blurRadius: 60,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 24.0, // Thicker track for thumb interaction
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 24.0),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 40.0),
                            showValueIndicator: ShowValueIndicator.always,
                            valueIndicatorTextStyle: const TextStyle(
                              color: Color(0xFF000000),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          child: Slider(
                            value: state.fanSpeed.clamp(0, 255),
                            min: 0,
                            max: 255,
                            divisions: 255,
                            label: state.fanSpeed.toInt().toString(),
                            activeColor: colorScheme.primary,
                            inactiveColor: const Color(0x1AFFFFFF),
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
