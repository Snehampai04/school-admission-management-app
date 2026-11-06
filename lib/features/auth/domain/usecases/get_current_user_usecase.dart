
import 'package:dartz/dartz.dart';

import 'package:school_admission_app/core/errors/failures.dart';
import 'package:school_admission_app/core/usecases/usecase.dart';

import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase
    implements UseCase<UserEntity?, NoParams> {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity?>> call(NoParams params) {
    return repository.getCurrentUser();
  }
}
