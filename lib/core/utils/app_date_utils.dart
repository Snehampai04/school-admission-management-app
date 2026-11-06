import 'package:intl/intl.dart';

/// Date/time formatting utilities used throughout the app.
class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _displayDate = DateFormat('dd MMM yyyy');
  static final DateFormat _displayDateTime = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat _shortDate = DateFormat('dd MMM');
  static final DateFormat _timeOnly = DateFormat('hh:mm a');
  static final DateFormat _isoDate = DateFormat('yyyy-MM-dd');

  /// Formats a [DateTime] as `12 Jan 2024`.
  static String formatDate(DateTime date) => _displayDate.format(date);

  /// Formats a [DateTime] as `12 Jan 2024, 09:00 AM`.
  static String formatDateTime(DateTime date) => _displayDateTime.format(date);

  /// Formats a [DateTime] as `12 Jan`.
  static String formatShortDate(DateTime date) => _shortDate.format(date);

  /// Formats a [DateTime] as `09:00 AM`.
  static String formatTime(DateTime date) => _timeOnly.format(date);

  /// Formats a [DateTime] as `2024-01-12`.
  static String formatIso(DateTime date) => _isoDate.format(date);

  /// Parses an ISO date string `yyyy-MM-dd` to [DateTime].
  static DateTime? parseIso(String value) {
    try {
      return _isoDate.parse(value);
    } catch (_) {
      return null;
    }
  }

  /// Returns the age in years from [dob] to today.
  static int calculateAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  /// Returns true if [date] is in the past.
  static bool isPast(DateTime date) => date.isBefore(DateTime.now());

  /// Returns true if [date] is in the future.
  static bool isFuture(DateTime date) => date.isAfter(DateTime.now());

  /// Formats a Firestore Timestamp-converted [DateTime] safely.
  /// Returns `'—'` if null.
  static String formatSafe(DateTime? date) =>
      date != null ? formatDate(date) : '—';
}
