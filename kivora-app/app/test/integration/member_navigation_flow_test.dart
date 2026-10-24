import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kivora_app/app.dart';
import 'package:kivora_app/core/routing/app_router.dart';

import 'package:kivora_app/core/services/kivora_service.dart';

void main() {
  setUp(() {
    KivoraService().resetToDefaults();
    appRouter.go('/welcome');
  });

  testWidgets('End-to-End User Journey: Welcome -> Sign In -> Home -> Check In -> History', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // 1. Launch App at /welcome
    await tester.pumpWidget(const ProviderScope(child: KivoraApp()));
    await tester.pumpAndSettle();

    // Verify Welcome Screen elements
    expect(find.text('Kivora'), findsWidgets);
    expect(find.text('Every presence counts.'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);

    // 2. Tap Sign In on Welcome Screen (OutlinedButton)
    await tester.tap(find.widgetWithText(OutlinedButton, 'Sign In'));
    await tester.pumpAndSettle();

    // Verify Sign In Screen
    expect(find.text('Welcome back! Please sign in to your account.'), findsOneWidget);

    // 3. Enter credentials and submit
    await tester.enterText(find.byType(TextField).first, 'alex.johnson@kivora.edu.ng');
    await tester.enterText(find.byType(TextField).last, 'Password123!');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    // 4. Verify Member Home Screen
    expect(find.text('Alex Johnson'), findsOneWidget);
    expect(find.text('Student \u2022 West Campus'), findsOneWidget);
    expect(find.text("Today's Attendance"), findsOneWidget);
    expect(find.text('Check In'), findsOneWidget);
    expect(find.text('My Schedule'), findsOneWidget);
    expect(find.text('Attendance History'), findsOneWidget);
    expect(find.text('Digital ID Card'), findsOneWidget);

    // 5. Navigate to Check In
    await tester.tap(find.text('Check In'));
    await tester.pumpAndSettle();

    // Verify Check In Screen
    expect(find.text('Ready for verification'), findsOneWidget);
    expect(find.text('Location (GPS)'), findsOneWidget);
    expect(find.text('Wi-Fi Network'), findsOneWidget);
    expect(find.text('Biometric'), findsOneWidget);

    // 6. Start Verification
    await tester.tap(find.text('Start Verification'));
    // Advance timers for step 1 (GPS), step 2 (Wi-Fi), step 3 (Biometric), and transition
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Verify Verification Result Screen
    expect(find.text('Verification Successful!'), findsOneWidget);
    expect(find.text("Your attendance has been recorded for today's session."), findsOneWidget);
    expect(find.text('View Details'), findsOneWidget);
    expect(find.text('Back to Dashboard'), findsOneWidget);

    // 7. Tap View Details -> Attendance History
    await tester.tap(find.text('View Details'));
    await tester.pumpAndSettle();

    // Verify Attendance History Screen
    expect(find.text('Attendance History'), findsWidgets);
  });

  testWidgets('Bottom Navigation Switches Tabs Correctly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const ProviderScope(child: KivoraApp()));
    await tester.pumpAndSettle();

    // Go directly to home via sign in
    await tester.tap(find.widgetWithText(OutlinedButton, 'Sign In'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'alex.johnson@kivora.edu.ng');
    await tester.enterText(find.byType(TextField).last, 'Password123!');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    // Verify Member Home
    expect(find.text('Alex Johnson'), findsOneWidget);

    // Tap Schedule tab — pushes new route on top of home
    await tester.tap(find.byIcon(Icons.calendar_month));
    await tester.pumpAndSettle();
    expect(find.text('Attendance Calendar'), findsOneWidget);

    // Pop back to Member Home using back arrow (schedule screen has no bottom nav)
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Alex Johnson'), findsOneWidget);

    // Tap Profile from bottom nav (home screen has bottom nav with person icon)
    await tester.tap(find.byIcon(Icons.person).last);
    await tester.pumpAndSettle();
    expect(find.text('Profile'), findsWidgets);
    expect(find.text('Personal Information'), findsOneWidget);
  });
}
