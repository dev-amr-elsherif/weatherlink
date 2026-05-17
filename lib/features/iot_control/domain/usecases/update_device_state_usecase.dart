import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/iot_repository.dart';

class UpdateDeviceStateUseCase {
  final IotRepository repository;

  UpdateDeviceStateUseCase(this.repository);

  Future<Either<Failure, void>> call(String pin, dynamic value) {
    return repository.updateDeviceState(pin, value);
  }
}
