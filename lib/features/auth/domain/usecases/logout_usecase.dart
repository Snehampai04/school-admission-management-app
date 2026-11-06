  
import 'package:dartz/dartz.dart';

import 'package:school_admission_app/core/errors/failures.dart';
import 'package:school_admission_app/core/usecases/usecase.dart';

import '../repositories/auth_repository.dart';

class LogoutUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.logout();
  }
}
