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

  group('App Startup & Welcome Routing Verification (6 Core Cases)', () {
    testWidgets('Case 1: Signed out user opening app displays Welcome page with sign-in and register options', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Ensure user is signed out
      KivoraService().clearSession();
      appRouter.go('/');

      await tester.pumpWidget(const ProviderScope(child: KivoraApp()));
      await tester.pumpAndSettle();

      // Must display Welcome screen
      expect(find.text('Kivora'), findsWidgets);
      expect(find.text('Every presence counts.'), findsOneWidget);

      // Must provide sign-in and registration options
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('Case 2: Signed in as an unassigned member opens app -> routes to Branch Gateway', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Authenticated user with no active branch assignment
      KivoraService().setCurrentUser(
        email: 'unassigned.member@example.com',
        name: 'Unassigned Member',
        role: 'member',
        branchId: null,
      );
      KivoraService().setMembershipStatus('none');

      appRouter.go('/');
      await tester.pumpWidget(const ProviderScope(child: KivoraApp()));
      await tester.pumpAndSettle();

      // Must display Branch Gateway
      expect(find.text('Branch & Membership Choice'), findsOneWidget);
      expect(find.text('Join an Existing Branch'), findsOneWidget);
      expect(find.text('Create a New Branch'), findsOneWidget);
    });

    testWidgets('Case 3: Signed in as an approved member opens app -> routes to Member Home', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Authenticated approved member with active branch assignment
      KivoraService().setCurrentUser(
        email: 'alex.johnson@kivora.edu.ng',
        name: 'Alex Johnson',
        role: 'member',
        branchId: 'branch-west',
      );
      KivoraService().setMembershipStatus('approved');

      appRouter.go('/');
      await tester.pumpWidget(const ProviderScope(child: KivoraApp()));
      await tester.pumpAndSettle();

      // Must display Member Home
      expect(find.text('Good morning,'), findsOneWidget);
      expect(find.text('Alex Johnson'), findsOneWidget);
    });

    testWidgets('Case 4: Signed in as a branch manager opens app -> routes to Manager Dashboard', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Authenticated branch manager
      KivoraService().setCurrentUser(
        email: 'manager@kivora.org',
        name: 'Branch Manager',
        role: 'manager',
        branchId: 'branch-west',
      );

      appRouter.go('/');
      await tester.pumpWidget(const ProviderScope(child: KivoraApp()));
      await tester.pumpAndSettle();

      // Must display Manager Dashboard
      expect(find.text('Branch Manager'), findsWidgets);
      expect(find.text('Registered Members'), findsOneWidget);
    });

    testWidgets('Case 5: Explicit navigation to /#/welcome displays Welcome page even with active session', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Case 5a: Approved member explicitly navigates to /welcome
      KivoraService().setCurrentUser(
        email: 'alex.johnson@kivora.edu.ng',
        name: 'Alex Johnson',
        role: 'member',
        branchId: 'branch-west',
      );
      KivoraService().setMembershipStatus('approved');

      appRouter.go('/welcome');
      await tester.pumpWidget(const ProviderScope(child: KivoraApp()));
      await tester.pumpAndSettle();

      // Must stay on Welcome screen and NOT redirect away
      expect(find.text('Every presence counts.'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);

      // Case 5b: Branch manager explicitly navigates to /welcome
      KivoraService().setCurrentUser(
        email: 'manager@kivora.org',
        name: 'Branch Manager',
        role: 'manager',
        branchId: 'branch-west',
      );

      appRouter.go('/welcome');
      await tester.pumpAndSettle();

      // Must remain on Welcome screen
      expect(find.text('Every presence counts.'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);

      // Case 5c: Unassigned member explicitly navigates to /welcome
      KivoraService().setCurrentUser(
        email: 'unassigned@kivora.org',
        name: 'Unassigned',
        role: 'member',
        branchId: null,
      );
      KivoraService().setMembershipStatus('none');

      appRouter.go('/welcome');
      await tester.pumpAndSettle();

      // Must remain on Welcome screen
      expect(find.text('Every presence counts.'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('Case 6: Browser refresh handles auth loading without incorrect redirects or loops', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Step 6a: User is on Member Home
      KivoraService().setCurrentUser(
        email: 'alex.johnson@kivora.edu.ng',
        name: 'Alex Johnson',
        role: 'member',
        branchId: 'branch-west',
      );
      KivoraService().setMembershipStatus('approved');

      appRouter.go('/member/home');
      await tester.pumpWidget(const ProviderScope(child: KivoraApp()));
      await tester.pumpAndSettle();
      expect(find.text('Good morning,'), findsOneWidget);

      // Simulate browser reload where auth is in loading state
      KivoraService().setAuthLoading(true);
      await tester.pump();

      // Router must NOT prematurely kick user to /welcome or /branch/gateway
      expect(find.text('Good morning,'), findsOneWidget);

      // Auth finishes loading
      KivoraService().setAuthLoading(false);
      await tester.pumpAndSettle();

      // Route remains stable on /member/home
      expect(find.text('Good morning,'), findsOneWidget);

      // Step 6b: Manager is on Manager Dashboard
      KivoraService().setCurrentUser(
        email: 'manager@kivora.org',
        name: 'Branch Manager',
        role: 'manager',
        branchId: 'branch-west',
      );

      appRouter.go('/manager/dashboard');
      await tester.pumpAndSettle();
      expect(find.text('Registered Members'), findsOneWidget);

      // Simulate reload with auth loading
      KivoraService().setAuthLoading(true);
      await tester.pump();
      expect(find.text('Registered Members'), findsOneWidget);

      KivoraService().setAuthLoading(false);
      await tester.pumpAndSettle();
      expect(find.text('Registered Members'), findsOneWidget);
    });
  });
}

