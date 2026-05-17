import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/iot_repository.dart';
import '../datasources/blynk_remote_data_source.dart';

class IotRepositoryImpl implements IotRepository {
  final BlynkRemoteDataSource remoteDataSource;

  IotRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> fetchAllSensors() async {
    try {
      final results = await Future.wait([
        remoteDataSource.getPinValue('V0'), // Temp
        remoteDataSource.getPinValue('V1'), // Hum
        remoteDataSource.getPinValue('V2'), // Rain
        remoteDataSource.getPinValue('V3'), // Light
        remoteDataSource.getPinValue('V7'), // Mode
      ]);

      final Map<String, dynamic> sensorData = {
        'temperature': results[0],
        'humidity': results[1],
        'rainLevel': results[2].toInt(),
        'lightLevel': results[3].toInt(),
        'isAutoMode': results[4] == 1.0, // Assuming 1.0 maps to true/auto mode
      };

      return Right(sensorData);
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateDeviceState(String pin, dynamic value) async {
    try {
      await remoteDataSource.updatePinValue(pin, value);
      return const Right(null);
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
