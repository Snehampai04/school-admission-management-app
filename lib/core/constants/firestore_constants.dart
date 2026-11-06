/// Firestore collection and field name constants.
/// Centralising these prevents typos across the codebase.
library;

class FirestoreConstants {
  FirestoreConstants._();

  // ── Collection Names ──────────────────────────────────────────────────────
  static const String usersCollection = 'users';
  static const String studentsCollection = 'students';
  static const String examSlotsCollection = 'exam_slots';
  static const String examBookingsCollection = 'exam_bookings';
  static const String paymentsCollection = 'payments';

  // ── users fields ─────────────────────────────────────────────────────────
  static const String uid = 'uid';
  static const String email = 'email';
  static const String name = 'name';
  static const String role = 'role';

  // ── students fields ───────────────────────────────────────────────────────
  static const String parentId = 'parentId';
  static const String studentName = 'studentName';
  static const String dateOfBirth = 'dateOfBirth';
  static const String gender = 'gender';
  static const String previousSchool = 'previousSchool';
  static const String applyingGrade = 'applyingGrade';
  static const String applicationStatus = 'applicationStatus';
  static const String paymentStatus = 'paymentStatus';
  static const String examScore = 'examScore';
  static const String assignedCourse = 'assignedCourse';

  // ── exam_slots fields ─────────────────────────────────────────────────────
  static const String date = 'date';
  static const String startTime = 'startTime';
  static const String endTime = 'endTime';
  static const String venue = 'venue';
  static const String totalCapacity = 'totalCapacity';
  static const String bookedCount = 'bookedCount';
  static const String createdBy = 'createdBy';

  // ── exam_bookings fields ──────────────────────────────────────────────────
  static const String studentId = 'studentId';
  static const String slotId = 'slotId';
  static const String bookedAt = 'bookedAt';

  // ── payments fields ───────────────────────────────────────────────────────
  static const String amount = 'amount';
  static const String status = 'status';
  static const String transactionId = 'transactionId';
  static const String timestamp = 'timestamp';

  // ── Shared timestamps ─────────────────────────────────────────────────────
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
}
