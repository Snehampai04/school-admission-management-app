import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

// ── Base Use Case ─────────────────────────────────────────────────────────────

/// Generic use case abstraction.
///
/// [T] — the success return type.
/// [Params] — the input parameter type (use [NoParams] for no inputs).
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

// ── NoParams ──────────────────────────────────────────────────────────────────

/// Use when a use case takes no parameters.        
///
/// Example:
/// ```dart
/// class GetCurrentUserUseCase extends UseCase<UserEntity, NoParams> { ... }
/// final result = await useCase(const NoParams());
/// ```
class NoParams {
  const NoParams();
}
