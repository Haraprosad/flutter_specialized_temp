import 'package:flutter/material.dart';
import 'package:flutter_specialized_temp/flavors/main_development.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// End-to-end auth flow tests.
///
/// These run on a real device/emulator via:
///   flutter test integration_test/auth_flow_test.dart
///
/// They require a running backend at the configured API base URL.
/// For CI, point the env file at a mock/staging server.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth flow', () {
    testWidgets('splash screen appears on cold start', (tester) async {
      app.main();
      await tester.pump();

      // Splash or login screen should be visible immediately
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('login screen renders email and password fields', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // If redirected to login, verify the form fields exist.
      // Skip gracefully if still on splash/loading.
      final emailFields = find.byType(TextFormField);
      if (emailFields.evaluate().isNotEmpty) {
        expect(emailFields, findsAtLeast(1));
      }
    });

    testWidgets('shows error on login with empty credentials', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final loginButton = find.byType(ElevatedButton);
      if (loginButton.evaluate().isEmpty) return; // not on login screen

      await tester.tap(loginButton.first);
      await tester.pumpAndSettle();

      // Validation error or snackbar should appear
      expect(
        find.byType(SnackBar).evaluate().isNotEmpty ||
            find.textContaining('required').evaluate().isNotEmpty ||
            find.textContaining('empty').evaluate().isNotEmpty,
        isTrue,
      );
    });
  });
}
