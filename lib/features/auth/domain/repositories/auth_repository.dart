  import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  // Register a new parent account.
  Future<Either<Failure, UserEntity>> registerParent({
    required String name,
    required String email,
    required String password,
  });

  // Login using email and password.
  Future<Either<Failure, UserEntity>> loginWithEmail({
    required String email,
    required String password,
  });

  // Get the currently logged-in user.
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  // Logout the current user.
  Future<Either<Failure, void>> logout();
} 