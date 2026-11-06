/// Named route path constants used throughout GoRouter.
library;

class RouteConstants {
  RouteConstants._();

  // ── Root ──────────────────────────────────────────────────────────────────
  static const String splash = '/';

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String login = '/login';
  static const String register = '/register';

  // ── Parent ────────────────────────────────────────────────────────────────
  static const String parentDashboard = '/parent/dashboard';
  static const String createStudent = '/parent/student/create';
  static const String studentDetail = '/parent/student/:studentId';
  static const String editStudent = '/parent/student/:studentId/edit';
  static const String payment = '/parent/student/:studentId/payment';
  static const String slotBooking = '/parent/student/:studentId/slots';
  static const String myApplications = '/parent/applications';

  // ── Admin ─────────────────────────────────────────────────────────────────
  static const String adminDashboard = '/admin/dashboard';
  static const String adminStudentDetail = '/admin/student/:studentId';
  static const String updateScore = '/admin/student/:studentId/score';
  static const String assignCourse = '/admin/student/:studentId/course';
  static const String adminExamBookings = '/admin/exam-bookings';
  static const String manageSlots = '/admin/slots';

  // ── Helpers to build parameterised paths ──────────────────────────────────
  static String studentDetailPath(String id) =>
      '/parent/student/$id';
  static String editStudentPath(String id) =>
      '/parent/student/$id/edit';
  static String paymentPath(String id) =>
      '/parent/student/$id/payment';
  static String slotBookingPath(String id) =>
      '/parent/student/$id/slots';
  static String adminStudentDetailPath(String id) =>
      '/admin/student/$id';
  static String updateScorePath(String id) =>
      '/admin/student/$id/score';
  static String assignCoursePath(String id) =>
      '/admin/student/$id/course';
}
