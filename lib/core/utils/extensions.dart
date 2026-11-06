import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

/// Dart extension methods used across the app.
extension StringExtensions on String {
  /// Capitalises the first letter and lowercases the rest.
  String get capitalised =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';

  /// Returns true if the string is a valid email format.
  bool get isValidEmail {
    final regex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(trim());
  }

  /// Trims and returns null if empty.
  String? get trimOrNull {
    final trimmed = trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

extension NullableStringExtensions on String? {
  /// Returns `'—'` if null or empty, otherwise the trimmed value.
  String get orDash {
    if (this == null || this!.trim().isEmpty) return '—';
    return this!.trim();
  }
}

extension DateTimeExtensions on DateTime {
  /// Returns true if [this] is the same calendar day as [other].
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;
}

extension BuildContextExtensions on BuildContext {
  // ── Theme shortcuts ───────────────────────────────────────────────────────
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // ── Screen size ───────────────────────────────────────────────────────────
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  // ── Keyboard ──────────────────────────────────────────────────────────────
  void hideKeyboard() => FocusScope.of(this).unfocus();
}

extension ApplicationStatusExtension on String {
  /// Returns the step index (0-based) for the admission progress timeline.
  int get statusStepIndex {
    switch (this) {
      case AppConstants.statusApplicationCreated:
        return 0;
      case AppConstants.statusSlotBooked:
        return 1;
      case AppConstants.statusExamCompleted:
        return 2;
      case AppConstants.statusAdmissionCompleted:
        return 3;
      default:
        return 0;
    }
  }

  /// Returns the display colour for a given application status.
  Color get statusColor {
    switch (this) {
      case AppConstants.statusApplicationCreated:
        return AppColors.statusCreated;
      case AppConstants.statusSlotBooked:
        return AppColors.statusSlotBooked;
      case AppConstants.statusExamCompleted:
        return AppColors.statusExamCompleted;
      case AppConstants.statusAdmissionCompleted:
        return AppColors.statusAdmitted;
      default:
        return AppColors.textSecondary;
    }
  }

  /// Returns the display colour for a payment status.
  Color get paymentStatusColor {
    switch (this) {
      case AppConstants.paymentPaid:
        return AppColors.success;
      case AppConstants.paymentSkipped:
        return AppColors.textSecondary;
      case AppConstants.paymentPending:
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }
}
