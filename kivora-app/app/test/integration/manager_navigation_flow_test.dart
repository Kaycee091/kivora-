import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kivora_app/app.dart';
import 'package:kivora_app/core/routing/app_router.dart';
import 'package:kivora_app/core/services/auth_service.dart';
import 'package:kivora_app/core/services/kivora_service.dart';

void main() {
  setUp(() {
    AuthService().switchToDemoMode();
    KivoraService().resetToDefaults();
    appRouter.go('/manager/sign-in');
  });

  testWidgets('Branch Manager End-to-End Journey: Sign In -> Dashboard -> Members & Quick Actions', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // 1. Launch App at /manager/sign-in
    await tester.pumpWidget(const ProviderScope(child: KivoraApp()));
    await tester.pumpAndSettle();

    // Verify Manager Sign In Screen
    expect(find.text('Branch Manager Sign In'), findsOneWidget);
    expect(find.text('Access your branch dashboard and manage your organization.'), findsOneWidget);
    expect(find.text('Email address'), findsOneWidget);

    // 2. Submit credentials
    await tester.enterText(find.byType(TextField).first, 'manager@kivora.org');
    await tester.enterText(find.byType(TextField).last, 'Password123!');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    // 3. Verify Manager Dashboard Screen
    expect(find.text('Branch Manager'), findsOneWidget);
    // manager@kivora.org has no pre-seeded branchId — dashboard correctly shows 'No branch assigned'
    expect(find.text('No branch assigned'), findsOneWidget);
    expect(find.text('Registered Members'), findsOneWidget);
    expect(find.text('Pending Approvals'), findsOneWidget);
    expect(find.text('Active Branches'), findsOneWidget);

    // 4. Test Quick Action: View Members
    await tester.tap(find.text('Members'));
    await tester.pumpAndSettle();
    expect(find.text('Members'), findsWidgets);

    // Pop back to Dashboard
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // 5. Test Quick Action: Attendance Logs
    await tester.tap(find.text('Attendance Sign-In Logs'));
    await tester.pumpAndSettle();
    expect(find.text('Attendance Logs'), findsWidgets);

    // Pop back to Dashboard
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // 6. Test Switch Role to Member View:
    // Because manager@kivora.org has no assigned branch, the route guard securely routes to the Branch Gateway
    await tester.tap(find.byIcon(Icons.swap_horiz));
    await tester.pumpAndSettle();
    expect(find.text('Branch & Membership Choice'), findsOneWidget);
    expect(find.text('Create a New Branch'), findsOneWidget);
  });
}
