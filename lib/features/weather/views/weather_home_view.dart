import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/weather_controller.dart';
import 'widgets/weather_card.dart';

class WeatherHomeView extends StatelessWidget {
  const WeatherHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<WeatherController>();

    if (controller.isLoading && controller.weatherData == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.cyanAccent),
        ),
      );
    }

    if (controller.errorMessage != null && controller.weatherData == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                controller.errorMessage!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: controller.fetchWeatherData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (controller.weatherData == null) {
      return const Scaffold(
        body: Center(child: Text('No data available')),
      );
    }

    final data = controller.weatherData!;
    final isAuto = data.autoMode == 1;

    Color alertColor = Colors.white;
    if (controller.systemStatus.startsWith("ALERT")) alertColor = Colors.redAccent;
    if (controller.systemStatus.startsWith("WARNING")) alertColor = Colors.orangeAccent;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: controller.fetchWeatherData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Hero Section
            AnimatedContainer(
              duration: const Duration(seconds: 1),
              padding: const EdgeInsets.fromLTRB(24, 100, 24, 60),
              decoration: BoxDecoration(
                gradient: controller.heroGradient,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(48),
                  bottomRight: Radius.circular(48),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(50),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: alertColor.withAlpha(40),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: alertColor.withAlpha(120)),
                    ),
                    child: Text(
                      controller.systemStatus,
                      style: TextStyle(
                        color: alertColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.temperature.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 130,
                          fontWeight: FontWeight.w200,
                          color: Colors.white,
                          height: 1.0,
                          letterSpacing: -6,
                        ),
                      ),
                      const Text(
                        '°C',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w400,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: controller.lightRange == "Bright" 
                              ? Colors.yellowAccent 
                              : (controller.lightRange == "Dim" ? Colors.orangeAccent : Colors.grey),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Light: ${controller.lightRange}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 2. Control Panel
                  const Text(
                    'CONTROL PANEL',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white54,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(10),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withAlpha(20)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'System Auto Mode',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Switch(
                          value: isAuto,
                          activeColor: Colors.cyanAccent,
                          onChanged: (val) {
                            controller.toggleAction('v7', val ? 1 : 0);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    opacity: isAuto ? 0.3 : 1.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.roofing,
                            label: 'Awning',
                            isActive: data.awning == 1,
                            isAuto: isAuto,
                            onTap: () => controller.toggleAction('v4', data.awning == 1 ? 0 : 1),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.mode_fan_off_outlined,
                            label: 'Fan',
                            isActive: data.fan == 1,
                            isAuto: isAuto,
                            onTap: () => controller.toggleAction('v5', data.fan == 1 ? 0 : 1),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.lightbulb_outline,
                            label: 'Light',
                            isActive: data.light == 1,
                            isAuto: isAuto,
                            onTap: () => controller.toggleAction('v6', data.light == 1 ? 0 : 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // 3. Secondary Stats
                  const Text(
                    'SECONDARY STATS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white54,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: WeatherCard(
                          title: 'Humidity',
                          value: data.humidity.toStringAsFixed(0),
                          unit: '%',
                          icon: Icons.cloud_outlined,
                          color: Colors.cyanAccent,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: WeatherCard(
                          title: 'Rainfall',
                          value: data.rainfall.toString(),
                          unit: '%',
                          icon: Icons.water_drop,
                          color: Colors.indigoAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required bool isAuto,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isAuto ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        decoration: BoxDecoration(
          color: isActive ? Colors.cyanAccent.withAlpha(30) : Colors.white.withAlpha(10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.cyanAccent.withAlpha(100) : Colors.white.withAlpha(20),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: isActive ? Colors.cyanAccent : Colors.white60),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.cyanAccent : Colors.white60,
                fontWeight: FontWeight.w600,
                fontSize: 15,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


