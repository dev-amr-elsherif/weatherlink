import 'package:equatable/equatable.dart';

abstract class IotEvent extends Equatable {
  const IotEvent();

  @override
  List<Object?> get props => [];
}

class UpdateSensorsEvent extends IotEvent {
  final double temperature;
  final double humidity;
  final int rainLevel;
  final int lightLevel;

  const UpdateSensorsEvent({
    required this.temperature,
    required this.humidity,
    required this.rainLevel,
    required this.lightLevel,
  });

  @override
  List<Object?> get props => [temperature, humidity, rainLevel, lightLevel];
}

class ToggleModeEvent extends IotEvent {
  final bool isAutoMode;

  const ToggleModeEvent({required this.isAutoMode});

  @override
  List<Object?> get props => [isAutoMode];
}

class UpdateManualControlsEvent extends IotEvent {
  final double? awningPosition;
  final double? fanSpeed;
  final double? smartLightsLevel;

  const UpdateManualControlsEvent({
    this.awningPosition,
    this.fanSpeed,
    this.smartLightsLevel,
  });

  @override
  List<Object?> get props => [awningPosition, fanSpeed, smartLightsLevel];
}

class StartPollingEvent extends IotEvent {}

class FetchRealDataEvent extends IotEvent {}

class UpdateManualControlEvent extends IotEvent {
  final String pin;
  final dynamic value;

  const UpdateManualControlEvent({required this.pin, required this.value});

  @override
  List<Object?> get props => [pin, value];
}
