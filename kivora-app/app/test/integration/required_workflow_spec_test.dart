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

  group('Section 1 & 2: Form Validation, Navigation & Clean Forms', () {
    testWidgets('Empty registration submission is blocked with concise errors', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      appRouter.go('/register');
      await tester.pumpWidget(const ProviderScope(child: KivoraApp()));
      await tester.pumpAndSettle();

      // Submit without entering details
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pumpAndSettle();

      // Validation errors should appear
      expect(find.text('Full name is required'), findsOneWidget);
      expect(find.text('Email address is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);

      // Should remain on register screen
      expect(find.text('Create Account'), findsWidgets);
    });

    testWidgets('Invalid email and short password are rejected', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      appRouter.go('/register');
      await tester.pumpWidget(const ProviderScope(child: KivoraApp()));
      await tester.pumpAndSettle();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'John Doe');
      await tester.enterText(fields.at(1), 'invalid-email-format');
      await tester.enterText(fields.at(2), '123'); // < 6 chars

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('Empty sign-in submission is blocked', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      appRouter.go('/sign-in');
      await tester.pumpWidget(const ProviderScope(child: KivoraApp()));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email or student ID'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });
  });

  group('Section 3 & 6: Join Branch Workflow & Membership Approvals', () {
    testWidgets('Invalid invitation code is rejected without revealing branches', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      KivoraService().setCurrentUser(email: 'newuser@kivora.org', name: 'New User', role: 'guest');
      appRouter.go('/branch/discover');
      await tester.pumpWidget(const ProviderScope(child: KivoraApp()));
      await tester.pumpAndSettle();

      // No branch directory or list shown
      expect(find.text('All Branches'), findsNothing);
      expect(find.text('Suggested Branches'), findsNothing);

      // Submit empty
      await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter an invitation code.'), findsOneWidget);

      // Submit invalid code
      await tester.enterText(find.byType(TextField).first, 'INVALID-999');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(find.text('Invalid, inactive, or expired invitation code. Please check with your branch manager.'), findsOneWidget);
      // Remains on invitation code page
      expect(find.text('Enter Branch Invitation Code'), findsOneWidget);
    });

    testWidgets('Valid invitation code reveals only associated branch and renders dynamic ID form', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      KivoraService().setCurrentUser(email: 'newuser@kivora.org', name: 'New User', role: 'guest');
      appRouter.go('/branch/discover');
      await tester.pumpWidget(const ProviderScope(child: KivoraApp()));
      await tester.pumpAndSettle();

      // Enter valid code
      await tester.enterText(find.byType(TextField).first, 'WEST-2026');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Step 2: Confirm matching branch
      expect(find.text('Confirm Branch'), findsOneWidget);
      expect(find.text('West Campus'), findsOneWidget);
      expect(find.text('WEST-2026'), findsOneWidget);
      // Ensure only this branch is shown, not a directory
      expect(find.text('Other Branches'), findsNothing);

      // Step 3: Proceed to ID Form
      await tester.tap(find.widgetWithText(ElevatedButton, 'Join This Branch'));
      await tester.pumpAndSettle();

      expect(find.text('Identification Details'), findsOneWidget);
      expect(find.text('West Campus'), findsOneWidget);
      expect(find.text('Full Name *'), findsOneWidget);
      expect(find.text('Email Address *'), findsOneWidget);

      // Step 4: Submit Application
      await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Application'));
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      // Step 5: Dedicated Waiting for Approval Screen
      expect(find.text('Your account is\nawaiting approval'), findsOneWidget);
      expect(find.text('West Campus'), findsOneWidget);
      expect(find.text('Pending Review'), findsOneWidget);
    });

    testWidgets('Manager can review application details and approve/reject membership', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Submit an application first
      final app = KivoraService().submitApplication(
        branchId: 'branch-west',
        inviteCode: 'WEST-2026',
        userName: 'Applicant David',
        userEmail: 'david@student.ng',
        submittedData: {
          'fullName': 'Applicant David',
          'email': 'david@student.ng',
          'phone': '+234 801 234 5678',
          'student_id': 'STD-2026-99',
        },
      );
      final appId = app.id;

      // Open manager membership requests screen
      KivoraService().setCurrentUser(email: 'manager@kivora.org', name: 'Branch Manager', role: 'manager', branchId: 'branch-west');
      appRouter.go('/manager/requests/membership');
      await tester.pumpWidget(const ProviderScope(child: KivoraApp()));
      await tester.pumpAndSettle();

      expect(find.text('Membership Requests'), findsWidgets);
      expect(find.text('Applicant David'), findsWidgets);
      expect(find.text('STD-2026-99'), findsOneWidget);

      // Approve applicant
      await tester.tap(find.widgetWithText(ElevatedButton, 'Approve').first);
      await tester.pumpAndSettle();

      // Check status in service
      final status = KivoraService().getApplicationStatus(appId);
      expect(status, 'approved');
    });
  });

  group('Section 4: Branch Manager Identification Form Settings', () {
    testWidgets('Manager can add new custom field and toggle requirements', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      KivoraService().setCurrentUser(email: 'manager@kivora.org', name: 'Branch Manager', role: 'manager', branchId: 'branch-west');
      appRouter.go('/manager/settings/id-form');
      await tester.pumpWidget(const ProviderScope(child: KivoraApp()));
      await tester.pumpAndSettle();

      expect(find.text('Identification Form Settings'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);

      // Tap 'Add Custom Field'
      await tester.tap(find.text('Add Custom Field'));
      await tester.pumpAndSettle();

      expect(find.text('Add Custom Identification Field'), findsOneWidget);

      // Enter field label
      await tester.enterText(find.byType(TextField).first, 'Emergency Contact');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add Field'));
      await tester.pumpAndSettle();

      // Verify custom field is added and rendered in the list
      expect(find.text('Emergency Contact'), findsOneWidget);

      // Save configuration
      await tester.tap(find.text('Save Form'));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      // Verify persistent in KivoraService
      final fields = KivoraService().getIdFormConfig('branch-west');
      expect(fields.any((f) => f.label == 'Emergency Contact'), true);
    });
  });

  group('Section 5: Attendance Log & Clickable Member Profiles', () {
    testWidgets('Attendance log displays member name and real timestamps without Present/Late/Absent', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      KivoraService().setCurrentUser(email: 'manager@kivora.org', name: 'Branch Manager', role: 'manager', branchId: 'branch-west');
      appRouter.go('/manager/attendance/logs');
      await tester.pumpWidget(const ProviderScope(child: KivoraApp()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Attendance'), findsWidgets);
      // Ensure real member names and actual sign in timestamps appear
      expect(find.text('Alex Johnson'), findsOneWidget);
      expect(find.text('08:14 AM'), findsOneWidget);

      // CRITICAL REQUIREMENT: "Remove attendance labels such as: Present, Late, Absent"
      expect(find.text('Present'), findsNothing);
      expect(find.text('Late'), findsNothing);
      expect(find.text('Absent'), findsNothing);

      // Click member name to open full identification profile
      await tester.tap(find.text('Alex Johnson'));
      await tester.pumpAndSettle();

      // Verify Full Member Identification Profile Screen
      expect(find.text('Member Profile'), findsOneWidget);
      expect(find.text('Alex Johnson'), findsWidgets);
      expect(find.text('Identification Details'), findsOneWidget);
      expect(find.text('alex.johnson@kivora.edu.ng'), findsOneWidget);
      expect(find.text('KIV-2026-0891'), findsOneWidget);
    });
  });
}
