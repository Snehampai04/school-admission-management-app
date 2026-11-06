import 'failures.dart';

// ── Base Exception ────────────────────────────────────────────────────────────

/// Base exception thrown in the data layer and converted to [Failure] at the
/// repository boundary.  Every concrete exception maps to exactly one Failure.
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);

  Failure toFailure();

  @override
  String toString() => '$runtimeType: $message';
}

// ── Concrete Exceptions ───────────────────────────────────────────────────────

class ServerException extends AppException {
  const ServerException(super.message);
  @override
  Failure toFailure() => ServerFailure(message);
}

class AuthException extends AppException {
  const AuthException(super.message);
  @override
  Failure toFailure() => AuthFailure(message);
}

class NetworkException extends AppException {
  const NetworkException(super.message);
  @override
  Failure toFailure() => NetworkFailure(message);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
  @override
  Failure toFailure() => ValidationFailure(message);
}

class PermissionException extends AppException {
  const PermissionException(super.message);
  @override
  Failure toFailure() => PermissionFailure(message);
}

class SlotFullException extends AppException {
  const SlotFullException([
    super.message = 'This exam slot is fully booked. Please choose another.',
  ]);
  @override
  Failure toFailure() => SlotFullFailure(message);
}

class DuplicateBookingException extends AppException {
  const DuplicateBookingException([
    super.message = 'A slot has already been booked for this student.',
  ]);
  @override
  Failure toFailure() => DuplicateBookingFailure(message);
}

class OwnershipException extends AppException {
  const OwnershipException([
    super.message = 'You do not have permission to perform this action.',
  ]);
  @override
  Failure toFailure() => OwnershipFailure(message);
}

class EditNotAllowedException extends AppException {
  const EditNotAllowedException([
    super.message =
        'Student details cannot be edited after a slot has been booked.',
  ]);
  @override
  Failure toFailure() => EditNotAllowedFailure(message);
}

class NotFoundException extends AppException {
  const NotFoundException([
    super.message = 'The requested record was not found.',
  ]);
  @override
  Failure toFailure() => NotFoundFailure(message);
}

class AlreadyBookedException extends AppException {
  const AlreadyBookedException([
    super.message =
        'This student has already progressed past slot booking.',
  ]);
  @override
  Failure toFailure() => AlreadyBookedFailure(message);
}
