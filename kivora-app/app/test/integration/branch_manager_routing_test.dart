import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kivora_app/app.dart';
import 'package:kivora_app/core/routing/app_router.dart';
import 'package:kivora_app/core/services/auth_service.dart';
import 'package:kivora_app/core/services/kivora_service.dart';
import 'package:kivora_app/core/services/storage_service.dart';

void main() {
  setUp(() {
    StorageService.useMemoryOnlyForTests();
    AuthService().switchToDemoMode();
    KivoraService().resetToDefaults();
  });

  group('Branch Manager Post-Login Routing & Assignment Verification', () {
    test('KivoraService.isManagementRole recognizes branch_manager, branch_admin, and web_admin', () {
      expect(KivoraService.isManagementRole('branch_manager'), isTrue);
      expect(KivoraService.isManagementRole('branch_admin'), isTrue);
      expect(KivoraService.isManagementRole('web_admin'), isTrue);
      expect(KivoraService.isManagementRole('manager'), isTrue);
      expect(KivoraService.isManagementRole('admin'), isTrue);
      expect(KivoraService.isManagementRole('BRANCH_MANAGER'), isTrue);
      expect(KivoraService.isManagementRole('WEB_ADMIN'), isTrue);

      expect(KivoraService.isManagementRole('member'), isFalse);
      expect(KivoraService.isManagementRole('guest'), isFalse);
      expect(KivoraService.isManagementRole('student'), isFalse);
      expect(KivoraService.isManagementRole(null), isFalse);
    });

    testWidgets('Active branch_manager assignment navigates directly to Manager Dashboard', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Manager user with Techverve branch assignment
      KivoraService().setCurrentUser(
        email: 'asogwakenechukwu284@gmail.com',
        name: 'Techverve Manager',
        role: 'branch_manager',
        branchId: 'branch-west',
      );

      expect(KivoraService().isManagerOrAdmin, isTrue);

      appRouter.go('/');
      await tester.pumpWidget(const ProviderScope(child: KivoraApp()));
      await tester.pumpAndSettle();

      // Must be on Manager Dashboard, NOT on Branch Gateway
      expect(find.text('Techverve Manager'), findsOneWidget);
      expect(find.text('Registered Members'), findsOneWidget);
      expect(find.text('Branch & Membership Choice'), findsNothing);
    });

    testWidgets('Active branch_admin assignment navigates directly to Manager Dashboard', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      KivoraService().setCurrentUser(
        email: 'admin.user@example.com',
        name: 'Branch Admin',
        role: 'branch_admin',
        branchId: 'branch-west',
      );

      expect(KivoraService().isManagerOrAdmin, isTrue);

      appRouter.go('/');
      await tester.pumpWidget(const ProviderScope(child: KivoraApp()));
      await tester.pumpAndSettle();

      expect(find.text('Branch Admin'), findsOneWidget);
      expect(find.text('Registered Members'), findsOneWidget);
      expect(find.text('Branch & Membership Choice'), findsNothing);
    });

    testWidgets('Active web_admin assignment navigates directly to Manager Dashboard', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      KivoraService().setCurrentUser(
        email: 'web.admin@example.com',
        name: 'Web Admin User',
        role: 'web_admin',
        branchId: 'branch-west',
      );

      expect(KivoraService().isManagerOrAdmin, isTrue);

      appRouter.go('/');
      await tester.pumpWidget(const ProviderScope(child: KivoraApp()));
      await tester.pumpAndSettle();

      expect(find.text('Web Admin User'), findsOneWidget);
      expect(find.text('Registered Members'), findsOneWidget);
      expect(find.text('Branch & Membership Choice'), findsNothing);
    });

    testWidgets('Manager Dash button on Branch Gateway functions and routes authorized manager', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Set user as manager with branch assignment
      KivoraService().setCurrentUser(
        email: 'asogwakenechukwu284@gmail.com',
        name: 'Branch Manager',
        role: 'branch_manager',
        branchId: 'branch-west',
      );

      // Explicitly navigate to Branch Gateway
      appRouter.go('/branch/gateway');
      await tester.pumpWidget(const ProviderScope(child: KivoraApp()));
      await tester.pumpAndSettle();

      expect(find.text('Branch & Membership Choice'), findsOneWidget);
      final managerDashBtn = find.widgetWithText(OutlinedButton, 'Manager Dash');
      expect(managerDashBtn, findsOneWidget);

      // Tap Manager Dash
      await tester.tap(managerDashBtn);
      await tester.pumpAndSettle();

      // Must navigate to Manager Dashboard
      expect(find.text('Branch Manager'), findsWidgets);
      expect(find.text('Registered Members'), findsOneWidget);
    });

    testWidgets('Member routing is preserved: unassigned member continues through member gateway flow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Regular member without branch assignment
      KivoraService().setCurrentUser(
        email: 'regular.member@example.com',
        name: 'Regular Member',
        role: 'member',
        branchId: null,
      );
      KivoraService().setMembershipStatus('none');

      expect(KivoraService().isManagerOrAdmin, isFalse);

      appRouter.go('/');
      await tester.pumpWidget(const ProviderScope(child: KivoraApp()));
      await tester.pumpAndSettle();

      // Must display Branch Gateway
      expect(find.text('Branch & Membership Choice'), findsOneWidget);
      expect(find.text('Join an Existing Branch'), findsOneWidget);
      expect(find.text('Create a New Branch'), findsOneWidget);
      expect(find.text('Registered Members'), findsNothing);
    });
  });
}
