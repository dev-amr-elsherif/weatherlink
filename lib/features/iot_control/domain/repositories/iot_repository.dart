import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class IotRepository {
  Future<Either<Failure, Map<String, dynamic>>> fetchAllSensors();
  Future<Either<Failure, void>> updateDeviceState(String pin, dynamic value);
}
