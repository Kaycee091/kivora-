import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kivora_app/app.dart';
import 'package:kivora_app/core/routing/app_router.dart';
import 'package:kivora_app/core/services/kivora_service.dart';

void main() {
  setUp(() {
    KivoraService().resetToDefaults();
  });

  testWidgets('Route Guard Protection & Session Authorization Test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // 1. Mount application
    await tester.pumpWidget(const ProviderScope(child: KivoraApp()));
    await tester.pumpAndSettle();

    // 2. Unauthenticated user attempts direct URL navigation to /manager/dashboard
    appRouter.go('/manager/dashboard');
    await tester.pumpAndSettle();

    // Must be redirected to /manager/sign-in
    expect(find.text('Branch Manager Sign In'), findsOneWidget);
    expect(find.text('Manager Dashboard'), findsNothing);

    // 3. Unauthenticated user attempts direct URL navigation to /member/home
    appRouter.go('/member/home');
    await tester.pumpAndSettle();

    // Must be redirected to /welcome
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Recent Activity'), findsNothing);

    // 4. User is authenticated as a Pending Applicant
    KivoraService().setCurrentUser(
      email: 'applicant.pending@example.com',
      name: 'Pending Applicant',
      role: 'guest',
      branchId: 'branch-west',
    );
    KivoraService().submitApplication(
      branchId: 'branch-west',
      inviteCode: 'WEST-2026',
      userName: 'Pending Applicant',
      userEmail: 'applicant.pending@example.com',
      submittedData: {'full_name': 'Pending Applicant'},
    );

    // Pending applicant attempts direct navigation to /member/home
    appRouter.go('/member/home');
    await tester.pumpAndSettle();

    // Guard must redirect them to /branch/status (Waiting for Approval)
    expect(find.textContaining('awaiting approval'), findsOneWidget);
    expect(find.text('Recent Activity'), findsNothing);

    // 5. User is authenticated as an ordinary Member
    KivoraService().setCurrentUser(
      email: 'member.alex@example.com',
      name: 'Alex Johnson',
      role: 'member',
      branchId: 'branch-west',
    );
    KivoraService().setMembershipStatus('approved');

    // Ordinary member attempts to access /manager/dashboard
    appRouter.go('/manager/dashboard');
    await tester.pumpAndSettle();

    // Guard must block ordinary member from manager routes and redirect to /member/home
    expect(find.text('Good morning,'), findsOneWidget);
    expect(find.text('Branch Manager Sign In'), findsNothing);

    // 6. User is authenticated as a Branch Manager
    KivoraService().setCurrentUser(
      email: 'manager@kivora.org',
      name: 'Branch Manager',
      role: 'manager',
      branchId: 'branch-west',
    );

    // Branch manager visits /manager/dashboard
    appRouter.go('/manager/dashboard');
    await tester.pumpAndSettle();

    // Authorized manager can access /manager/dashboard
    expect(find.text('Branch Manager'), findsWidgets);
  });
}
