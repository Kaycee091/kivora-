import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kivora_app/app.dart';
import 'package:kivora_app/core/routing/app_router.dart';
import 'package:kivora_app/core/services/auth_service.dart';
import 'package:kivora_app/core/services/kivora_service.dart';
import 'package:kivora_app/features/authentication/screens/email_verification_screen.dart';

// Dummy/sample email addresses that must NEVER appear at runtime
const _forbiddenEmails = [
  'sarah.johnson@kivora.edu.ng',
  'alex.johnson@kivora.edu.ng',
  'applicant@kivora.edu.ng',
  'manager@kivora.org',
  'michael.brown@kivora.edu.ng',
  'emily.davis@kivora.edu.ng',
  'david.wilson@kivora.edu.ng',
];

void main() {
  setUp(() {
    KivoraService().resetToDefaults();
    AuthService().setLiveBackendConfigured(false);
    appRouter.go('/welcome');
  });

  // 1. Full registration-to-verification journey
  testWidgets('Email Registration and 6-Digit Verification Workflow Test',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const ProviderScope(child: KivoraApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Get Started'));
    await tester.pumpAndSettle();
    expect(find.text('Create Account'), findsWidgets);

    // Submit empty form
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
    await tester.pumpAndSettle();
    expect(find.text('Full name is required'), findsOneWidget);
    expect(find.text('Email address is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);

    // Invalid email
    final textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), 'Amara Okafor');
    await tester.enterText(textFields.at(1), 'not-an-email');
    await tester.enterText(textFields.at(2), 'Pass123!');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter a valid email address'), findsOneWidget);

    // Valid user email
    const testEmail = 'amara.okafor@example.com';
    await tester.enterText(textFields.at(1), testEmail);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Email verification service is not configured'), findsOneWidget);
    for (final dummy in _forbiddenEmails) {
      expect(find.textContaining(dummy), findsNothing,
          reason: 'Dummy email should not appear on register screen');
    }

    // Demo mode
    await tester.tap(find.text('Continue in Demo Mode (Offline Preview)'));
    await tester.pumpAndSettle();

    // Critical: real email shown on verification screen
    expect(find.text('Verify your email address'), findsOneWidget);
    expect(find.textContaining(testEmail), findsOneWidget,
        reason: 'Must display actual registered email');
    for (final dummy in _forbiddenEmails) {
      expect(find.textContaining(dummy), findsNothing,
          reason: 'Dummy email must not appear on verification screen');
    }
    expect(find.textContaining('Demo Mode'), findsOneWidget);
    expect(find.textContaining('Resend in '), findsOneWidget);

    // Wrong code
    final digitBoxes = find.byType(TextField);
    expect(digitBoxes, findsNWidgets(6));
    for (int i = 0; i < 6; i++) {
      await tester.enterText(digitBoxes.at(i), '9');
    }
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Invalid verification code'), findsOneWidget);
    expect(find.text('Verify your email address'), findsOneWidget);

    // Correct code (1,2,3,4,5,6 -> '123456')
    for (int i = 0; i < 6; i++) {
      await tester.enterText(digitBoxes.at(i), '${i + 1}');
    }
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Join an Existing Branch'), findsOneWidget);
  });

  // 2. Empty email guard
  testWidgets('EmailVerificationScreen shows error state when email is empty',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: EmailVerificationScreen(email: '', isDemoMode: true),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No Email Address Found'), findsOneWidget);
    expect(find.text('Back to Registration'), findsOneWidget);
    for (final dummy in _forbiddenEmails) {
      expect(find.textContaining(dummy), findsNothing,
          reason: 'Dummy email must not appear in empty-email guard');
    }
  });

  // 3. Exact email preserved through OTP verify
  testWidgets('EmailVerificationScreen uses exact provided email for verifyOtp',
      (WidgetTester tester) async {
    const userEmail = 'testuser@realmail.com';
    AuthService().startDemoRegistration(email: userEmail, fullName: 'Test User');

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: EmailVerificationScreen(email: userEmail, isDemoMode: true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining(userEmail), findsOneWidget);
    for (final dummy in _forbiddenEmails) {
      expect(find.textContaining(dummy), findsNothing,
          reason: 'Dummy must not appear when real email is set');
    }

    final digitBoxes = find.byType(TextField);
    for (int i = 0; i < 6; i++) {
      await tester.enterText(digitBoxes.at(i), '${i + 1}');
    }
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pumpAndSettle();

    // KivoraService stores the real email after successful verify
    expect(KivoraService().currentUserEmail, equals(userEmail));
  });

  // 4. AuthService.signUp returns no dummy email when unconfigured
  test('AuthService.signUp unconfigured returns no dummy email', () async {
    AuthService().setLiveBackendConfigured(false);
    const inputEmail = '  Real.User@Example.COM  ';
    const expectedEmail = 'real.user@example.com';

    final result = await AuthService().signUp(
      email: inputEmail,
      password: 'securePassword1',
      fullName: 'Real User',
    );

    expect(result.isUnconfigured, isTrue);
    expect(result.isSuccess, isFalse);
    if (result.email != null) {
      expect(result.email, equals(expectedEmail));
      for (final dummy in _forbiddenEmails) {
        expect(result.email, isNot(equals(dummy)));
      }
    }
  });

  // 5. startDemoRegistration preserves exact user email
  test('AuthService.startDemoRegistration stores exact user email', () {
    AuthService().setLiveBackendConfigured(false);
    const inputEmail = '  Amara.Okafor@University.EDU  ';
    const expectedEmail = 'amara.okafor@university.edu';

    final result = AuthService().startDemoRegistration(
      email: inputEmail,
      fullName: 'Amara Okafor',
    );

    expect(result.isSuccess, isTrue);
    expect(result.email, equals(expectedEmail));
    expect(AuthService().demoEmail, equals(expectedEmail));
    for (final dummy in _forbiddenEmails) {
      expect(result.email, isNot(equals(dummy)));
    }
  });
}
