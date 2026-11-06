// Placeholder widget test — the default counter smoke test is removed because
// main.dart now initialises Firebase and GoRouter (which require a real Firebase
// project and cannot be meaningfully tested here without mocks).
//
// Feature-specific widget and unit tests will be added under test/ in later
// phases, using fake_cloud_firestore, firebase_auth_mocks, and bloc_test.

import 'package:flutter_test/flutter_test.dart';

void main() {
  // No-op — real tests will be added in Phase 9.
  test('placeholder', () {
    expect(1 + 1, 2);
  });
}
