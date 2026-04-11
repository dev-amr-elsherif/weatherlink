class WeatherModel {
  final double temperature;
  final double humidity;
  final int rainfall;
  final int lightRaw;
  final int awning;
  final int fan;
  final int light;
  final int autoMode;

  WeatherModel({
    required this.temperature,
    required this.humidity,
    required this.rainfall,
    required this.lightRaw,
    required this.awning,
    required this.fan,
    required this.light,
    required this.autoMode,
  });

  factory WeatherModel.fromBlynk(
    double v0, double v1, int v2, int v3, int v4, int v5, int v6, int v7) {
    return WeatherModel(
      temperature: v0,
      humidity: v1,
      rainfall: v2,
      lightRaw: v3,
      awning: v4,
      fan: v5,
      light: v6,
      autoMode: v7,
    );
  }
}
