import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/weather_model.dart';

class WeatherController extends ChangeNotifier {
  WeatherModel? weatherData;
  bool isLoading = false;
  String? errorMessage;
  Timer? _timer;

  String get lightRange {
    if (weatherData == null) return "Unknown";
    final v3 = weatherData!.lightRaw;
    if (v3 < 50) return "Dark";
    if (v3 <= 150) return "Dim";
    return "Bright";
  }

  LinearGradient get heroGradient {
    if (lightRange == "Bright") {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0277BD), Color(0xFF00BCD4)],
      );
    }
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF102027), Color(0xFF263238)],
    );
  }

  String get systemStatus {
    if (weatherData == null) return "SYSTEM NORMAL";
    if (weatherData!.rainfall > 80) return "ALERT: HEAVY RAIN";
    if (weatherData!.temperature > 35) return "WARNING: HIGH HEAT";
    return "SYSTEM NORMAL";
  }

  void startAutoRefresh() {
    fetchWeatherData();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      fetchWeatherData(isBackgroundRefresh: true);
    });
  }

  void stopAutoRefresh() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }

  Future<void> fetchWeatherData({bool isBackgroundRefresh = false}) async {
    if (!isBackgroundRefresh) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
    }

    try {
      final url = Uri.parse(
        'https://blynk.cloud/external/api/get?token=QTbml8OyLxCcCqRNFZ9Xh9Nw5cqy2Mll&v0&v1&v2&v3&v4&v5&v6&v7',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final temp = double.tryParse(data['v0']?.toString() ?? '0') ?? 0.0;
        final hum = double.tryParse(data['v1']?.toString() ?? '0') ?? 0.0;
        final rain = int.tryParse(data['v2']?.toString() ?? '0') ?? 0;
        final lightRaw = int.tryParse(data['v3']?.toString() ?? '0') ?? 0;
        final awning = int.tryParse(data['v4']?.toString() ?? '0') ?? 0;
        final fan = int.tryParse(data['v5']?.toString() ?? '0') ?? 0;
        final light = int.tryParse(data['v6']?.toString() ?? '0') ?? 0;
        final autoMode = int.tryParse(data['v7']?.toString() ?? '0') ?? 0;

        weatherData = WeatherModel.fromBlynk(
            temp, hum, rain, lightRaw, awning, fan, light, autoMode);
        errorMessage = null;
      } else {
        errorMessage =
            'Failed to load weather data. Status: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage = 'Error fetching data: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleAction(String vPin, int value) async {
    // Optimistic UI Update
    if (weatherData != null) {
      weatherData = WeatherModel(
        temperature: weatherData!.temperature,
        humidity: weatherData!.humidity,
        rainfall: weatherData!.rainfall,
        lightRaw: weatherData!.lightRaw,
        awning: vPin == 'v4' ? value : weatherData!.awning,
        fan: vPin == 'v5' ? value : weatherData!.fan,
        light: vPin == 'v6' ? value : weatherData!.light,
        autoMode: vPin == 'v7' ? value : weatherData!.autoMode,
      );
      notifyListeners();
    }

    final url = Uri.parse(
      'https://blynk.cloud/external/api/update?token=QTbml8OyLxCcCqRNFZ9Xh9Nw5cqy2Mll&$vPin=$value',
    );
    try {
      await http.get(url);
    } catch (e) {
      // Ignore
    }
  }
}
