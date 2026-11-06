
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:school_admission_app/core/errors/failures.dart';
import 'package:school_admission_app/core/usecases/usecase.dart';
import 'package:school_admission_app/features/auth/domain/entities/user_entity.dart';
import 'package:school_admission_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:school_admission_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:school_admission_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:school_admission_app/features/auth/domain/usecases/register_parent_usecase.dart';
import 'package:school_admission_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_admission_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_admission_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_admission_app/features/auth/domain/repositories/auth_repository.dart';

class FakeGetCurrentUserUseCase extends GetCurrentUserUseCase {
  FakeGetCurrentUserUseCase(this.result) : super(_FakeAuthRepository());

  Either<Failure, UserEntity?> result;

  @override
  Future<Either<Failure, UserEntity?>> call(NoParams params) async => result;
}

// These are only placeholders for dependencies not used in these tests.
class FakeRegisterParentUseCase extends RegisterParentUseCase {
  FakeRegisterParentUseCase() : super(_FakeAuthRepository());
}

class FakeLoginUseCase extends LoginUseCase {
  FakeLoginUseCase() : super(_FakeAuthRepository());
}

class FakeLogoutUseCase extends LogoutUseCase {
  FakeLogoutUseCase() : super(_FakeAuthRepository());
}

class _FakeAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final testUser = UserEntity(
    uid: 'parent-001',
    email: 'parent@example.com',
    name: 'Test Parent',
    role: 'parent',
    createdAt: DateTime(2026, 1, 1),
  );

  late FakeGetCurrentUserUseCase fakeGetCurrentUser;
  late AuthBloc authBloc;

  setUp(() {
    fakeGetCurrentUser = FakeGetCurrentUserUseCase(
      Right<Failure, UserEntity?>(null),
    );

    authBloc = AuthBloc(
      registerParentUseCase: FakeRegisterParentUseCase(),
      loginUseCase: FakeLoginUseCase(),
      getCurrentUserUseCase: fakeGetCurrentUser,
      logoutUseCase: FakeLogoutUseCase(),
    );
  });

  tearDown(() async {
    await authBloc.close();
  });

  group('AuthCheckRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits loading and unauthenticated when no user exists',
      build: () {
        fakeGetCurrentUser.result = Right<Failure, UserEntity?>(null);
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthLoading(),
        const Unauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits loading and authenticated when a user exists',
      build: () {
        fakeGetCurrentUser.result =
            Right<Failure, UserEntity?>(testUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthLoading(),
        Authenticated(testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits AuthError when checking the current user fails',
      build: () {
        fakeGetCurrentUser.result = const Left<Failure, UserEntity?>(
          NetworkFailure('No internet connection.'),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthError(
          failure: NetworkFailure('No internet connection.'),
        ),
      ],
    );
  });
}
