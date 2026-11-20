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
    appRouter.go('/welcome');
  });

  testWidgets('Test A: Complete Member Onboarding Journey (Invitation Code -> Dynamic Form -> Waiting -> Approval)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // 1. Launch App at /welcome
    await tester.pumpWidget(const ProviderScope(child: KivoraApp()));
    await tester.pumpAndSettle();

    expect(find.text('Kivora'), findsWidgets);
    expect(find.text('Get Started'), findsOneWidget);

    // 2. Open registration
    await tester.tap(find.widgetWithText(ElevatedButton, 'Get Started'));
    await tester.pumpAndSettle();

    // Verify Register Screen
    expect(find.text('Create Account'), findsWidgets);

    // 3. Fill details and submit registration
    final textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), 'Sarah Johnson');
    await tester.enterText(textFields.at(1), 'sarah.johnson@kivora.edu.ng');
    await tester.enterText(textFields.at(2), 'SecurePass123!');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
    await tester.pumpAndSettle();

    // If live email backend is not configured, tap Continue in Demo Mode
    final demoBtn = find.text('Continue in Demo Mode (Offline Preview)');
    if (demoBtn.evaluate().isNotEmpty) {
      await tester.tap(demoBtn);
      await tester.pumpAndSettle();
    }

    // 4. Verify Email Verification Screen
    expect(find.text('Verify your email address'), findsOneWidget);
    expect(find.textContaining('sarah.johnson@kivora.edu.ng'), findsOneWidget);
    expect(find.textContaining('6-digit verification code'), findsOneWidget);

    // Enter 6 digit code
    final digitFields = find.byType(TextField);
    for (int i = 0; i < 6; i++) {
      await tester.enterText(digitFields.at(i), '${i + 1}');
    }
    await tester.pumpAndSettle();

    // 5. Complete verification -> Go to Branch Gateway
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    // 6. Verify Post-Sign-In Decision: Branch & Membership Choice
    expect(find.text('Branch & Membership Choice'), findsOneWidget);
    expect(find.text('Join an Existing Branch'), findsOneWidget);
    expect(find.text('Create a New Branch'), findsOneWidget);

    // 7. Choose Option A: Join an Existing Branch
    await tester.tap(find.text('Join an Existing Branch'));
    await tester.pumpAndSettle();

    // 8. Verify Invitation Code Entry Screen (NO branch directory)
    expect(find.text('Join an Existing Branch'), findsWidgets);
    expect(find.text('Enter Branch Invitation Code'), findsOneWidget);
    // Ensure no branch list is shown
    expect(find.text('All Branches'), findsNothing);

    // Enter valid invite code
    await tester.enterText(find.byType(TextField).first, 'WEST-2026');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    // 9. Verify Matching Branch Preview Screen
    expect(find.text('Confirm Branch'), findsOneWidget);
    expect(find.text('West Campus'), findsOneWidget);
    expect(find.text('WEST-2026'), findsOneWidget);

    // Proceed to Dynamic Identification Form
    await tester.tap(find.widgetWithText(ElevatedButton, 'Join This Branch'));
    await tester.pumpAndSettle();

    // 10. Verify Configured Identification Form
    expect(find.text('Identification Details'), findsOneWidget);
    expect(find.text('Full Name *'), findsOneWidget);

    // Submit Application
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Application'));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    // 11. Verify Dedicated Waiting for Approval Screen
    expect(find.text('Application Status'), findsOneWidget);
    expect(find.text('Your account is\nawaiting approval'), findsOneWidget);
    expect(find.text('West Campus'), findsOneWidget);
    expect(find.text('Pending Review'), findsOneWidget);

    // 12. Simulate Branch Manager Approving Application in KivoraService
    final apps = KivoraService().getApplicationsForBranch('branch-west');
    expect(apps.isNotEmpty, true);
    final myApp = apps.last;
    KivoraService().approveApplication(myApp.id);

    // 13. Refresh status on Waiting screen
    await tester.tap(find.text('Check Status'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    // Now status is Approved, can proceed to Member Home
    expect(find.text('Application Approved!'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Proceed to Member Home'));
    await tester.pumpAndSettle();

    expect(find.text('Sarah Johnson'), findsOneWidget);
    expect(find.text("Today's Attendance"), findsOneWidget);
    expect(find.text('Check In'), findsOneWidget);
  });

  testWidgets('Test B: Branch Manager Creation Journey from Gateway to Manager Dashboard', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // 1. Start at Branch Choice Gateway
    KivoraService().setCurrentUser(email: 'newmanager@kivora.org', name: 'New Manager', role: 'guest');
    appRouter.go('/branch/gateway');
    await tester.pumpWidget(const ProviderScope(child: KivoraApp()));
    await tester.pumpAndSettle();

    expect(find.text('Branch & Membership Choice'), findsOneWidget);
    expect(find.text('Create a New Branch'), findsOneWidget);

    // 2. Select Option B: Create a New Branch
    await tester.tap(find.text('Create a New Branch'));
    await tester.pumpAndSettle();

    // 3. Verify Branch Details Screen
    expect(find.text('Create Branch - Details'), findsOneWidget);
    expect(find.text('Branch Information'), findsOneWidget);

    // Fill branch details
    final detailsFields = find.byType(TextField);
    await tester.enterText(detailsFields.at(0), 'North Tech Academy');
    await tester.enterText(detailsFields.at(1), '12 Innovation Drive');
    await tester.enterText(detailsFields.at(2), '+234 800 111 2233');

    // Tap Next -> Branch Admin Setup
    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('Create Branch - Add Admin'), findsOneWidget);

    // Fill Admin details
    final adminFields = find.byType(TextField);
    await tester.enterText(adminFields.at(0), 'Admin Marcus');
    await tester.enterText(adminFields.at(1), 'marcus@northtech.edu');
    await tester.enterText(adminFields.at(2), '+234 800 999 8877');

    // Submit Branch Creation -> Success Screen
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create Branch'));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    expect(find.text('Branch Created\nSuccessfully!'), findsOneWidget);
    expect(find.text('Go to Dashboard'), findsOneWidget);

    // Verify success card shows the actual user-entered branch name and details
    expect(find.text('North Tech Academy'), findsWidgets);
    expect(find.textContaining('Invite Code:'), findsOneWidget);

    // Go to Dashboard -> Branch Manager Dashboard
    await tester.tap(find.widgetWithText(ElevatedButton, 'Go to Dashboard'));
    await tester.pumpAndSettle();

    // The dashboard now displays the real administrator's name entered in the form
    expect(find.text('Admin Marcus'), findsOneWidget);
    // The dashboard now displays '${branchName} Branch' using the actual created branch
    expect(find.text('North Tech Academy Branch'), findsOneWidget);
    expect(find.text('Registered Members'), findsOneWidget);
  });

  testWidgets('Test C: Returning User Role Resolution & Routing', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // 1. Launch at Welcome
    appRouter.go('/welcome');
    await tester.pumpWidget(const ProviderScope(child: KivoraApp()));
    await tester.pumpAndSettle();

    // 2. Tap Sign In
    await tester.tap(find.widgetWithText(OutlinedButton, 'Sign In'));
    await tester.pumpAndSettle();

    // 3. Manager email should resolve directly to Manager Dashboard
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'manager@kivora.org');
    await tester.enterText(fields.at(1), 'Password123!');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(find.text('Branch Manager'), findsOneWidget);
    // manager@kivora.org has no pre-seeded branch association
    expect(find.text('No branch assigned'), findsOneWidget);
  });
}
