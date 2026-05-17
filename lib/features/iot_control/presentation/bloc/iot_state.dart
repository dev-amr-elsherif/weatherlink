import 'package:equatable/equatable.dart';

class IotState extends Equatable {
  final double temperature;
  final double humidity;
  final int rainLevel;
  final int lightLevel;
  final bool isAutoMode;
  
  // Manual Controls fields
  final double awningPosition; // 0 to 100
  final double fanSpeed; // 0 to 255
  final double smartLightsLevel; // 0 to 8

  const IotState({
    this.temperature = 0.0,
    this.humidity = 0.0,
    this.rainLevel = 0,
    this.lightLevel = 0,
    this.isAutoMode = true,
    this.awningPosition = 0.0,
    this.fanSpeed = 0.0,
    this.smartLightsLevel = 0.0,
  });

  IotState copyWith({
    double? temperature,
    double? humidity,
    int? rainLevel,
    int? lightLevel,
    bool? isAutoMode,
    double? awningPosition,
    double? fanSpeed,
    double? smartLightsLevel,
  }) {
    return IotState(
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      rainLevel: rainLevel ?? this.rainLevel,
      lightLevel: lightLevel ?? this.lightLevel,
      isAutoMode: isAutoMode ?? this.isAutoMode,
      awningPosition: awningPosition ?? this.awningPosition,
      fanSpeed: fanSpeed ?? this.fanSpeed,
      smartLightsLevel: smartLightsLevel ?? this.smartLightsLevel,
    );
  }

  @override
  List<Object?> get props => [
        temperature,
        humidity,
        rainLevel,
        lightLevel,
        isAutoMode,
        awningPosition,
        fanSpeed,
        smartLightsLevel,
      ];
}
