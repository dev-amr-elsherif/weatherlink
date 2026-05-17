import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../bloc/iot_bloc.dart';
import '../widgets/sensor_card.dart';
import '../widgets/shimmer_bento.dart';

class DashboardView extends StatelessWidget {
  final IotState state;

  const DashboardView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isPolling = state.temperature == 0.0 && state.humidity == 0.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive Spacing & Sizing
    final double paddingHorizontal = (screenWidth * 0.04).clamp(16.0, 32.0);
    final double primaryCardHeight = (screenHeight * 0.32).clamp(240.0, 340.0);
    final double secondaryCardHeight = (screenHeight * 0.22).clamp(160.0, 220.0);

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: 20.0),
      children: [
        // Sleek Technical Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: 8.0),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              Text(
                'welcome_user'.tr().toUpperCase(),
                style: TextStyle(
                  fontSize: (screenWidth * 0.04).clamp(12.0, 16.0),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: colorScheme.primary,
                  shadows: const [Shadow(color: Color(0x6600E5FF), blurRadius: 4)],
                ),
              ),
              Text(
                '|',
                style: TextStyle(
                  color: const Color(0x66FFFFFF), 
                  fontSize: (screenWidth * 0.045).clamp(14.0, 18.0),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded, 
                    color: const Color(0xFF00E676), 
                    size: (screenWidth * 0.04).clamp(12.0, 16.0),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'systems_optimal'.tr().toUpperCase(),
                    style: TextStyle(
                      fontSize: (screenWidth * 0.035).clamp(10.0, 14.0),
                      color: const Color(0xB3FFFFFF),
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: (screenHeight * 0.03).clamp(16.0, 32.0)),
        
        // Bento Grid Layout
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              // Primary Large Bento Module
              ShimmerBento(
                isLoading: isPolling,
                child: isPolling 
                  ? SkeletonBentoBox(height: primaryCardHeight)
                  : SizedBox(
                      height: primaryCardHeight,
                      child: SensorCard(
                        isLarge: true,
                        title: 'temp'.tr().toUpperCase(),
                        value: '${state.temperature.toStringAsFixed(1)}°C',
                        icon: Icons.thermostat_rounded,
                        color: const Color(0xFF00E5FF),
                        secondaryTitle: 'humidity'.tr().toUpperCase(),
                        secondaryValue: '${state.humidity.toStringAsFixed(1)}%',
                        secondaryIcon: Icons.water_drop_rounded,
                        sparklineData: [
                          state.temperature * 0.8,
                          state.temperature * 0.9,
                          state.temperature * 1.1,
                          state.temperature * 1.0,
                          state.temperature * 1.2,
                          state.temperature * 1.05,
                          state.temperature, // Current value at the end
                        ],
                      ),
                    ),
              ),
              const SizedBox(height: 16),
              // Secondary Bento Modules
              Row(
                children: [
                  Expanded(
                    child: ShimmerBento(
                      isLoading: isPolling,
                      child: isPolling 
                        ? SkeletonBentoBox(height: secondaryCardHeight)
                        : SizedBox(
                            height: secondaryCardHeight,
                            child: SensorCard(
                              title: 'rain'.tr().toUpperCase(),
                              value: '${state.rainLevel}%',
                              icon: Icons.grain_rounded,
                              color: const Color(0xFF00E5FF),
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ShimmerBento(
                      isLoading: isPolling,
                      child: isPolling 
                        ? SkeletonBentoBox(height: secondaryCardHeight)
                        : SizedBox(
                            height: secondaryCardHeight,
                            child: SensorCard(
                              title: 'light_level'.tr().toUpperCase(),
                              value: '${state.lightLevel}%',
                              icon: Icons.lightbulb_outline_rounded,
                              color: const Color(0xFF00E5FF),
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
