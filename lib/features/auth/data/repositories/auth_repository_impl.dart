    
import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
  });

  Failure _mapException(Object error) {
    if (error is AppException) {
      return error.toFailure();
    }

    return const ServerException(
      'An unexpected error occurred. Please try again.',
    ).toFailure();
  }

  @override
  Future<Either<Failure, UserEntity>> registerParent({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.registerParent(
        name: name,
        email: email,
        password: password,
      );

      return Right(user);
    } catch (error) {
      return Left(_mapException(error));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.loginWithEmail(
        email: email,
        password: password,
      );

      return Right(user);
    } catch (error) {
      return Left(_mapException(error));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();

      return Right(user);
    } catch (error) {
      return Left(_mapException(error));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();

      return const Right(null);
    } catch (error) {
      return Left(_mapException(error));
    }
  }
}
  