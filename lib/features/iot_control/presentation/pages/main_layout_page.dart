import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/iot_bloc.dart';
import 'controls_view.dart';
import 'dashboard_view.dart';
import 'settings_view.dart';

class MainLayoutPage extends StatefulWidget {
  const MainLayoutPage({super.key});

  @override
  State<MainLayoutPage> createState() => _MainLayoutPageState();
}

class _MainLayoutPageState extends State<MainLayoutPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomNavPadding = (screenWidth * 0.05).clamp(16.0, 32.0);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0B0C10), // deep rich tech base restored
            Color(0xFF1F2833), // ambient secondary slate restored
            Color(0xFF050505), // pure dark void restored
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('SMART IOT PROTOCOL'),
          actions: [
            IconButton(
              icon: const Icon(Icons.sensors_rounded),
              tooltip: 'Simulate Telemetry Stream',
              onPressed: () {
                context.read<IotBloc>().add(
                      const UpdateSensorsEvent(
                        temperature: 24.2,
                        humidity: 55.4,
                        rainLevel: 8,
                        lightLevel: 88,
                      ),
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Color(0xE600E5FF),
                    content: Text(
                      'SIMULATED TELEMETRY STREAM COMMITTED',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF000000)),
                    ),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: BlocBuilder<IotBloc, IotState>(
          builder: (context, state) {
            return IndexedStack(
              index: _currentIndex,
              children: [
                DashboardView(state: state),
                ControlsView(state: state),
                const SettingsView(),
              ],
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: BlocBuilder<IotBloc, IotState>(
          builder: (context, state) {
            final fabColor = state.isAutoMode ? const Color(0xFF00E5FF) : const Color(0xFF9D00FF);
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: fabColor,
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: () {
                  context.read<IotBloc>().add(ToggleModeEvent(isAutoMode: !state.isAutoMode));
                },
                elevation: 0,
                backgroundColor: fabColor,
                foregroundColor: state.isAutoMode ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                icon: Icon(
                  state.isAutoMode ? Icons.smart_toy_rounded : Icons.pan_tool_rounded,
                ),
                label: Text(
                  state.isAutoMode ? 'auto'.tr().toUpperCase() : 'manual'.tr().toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
                ),
              ),
            );
          },
        ),
        extendBody: true,
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(left: bottomNavPadding, right: bottomNavPadding, bottom: 24.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
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
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  selectedItemColor: colorScheme.primary,
                  unselectedItemColor: const Color(0x66FFFFFF),
                  showUnselectedLabels: true,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  unselectedLabelStyle: const TextStyle(letterSpacing: 1.0),
                  items: [
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.dashboard_rounded),
                      activeIcon: _buildGlowingIcon(Icons.dashboard_rounded, colorScheme.primary),
                      label: 'dashboard'.tr().toUpperCase(),
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.tune_rounded),
                      activeIcon: _buildGlowingIcon(Icons.tune_rounded, colorScheme.primary),
                      label: 'actuators'.tr().toUpperCase(),
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.settings_rounded),
                      activeIcon: _buildGlowingIcon(Icons.settings_rounded, colorScheme.primary),
                      label: 'config'.tr().toUpperCase(),
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

  Widget _buildGlowingIcon(IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(0x66), // Glowing active effect
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(icon, color: color),
    );
  }
}
