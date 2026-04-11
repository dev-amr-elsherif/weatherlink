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
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: AnimatedContainer(
              duration: const Duration(seconds: 1),
              padding: const EdgeInsets.only(top: 80, bottom: 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: controller.heroGradient,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: alertColor.withAlpha(50),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: alertColor.withAlpha(100)),
                    ),
                    child: Text(
                      controller.systemStatus,
                      style: TextStyle(
                        color: alertColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.temperature.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 120,
                          fontWeight: FontWeight.w200,
                          color: Colors.white,
                          height: 1.0,
                          letterSpacing: -5,
                        ),
                      ),
                      const Text(
                        '°C',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w400,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: controller.lightRange == "Bright" 
                              ? Colors.yellowAccent 
                              : (controller.lightRange == "Dim" ? Colors.orangeAccent : Colors.grey),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Light: ${controller.lightRange}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text(
                  'CONTROL PANEL',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white54,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E).withAlpha(150),
                    borderRadius: BorderRadius.circular(20),
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
                const SizedBox(height: 16),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isAuto ? 0.4 : 1.0,
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.mode_fan_off_outlined,
                          label: 'Fan',
                          isActive: data.fan == 1,
                          isAuto: isAuto,
                          onTap: () => controller.toggleAction('v5', data.fan == 1 ? 0 : 1),
                        ),
                      ),
                      const SizedBox(width: 12),
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
                const SizedBox(height: 32),
                const Text(
                  'SECONDARY STATS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white54,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: WeatherCard(
                        title: 'Humidity',
                        value: data.humidity.toStringAsFixed(0),
                        unit: '%',
                        icon: Icons.water_drop_outlined,
                        color: Colors.cyanAccent,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: WeatherCard(
                        title: 'Rainfall',
                        value: data.rainfall.toString(),
                        unit: '%',
                        icon: Icons.waves,
                        color: Colors.indigoAccent,
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        decoration: BoxDecoration(
          color: isActive ? Colors.cyanAccent.withAlpha(40) : const Color(0xFF1E1E1E).withAlpha(150),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? Colors.cyanAccent.withAlpha(100) : Colors.white.withAlpha(20),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: isActive ? Colors.cyanAccent : Colors.white54),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.cyanAccent : Colors.white54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


