
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// Initial application state.
class AuthInitial extends AuthState {
  const AuthInitial();
}

// Authentication operation is in progress.
class AuthLoading extends AuthState {
  const AuthLoading();
}

// A user has successfully authenticated.
class Authenticated extends AuthState {
  final UserEntity user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

// No authenticated user exists.
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

// Logout is in progress, but preserve the current user.
class AuthLoggingOut extends AuthState {
  final UserEntity user;

  const AuthLoggingOut(this.user);

  @override
  List<Object?> get props => [user];
}

// Authentication failed.
// previousUser preserves the session when an operation
// such as logout fails.
class AuthError extends AuthState {
  final Failure failure;
  final UserEntity? previousUser;

  const AuthError({
    required this.failure,
    this.previousUser,
  });

  @override
  List<Object?> get props => [failure, previousUser];
}
