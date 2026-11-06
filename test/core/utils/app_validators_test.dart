
import 'package:flutter_test/flutter_test.dart';
import 'package:school_admission_app/core/utils/validators.dart';

void main() {
  group('AppValidators.email', () {
    test('accepts a valid email', () {
      expect(AppValidators.email('test@example.com'), isNull);
    });

    test('rejects an invalid email', () {
      expect(AppValidators.email('invalid-email'), isNotNull);
    });

    test('rejects an empty email', () {
      expect(AppValidators.email(''), isNotNull);
    });
  });

  group('AppValidators.password', () {
    test('accepts a password with at least 8 characters', () {
      expect(AppValidators.password('Password123'), isNull);
    });

    test('rejects a short password', () {
      expect(AppValidators.password('12345'), isNotNull);
    });
  });

  group('AppValidators.examScore', () {
    test('accepts a score between 0 and 100', () {
      expect(AppValidators.examScore('85'), isNull);
      expect(AppValidators.examScore('0'), isNull);
      expect(AppValidators.examScore('100'), isNull);
    });

    test('rejects a score above 100', () {
      expect(AppValidators.examScore('105'), isNotNull);
    });

    test('rejects a non-numeric score', () {
      expect(AppValidators.examScore('abc'), isNotNull);
    });
  });
}
