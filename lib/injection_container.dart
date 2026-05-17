import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'features/iot_control/data/datasources/blynk_remote_data_source.dart';
import 'features/iot_control/data/repositories/iot_repository_impl.dart';
import 'features/iot_control/domain/repositories/iot_repository.dart';
import 'features/iot_control/domain/usecases/fetch_sensors_usecase.dart';
import 'features/iot_control/domain/usecases/update_device_state_usecase.dart';
import 'features/iot_control/presentation/bloc/iot_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());

  //! Core

  //! Features - iot_control
  // Bloc
  sl.registerFactory(() => IotBloc(
        fetchSensorsUseCase: sl(),
        updateDeviceStateUseCase: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => FetchSensorsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateDeviceStateUseCase(sl()));

  // Repository
  sl.registerLazySingleton<IotRepository>(
    () => IotRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<BlynkRemoteDataSource>(
    () => BlynkRemoteDataSourceImpl(client: sl()),
  );
}
