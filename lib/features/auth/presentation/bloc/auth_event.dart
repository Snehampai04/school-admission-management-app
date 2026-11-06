
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// Check whether a user is already logged in.
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

// Register a new parent account.
class RegisterParentRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const RegisterParentRequested({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

// Login using email and password.
class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  final String selectedRole;

  const LoginRequested({
    required this.email,
    required this.password,
    required this.selectedRole,
  });

  @override
  List<Object?> get props => [email, password, selectedRole];
}

// Logout the current user.
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
