/// Application-wide constants for the School Admission Management App.
library;

class AppConstants {
  AppConstants._();

  // ── App Identity ──────────────────────────────────────────────────────────
  static const String appName = 'School Admission';
  static const String appTagline = 'Manage admissions with ease';

  // ── Payment ───────────────────────────────────────────────────────────────
  static const double mockPaymentAmount = 500.0;
  static const String mockPaymentCurrency = '₹';

  // ── Exam Score ────────────────────────────────────────────────────────────
  static const int minExamScore = 0;
  static const int maxExamScore = 100;

  // ── Predefined Courses (Grades) ───────────────────────────────────────────
  /// Predefined applying grades / courses. No Firestore collection needed.
  static const List<String> availableGrades = [
    'Grade 1',
    'Grade 2',
    'Grade 3',
    'Grade 4',
  ];

  // ── Gender Options ────────────────────────────────────────────────────────
  static const List<String> genderOptions = ['Male', 'Female', 'Other'];

  // ── Application Statuses ──────────────────────────────────────────────────
  static const String statusApplicationCreated = 'Application Created';
  static const String statusSlotBooked = 'Slot Booked';
  static const String statusExamCompleted = 'Exam Completed';
  static const String statusAdmissionCompleted = 'Admission Completed';

  static const List<String> applicationStatuses = [
    statusApplicationCreated,
    statusSlotBooked,
    statusExamCompleted,
    statusAdmissionCompleted,
  ];

  // ── Payment Statuses ──────────────────────────────────────────────────────
  static const String paymentPending = 'Pending';
  static const String paymentPaid = 'Paid';
  static const String paymentSkipped = 'Skipped';

  // ── User Roles ────────────────────────────────────────────────────────────
  static const String roleParent = 'parent';
  static const String roleAdmin = 'admin';

  // ── Error Messages ────────────────────────────────────────────────────────
  static const String errGeneric = 'Something went wrong. Please try again.';
  static const String errNetwork = 'No internet connection. Please check your network.';
  static const String errSlotFull = 'This exam slot is fully booked. Please choose another.';
  static const String errDuplicateBooking =
      'A slot has already been booked for this student.';
  static const String errOwnership =
      'You do not have permission to perform this action.';
  static const String errEditNotAllowed =
      'Student details cannot be edited after a slot has been booked.';
  static const String errNotFound = 'The requested record was not found.';

  // ── Success Messages ──────────────────────────────────────────────────────
  static const String successApplicationCreated = 'Application created successfully!';
  static const String successApplicationUpdated = 'Application updated successfully!';
  static const String successPaymentCompleted = 'Payment completed successfully!';
  static const String successPaymentSkipped = 'Payment skipped.';
  static const String successSlotBooked = 'Exam slot booked successfully!';
  static const String successScoreUpdated = 'Exam score updated successfully!';
  static const String successCourseAssigned = 'Course assigned. Admission completed!';

  // ── Pagination ────────────────────────────────────────────────────────────
  static const int pageSize = 20;
}
