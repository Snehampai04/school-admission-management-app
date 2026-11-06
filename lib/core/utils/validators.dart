  /// Form field validators used in TextFormField widgets.
  /// Each function returns `null` on success or an error string on failure.
  class AppValidators {
    AppValidators._();

    // ── Generic ───────────────────────────────────────────────────────────────

    static String? required(String? value, {String? fieldName}) {
      if (value == null || value.trim().isEmpty) {
        return '${fieldName ?? 'This field'} is required.';
      }
      return null;
    }

    // ── Auth ──────────────────────────────────────────────────────────────────

    static String? email(String? value) {
      if (value == null || value.trim().isEmpty) return 'Email is required.';
      final regex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
      if (!regex.hasMatch(value.trim())) return 'Enter a valid email address.';
      return null;
    }

    static String? password(String? value) {
      if (value == null || value.isEmpty) return 'Password is required.';
      if (value.length < 8) return 'Password must be at least 8 characters.';
      return null;
    }

    static String? confirmPassword(String? value, String original) {
      if (value == null || value.isEmpty) return 'Please confirm your password.';
      if (value != original) return 'Passwords do not match.';
      return null;
    }

    static String? name(String? value) {
      if (value == null || value.trim().isEmpty) return 'Name is required.';
      if (value.trim().length < 2) return 'Name must be at least 2 characters.';
      return null;
    }

    // ── Student Application ───────────────────────────────────────────────────

    static String? studentName(String? value) {
      if (value == null || value.trim().isEmpty) return 'Student name is required.';
      if (value.trim().length < 2) return 'Enter a valid name (min 2 characters).';
      return null;
    }

    static String? previousSchool(String? value) {
      if (value == null || value.trim().isEmpty) return 'Previous school is required.';
      if (value.trim().length < 2) return 'Enter a valid school name.';
      return null;
    }

    static String? grade(String? value) {
      if (value == null || value.trim().isEmpty) return 'Please select a grade.';
      return null;
    }

    static String? gender(String? value) {
      if (value == null || value.trim().isEmpty) return 'Please select a gender.';
      return null;
    }

    static String? dateOfBirth(DateTime? value) {
      if (value == null) return 'Date of birth is required.';
      final now = DateTime.now();
      final age = now.year - value.year;
      if (age < 4) return 'Student must be at least 4 years old.';
      if (age > 18) return 'Student age seems too high for admission.';
      return null;
    }

    // ── Exam Slot ─────────────────────────────────────────────────────────────

    static String? venue(String? value) {
      if (value == null || value.trim().isEmpty) return 'Venue is required.';
      return null;
    }

    static String? capacity(String? value) {
      if (value == null || value.trim().isEmpty) return 'Capacity is required.';
      final n = int.tryParse(value.trim());
      if (n == null || n < 1) return 'Capacity must be a positive number.';
      return null;
    }

    // ── Exam Score ────────────────────────────────────────────────────────────

    static String? examScore(String? value) {
      if (value == null || value.trim().isEmpty) return 'Exam score is required.';
      final score = int.tryParse(value.trim());
      if (score == null) return 'Enter a valid integer score.';
      if (score < 0 || score > 100) return 'Score must be between 0 and 100.';
      return null;
    } 
  }
