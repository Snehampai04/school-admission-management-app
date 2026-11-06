import 'package:school_admission_app/core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:school_admission_app/core/errors/failures.dart';

import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterParentUseCase
    implements UseCase<UserEntity, RegisterParentParams> {
  final AuthRepository repository;

  RegisterParentUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(RegisterParentParams params) {
    return repository.registerParent(
      name: params.name,
      email: params.email,
      password: params.password,
    );
  } 
}

class RegisterParentParams {
  final String name;
  final String email;
  final String password;

  const RegisterParentParams({
    required this.name,
    required this.email,
    required this.password,
  });
}
