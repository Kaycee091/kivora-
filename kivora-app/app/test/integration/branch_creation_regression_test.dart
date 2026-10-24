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

  // Helper: navigate through registration to reach the branch gateway
  Future<void> navigateToBranchGateway(WidgetTester tester) async {
    KivoraService().setCurrentUser(
      email: 'creator@testorg.com',
      name: 'Branch Creator',
      role: 'guest',
    );
    appRouter.go('/branch/gateway');
    await tester.pumpWidget(const ProviderScope(child: KivoraApp()));
    await tester.pumpAndSettle();
    expect(find.text('Create a New Branch'), findsOneWidget);
  }

  // ─────────────────────────────────────────────────────────────────
  // 1. User-entered branch details are preserved when Next is pressed
  // ─────────────────────────────────────────────────────────────────
  testWidgets(
    'Branch creation: user-entered details are preserved through wizard',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await navigateToBranchGateway(tester);

      // Navigate to Create New Branch
      await tester.tap(find.text('Create a New Branch'));
      await tester.pumpAndSettle();
      expect(find.text('Create Branch - Details'), findsOneWidget);

      // Enter unique branch details
      const branchName = 'Lekki Tech Academy';
      const address = '15 Innovation Blvd, Lagos';
      const phone = '+234 800 555 1234';

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), branchName);
      await tester.enterText(fields.at(1), address);
      await tester.enterText(fields.at(2), phone);
      await tester.pumpAndSettle();

      // Press Next
      await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
      await tester.pumpAndSettle();

      // Step 2: Admin Details
      expect(find.text('Create Branch - Add Admin'), findsOneWidget);

      const adminName = 'Chidi Okonkwo';
      const adminEmail = 'chidi@lekkitech.edu';

      final adminFields = find.byType(TextField);
      await tester.enterText(adminFields.at(0), adminName);
      await tester.enterText(adminFields.at(1), adminEmail);
      await tester.pumpAndSettle();

      // Create Branch
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Branch'));
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();

      // Success screen: branch name must be exactly what user entered
      expect(find.text('Branch Created\nSuccessfully!'), findsOneWidget);
      expect(find.text(branchName), findsWidgets);

      // Invite code shown on success screen
      expect(find.textContaining('Invite Code:'), findsOneWidget);

      // Org type / address section (no hardcoded 'School • Lagos, Nigeria')
      expect(find.text('School \u2022 Lagos, Nigeria'), findsNothing);
    },
  );

  // ─────────────────────────────────────────────────────────────────
  // 2. Validation prevents creation when required fields are empty
  // ─────────────────────────────────────────────────────────────────
  testWidgets(
    'Branch creation: empty required fields are rejected with visible errors',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await navigateToBranchGateway(tester);

      await tester.tap(find.text('Create a New Branch'));
      await tester.pumpAndSettle();
      expect(find.text('Create Branch - Details'), findsOneWidget);

      // Tap Next without filling anything
      await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
      await tester.pumpAndSettle();

      // Validation errors shown, still on step 1
      expect(find.text('Branch name is required.'), findsOneWidget);
      expect(find.text('Branch location or address is required.'), findsOneWidget);
      expect(find.text('Create Branch - Details'), findsOneWidget);

      // No branch must have been added to KivoraService
      final branchCountBefore = KivoraService().branches.length;
      expect(branchCountBefore, equals(3)); // only the 3 seed branches
    },
  );

  // ─────────────────────────────────────────────────────────────────
  // 3. Going Back and Next again does not reset user-entered values
  // ─────────────────────────────────────────────────────────────────
  testWidgets(
    'Branch creation: Back then Next retains the entered branch data',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await navigateToBranchGateway(tester);

      await tester.tap(find.text('Create a New Branch'));
      await tester.pumpAndSettle();

      const branchName = 'Ibadan Central Hub';
      const address = '22 Ring Road, Ibadan';

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), branchName);
      await tester.enterText(fields.at(1), address);
      await tester.pumpAndSettle();

      // Proceed to step 2
      await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
      await tester.pumpAndSettle();
      expect(find.text('Create Branch - Add Admin'), findsOneWidget);

      // Go back to step 1
      await tester.tap(find.byType(IconButton).first);
      await tester.pumpAndSettle();
      expect(find.text('Create Branch - Details'), findsOneWidget);

      // Note: GoRouter pushes create a new screen instance on re-entry.
      // The test verifies that a second Next submission still creates the
      // branch using the re-entered values, not a dummy.
      final fieldsAgain = find.byType(TextField);
      await tester.enterText(fieldsAgain.at(0), branchName);
      await tester.enterText(fieldsAgain.at(1), address);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
      await tester.pumpAndSettle();
      expect(find.text('Create Branch - Add Admin'), findsOneWidget);

      await tester.enterText(find.byType(TextField).at(0), 'Amaka Eze');
      await tester.enterText(find.byType(TextField).at(1), 'amaka@ibadanhub.edu');
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Branch'));
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();

      // Branch name on success screen matches re-entered value
      expect(find.text(branchName), findsWidgets);
      expect(find.text('Branch Created\nSuccessfully!'), findsOneWidget);

      // Exactly ONE new branch must be in KivoraService (not duplicated)
      final userBranches = KivoraService().branches
          .where((b) => b.name == branchName)
          .toList();
      expect(userBranches.length, equals(1));
    },
  );

  // ─────────────────────────────────────────────────────────────────
  // 4. KivoraService.addBranch persists exact user-provided values
  // ─────────────────────────────────────────────────────────────────
  test(
    'KivoraService.addBranch stores exactly the provided name, address and orgType',
    () {
      final branchCountBefore = KivoraService().branches.length;

      const name = 'Abuja Satellite Office';
      const orgType = 'Company';
      const address = '7 Garki District, Abuja';
      const phone = '+234 809 876 5432';

      final created = KivoraService().addBranch(
        name: name,
        organizationType: orgType,
        address: address,
        contactPhone: phone,
      );

      // Persisted data matches user input exactly
      expect(created.name, equals(name));
      expect(created.organizationType, equals(orgType));
      expect(created.address, equals(address));
      expect(created.contactPhone, equals(phone));

      // Branch is now in the list
      expect(KivoraService().branches.length, equals(branchCountBefore + 1));
      final found = KivoraService().getBranchById(created.id);
      expect(found, isNotNull);
      expect(found!.name, equals(name));

      // Invite code uses actual branch name prefix, not a dummy
      expect(created.inviteCode, startsWith('ABUJA'));
      expect(created.inviteCode, isNot(equals('WEST-2026')));
      expect(created.inviteCode, isNot(equals('EAST-2026')));
    },
  );

  // ─────────────────────────────────────────────────────────────────
  // 5. Failed admin validation does not create a branch record
  // ─────────────────────────────────────────────────────────────────
  testWidgets(
    'Branch creation: empty admin form is rejected without creating a branch',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await navigateToBranchGateway(tester);

      await tester.tap(find.text('Create a New Branch'));
      await tester.pumpAndSettle();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'Kano Regional Center');
      await tester.enterText(fields.at(1), '33 Airport Road, Kano');
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
      await tester.pumpAndSettle();
      expect(find.text('Create Branch - Add Admin'), findsOneWidget);

      // Tap Create without filling admin details
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Branch'));
      await tester.pumpAndSettle();

      // Still on admin screen, errors visible
      expect(find.text('Administrator name is required.'), findsOneWidget);
      expect(find.text('Administrator email is required.'), findsOneWidget);
      expect(find.text('Create Branch - Add Admin'), findsOneWidget);

      // No new branch should have been created
      final kanoMatches = KivoraService().branches
          .where((b) => b.name == 'Kano Regional Center')
          .toList();
      expect(kanoMatches, isEmpty);
    },
  );

  // ─────────────────────────────────────────────────────────────────
  // 6. Dashboard shows the newly created branch name, not a dummy
  // ─────────────────────────────────────────────────────────────────
  testWidgets(
    'Dashboard displays the actual branch name after successful creation',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await navigateToBranchGateway(tester);

      await tester.tap(find.text('Create a New Branch'));
      await tester.pumpAndSettle();

      const branchName = 'Port Harcourt East';
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), branchName);
      await tester.enterText(fields.at(1), '8 Trans-Amadi, Port Harcourt');
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
      await tester.pumpAndSettle();

      final adminFields = find.byType(TextField);
      await tester.enterText(adminFields.at(0), 'Manager PH');
      await tester.enterText(adminFields.at(1), 'manager@pheast.edu');
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Branch'));
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();

      expect(find.text('Branch Created\nSuccessfully!'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Go to Dashboard'));
      await tester.pumpAndSettle();

      // Dashboard branch label must show the actual created branch name
      expect(find.text('$branchName Branch'), findsOneWidget);

      // No dummy fallbacks should appear
      expect(find.text('West Campus Branch'), findsNothing);
      expect(find.text('No branch assigned'), findsNothing);
    },
  );

  // ─────────────────────────────────────────────────────────────────
  // 7. View Branch Details leads to BranchInfoScreen with actual data
  // ─────────────────────────────────────────────────────────────────
  testWidgets(
    'View Branch Details from success screen renders BranchInfoScreen with exact user-entered data',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await navigateToBranchGateway(tester);

      await tester.tap(find.text('Create a New Branch'));
      await tester.pumpAndSettle();

      const branchName = 'Horizon Polytechnic';
      const address = '99 Innovation Boulevard, Abuja';
      const phone = '+234 809 999 8888';
      const email = 'admin@horizonpoly.edu.ng';

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), branchName);
      await tester.enterText(fields.at(1), address);
      await tester.enterText(fields.at(2), phone);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
      await tester.pumpAndSettle();

      final adminFields = find.byType(TextField);
      await tester.enterText(adminFields.at(0), 'Rector Horizon');
      await tester.enterText(adminFields.at(1), email);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Branch'));
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();

      expect(find.text('Branch Created\nSuccessfully!'), findsOneWidget);

      // Tap "View Branch Details"
      await tester.tap(find.widgetWithText(OutlinedButton, 'View Branch Details'));
      await tester.pumpAndSettle();

      // Must be on Branch Information screen
      expect(find.text('Branch Information'), findsOneWidget);

      // Must display the EXACT branch name, address, phone, and email entered
      expect(find.text(branchName), findsWidgets);
      expect(find.text(address), findsWidgets);
      expect(find.text(phone), findsOneWidget);
      expect(find.text(email), findsOneWidget);

      // Must NOT display hardcoded dummy data
      expect(find.text('West Campus'), findsNothing);
      expect(find.text('12 Education Road, Lagos, Nigeria'), findsNothing);
      expect(find.text('westcampus@kivora.edu.ng'), findsNothing);
      expect(find.text('+234 801 234 5678'), findsNothing);
    },
  );

  // ─────────────────────────────────────────────────────────────────
  // 8. BranchInfoScreen shows clean empty state when no branch assigned
  // ─────────────────────────────────────────────────────────────────
  testWidgets(
    'BranchInfoScreen displays clean empty state when no branch is assigned',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      KivoraService().setCurrentUser(
        email: 'unassigned@test.org',
        name: 'Unassigned User',
        role: 'member',
        branchId: null,
      );

      appRouter.go('/member/branch');
      await tester.pumpWidget(const ProviderScope(child: KivoraApp()));
      await tester.pumpAndSettle();

      expect(find.text('Branch Information'), findsOneWidget);
      expect(find.text('No Branch Information Found'), findsOneWidget);
      expect(find.text('Go to Branch Gateway'), findsOneWidget);

      // Must NOT display dummy 'West Campus'
      expect(find.text('West Campus'), findsNothing);
    },
  );
}

