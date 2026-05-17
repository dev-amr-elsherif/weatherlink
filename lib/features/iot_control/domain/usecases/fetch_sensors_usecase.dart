import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/iot_repository.dart';

class FetchSensorsUseCase {
  final IotRepository repository;

  FetchSensorsUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call() {
    return repository.fetchAllSensors();
  }
}
