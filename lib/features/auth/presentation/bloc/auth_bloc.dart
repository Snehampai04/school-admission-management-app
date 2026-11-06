
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_parent_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterParentUseCase registerParentUseCase;
  final LoginUseCase loginUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final LogoutUseCase logoutUseCase;

  AuthBloc({
    required this.registerParentUseCase,
    required this.loginUseCase,
    required this.getCurrentUserUseCase,
    required this.logoutUseCase,
  }) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<RegisterParentRequested>(_onRegisterParentRequested);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final result = await getCurrentUserUseCase(
        const NoParams(),
      );

      result.fold(
        (failure) {
          emit(AuthError(failure: failure));
        },
        (user) {
          if (user == null) {
            emit(const Unauthenticated());
          } else {
            emit(Authenticated(user));
          }
        },
      );
    } catch (e) {
      emit(
        const AuthError(
          failure: ServerFailure(
            'Unable to verify your account. Please try again.',
          ),
        ),
      );
    }
  }

  Future<void> _onRegisterParentRequested(
    RegisterParentRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await registerParentUseCase(
      RegisterParentParams(
        name: event.name,
        email: event.email,
        password: event.password,
      ),
    );

    await result.fold(
      (failure) async {
        emit(AuthError(failure: failure));
      },
      (registeredUser) async {
        final verification = await getCurrentUserUseCase(
          const NoParams(),
        );

        await verification.fold(
          (failure) async {
            await logoutUseCase(const NoParams());
            emit(AuthError(failure: failure));
          },
          (verifiedUser) async {
            if (verifiedUser == null) {
              emit(
                const AuthError(
                  failure: AuthFailure(
                    'Registration succeeded, but account verification failed.',
                  ),
                ),
              );
              return;
            }

            emit(Authenticated(verifiedUser));
          },
        );
      },
    );
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await loginUseCase(
      LoginParams(
        email: event.email,
        password: event.password,
      ),
    );

    await result.fold(
      (failure) async {
        emit(AuthError(failure: failure));
      },
      (user) async {
        if (user.role != event.selectedRole) {
          final logoutResult = await logoutUseCase(
            const NoParams(),
          );

          logoutResult.fold(
            (failure) {
              emit(
                AuthError(
                  failure: failure,
                  previousUser: user,
                ),
              );
            },
            (_) {
              emit(
                const AuthError(
                  failure: AuthFailure(
                    'The selected login type does not match your account role.',
                  ),
                ),
              );
            },
          );

          return;
        }

        emit(Authenticated(user));
      },
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    UserEntity? currentUser;

    if (state is Authenticated) {
      currentUser = (state as Authenticated).user;
    } else if (state is AuthError) {
      currentUser = (state as AuthError).previousUser;
    }

    if (currentUser == null) return;

    emit(AuthLoggingOut(currentUser));

    final result = await logoutUseCase(
      const NoParams(),
    );

    result.fold(
      (failure) {
        emit(
          AuthError(
            failure: failure,
            previousUser: currentUser,
          ),
        );
      },
      (_) => emit(const Unauthenticated()),
    );
  }
}
