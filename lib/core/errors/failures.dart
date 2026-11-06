import 'package:equatable/equatable.dart';

// ── Base Failure ──────────────────────────────────────────────────────────────

/// Base class for all domain-layer failures.
/// Every repository returns [Either<Failure, T>].
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// ── Concrete Failures ─────────────────────────────────────────────────────────

/// Generic server / Firebase error.
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Firebase Auth errors (wrong password, user not found, etc.).
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// No network connectivity.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Form / input validation error.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Action not permitted for the current user's role.
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

/// Exam slot is at full capacity.
class SlotFullFailure extends Failure {
  const SlotFullFailure(super.message);
}

/// Student already has a booking in a different slot.
class DuplicateBookingFailure extends Failure {
  const DuplicateBookingFailure(super.message);
}

/// The requesting parent does not own the targeted student record.
class OwnershipFailure extends Failure {
  const OwnershipFailure(super.message);
}

/// Student details cannot be edited after slot booking.
class EditNotAllowedFailure extends Failure {
  const EditNotAllowedFailure(super.message);
}

/// Requested Firestore document does not exist.
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Student already booked into a slot (status beyond Application Created).
class AlreadyBookedFailure extends Failure {
  const AlreadyBookedFailure(super.message);
}
