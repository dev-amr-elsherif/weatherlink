import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/iot_bloc.dart';
import 'actuators/awning_detail_screen.dart';
import 'actuators/fan_detail_screen.dart';
import 'actuators/light_detail_screen.dart';

class ControlsView extends StatelessWidget {
  final IotState state;

  const ControlsView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      children: [
        _buildSectionTitle(context, 'actuators'.tr()),
        const SizedBox(height: 16),

        // Auto mode visual feedback
        if (state.isAutoMode)
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0x26FF1744),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x66FF1744)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline_rounded, color: Color(0xFFFF1744), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'MANUAL OVERRIDE LOCKED IN AUTO MODE',
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

        // Card 1: Awning System
        _buildActuatorCard(
          context,
          title: 'awning'.tr().toUpperCase(),
          valueText: '${state.awningPosition.toInt()}%',
          icon: Icons.roofing_rounded,
          heroTag: 'hero_awning_icon',
          accentColor: const Color(0xFF00E5FF),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<IotBloc>(),
                  child: const AwningDetailScreen(),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),

        // Card 2: Ventilation (Fan)
        _buildActuatorCard(
          context,
          title: 'fan'.tr().toUpperCase(),
          valueText: '${state.fanSpeed.toInt()} RPM',
          icon: Icons.air_rounded,
          heroTag: 'hero_fan_icon',
          accentColor: const Color(0xFF00E5FF),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<IotBloc>(),
                  child: const FanDetailScreen(),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),

        // Card 3: Smart Radiance
        _buildActuatorCard(
          context,
          title: 'smart_lights'.tr().toUpperCase(),
          valueText: '${state.smartLightsLevel.toInt()} / 8 PAIRS',
          icon: Icons.lightbulb_rounded,
          heroTag: 'hero_light_icon',
          accentColor: const Color(0xFF00E5FF),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<IotBloc>(),
                  child: const LightDetailScreen(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String text) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x4000E5FF),
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
              fontSize: 16,
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

  Widget _buildActuatorCard(
    BuildContext context, {
    required String title,
    required String valueText,
    required IconData icon,
    required String heroTag,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0x1AFFFFFF), // Semi-transparent glassmorphism core
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0x33FFFFFF), width: 1),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                child: Row(
                  children: [
                    // Hero wrapped badge Icon
                    Hero(
                      tag: heroTag,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0x1A000000),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x4000E5FF),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          size: 32,
                          color: accentColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            valueText,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00E5FF),
                              shadows: [
                                Shadow(color: Color(0x6600E5FF), blurRadius: 4),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0x80FFFFFF),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
