import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/fetch_sensors_usecase.dart';
import '../../domain/usecases/update_device_state_usecase.dart';
import 'iot_event.dart';
import 'iot_state.dart';

export 'iot_event.dart';
export 'iot_state.dart';

class IotBloc extends Bloc<IotEvent, IotState> {
  final FetchSensorsUseCase fetchSensorsUseCase;
  final UpdateDeviceStateUseCase updateDeviceStateUseCase;
  Timer? _pollingTimer;

  IotBloc({
    required this.fetchSensorsUseCase,
    required this.updateDeviceStateUseCase,
  }) : super(const IotState()) {
    on<UpdateSensorsEvent>(_onUpdateSensors);
    on<ToggleModeEvent>(_onToggleMode);
    on<UpdateManualControlsEvent>(_onUpdateManualControls);
    on<StartPollingEvent>(_onStartPolling);
    on<FetchRealDataEvent>(_onFetchRealData);
    on<UpdateManualControlEvent>(_onUpdateManualControl);
  }

  void _onUpdateSensors(UpdateSensorsEvent event, Emitter<IotState> emit) {
    emit(state.copyWith(
      temperature: event.temperature,
      humidity: event.humidity,
      rainLevel: event.rainLevel,
      lightLevel: event.lightLevel,
    ));
  }

  Future<void> _onToggleMode(ToggleModeEvent event, Emitter<IotState> emit) async {
    // Update remote pin V7
    await updateDeviceStateUseCase.call('V7', event.isAutoMode ? 1 : 0);
    emit(state.copyWith(
      isAutoMode: event.isAutoMode,
    ));
  }

  void _onUpdateManualControls(
    UpdateManualControlsEvent event,
    Emitter<IotState> emit,
  ) {
    emit(state.copyWith(
      awningPosition: event.awningPosition,
      fanSpeed: event.fanSpeed,
      smartLightsLevel: event.smartLightsLevel,
    ));
  }

  void _onStartPolling(StartPollingEvent event, Emitter<IotState> emit) {
    _pollingTimer?.cancel();
    // Fire immediately then every 2 seconds
    add(FetchRealDataEvent());
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      add(FetchRealDataEvent());
    });
  }

  Future<void> _onFetchRealData(FetchRealDataEvent event, Emitter<IotState> emit) async {
    final result = await fetchSensorsUseCase.call();
    result.fold(
      (failure) {
        // Leave state unchanged on fetch failure to prevent disruptive UI jitter
      },
      (data) {
        final v3Value = (data['lightLevel'] as num?)?.toDouble();
        final lightPercentage = v3Value != null
            ? ((v3Value / 4095.0) * 100).toInt().clamp(0, 100)
            : state.lightLevel;

        emit(state.copyWith(
          temperature: (data['temperature'] as num?)?.toDouble() ?? state.temperature,
          humidity: (data['humidity'] as num?)?.toDouble() ?? state.humidity,
          rainLevel: (data['rainLevel'] as num?)?.toInt() ?? state.rainLevel,
          lightLevel: lightPercentage,
          isAutoMode: data['isAutoMode'] as bool? ?? state.isAutoMode,
        ));
      },
    );
  }

  Future<void> _onUpdateManualControl(
    UpdateManualControlEvent event,
    Emitter<IotState> emit,
  ) async {
    await updateDeviceStateUseCase.call(event.pin, event.value);
    
    // Also sync state locally to ensure UI matches final committed server value
    double? awning;
    double? fan;
    double? lights;

    final valDouble = (event.value as num).toDouble();
    if (event.pin == 'V4') {
      awning = valDouble;
    } else if (event.pin == 'V5') {
      fan = valDouble;
    } else if (event.pin == 'V6') {
      lights = valDouble;
    }

    emit(state.copyWith(
      awningPosition: awning ?? state.awningPosition,
      fanSpeed: fan ?? state.fanSpeed,
      smartLightsLevel: lights ?? state.smartLightsLevel,
    ));
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}
