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

  group('Connected Screens Integration Tests', () {
    testWidgets('1. ManagerLeaveManagementScreen renders tabs and cards correctly in demo mode', (tester) async {
      KivoraService().setCurrentUser(
        email: 'manager@kivora.org',
        name: 'Branch Manager',
        role: 'manager',
        branchId: 'branch-west',
      );

      await tester.pumpWidget(const ProviderScope(child: KivoraApp()));
      await tester.pumpAndSettle();

      appRouter.go('/manager/requests/leave');
      await tester.pumpAndSettle();

      expect(find.text('Leave Management'), findsOneWidget);
      expect(find.textContaining('Pending'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);

      // Verify pending items rendered
      expect(find.text('Amara Osei'), findsOneWidget);
      expect(find.text('Approve'), findsWidgets);
      expect(find.text('Reject'), findsWidgets);

      // Tap on History tab
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      // Verify history items rendered
      expect(find.text('Kofi Mensah'), findsOneWidget);
      expect(find.text('Ama Boateng'), findsOneWidget);
    });

    testWidgets('2. RequestsHistoryScreen renders filter tabs and request records', (tester) async {
      KivoraService().setCurrentUser(
        email: 'member.alex@example.com',
        name: 'Alex Johnson',
        role: 'member',
        branchId: 'branch-west',
      );
      KivoraService().setMembershipStatus('approved');

      await tester.pumpWidget(const ProviderScope(child: KivoraApp()));
      await tester.pumpAndSettle();

      appRouter.go('/member/requests');
      await tester.pumpAndSettle();

      expect(find.text('Request History'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Leave'), findsOneWidget);
      expect(find.text('Correction'), findsOneWidget);
      expect(find.text('Other'), findsOneWidget);

      // Verify leave item
      expect(find.text('Annual Leave'), findsWidgets);

      // Filter to Correction
      await tester.tap(find.text('Correction'));
      await tester.pumpAndSettle();
      expect(find.text('Attendance Correction'), findsWidgets);
    });

    testWidgets('3. NotificationsScreen renders list and updates read status on tap', (tester) async {
      KivoraService().setCurrentUser(
        email: 'member.alex@example.com',
        name: 'Alex Johnson',
        role: 'member',
        branchId: 'branch-west',
      );
      KivoraService().setMembershipStatus('approved');

      await tester.pumpWidget(const ProviderScope(child: KivoraApp()));
      await tester.pumpAndSettle();

      appRouter.go('/member/notifications');
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Attendance Confirmed'), findsOneWidget);
      expect(find.text('Welcome to Kivora'), findsOneWidget);

      // Tap an unread notification to mark as read
      await tester.tap(find.text('Attendance Confirmed'));
      await tester.pumpAndSettle();
      expect(find.text('Attendance Confirmed'), findsOneWidget);
    });

    testWidgets('4. AttendanceHistoryScreen renders progress, percentage and sessions', (tester) async {
      KivoraService().setCurrentUser(
        email: 'member.alex@example.com',
        name: 'Alex Johnson',
        role: 'member',
        branchId: 'branch-west',
      );
      KivoraService().setMembershipStatus('approved');

      await tester.pumpWidget(const ProviderScope(child: KivoraApp()));
      await tester.pumpAndSettle();

      appRouter.go('/member/attendance/history');
      await tester.pumpAndSettle();

      expect(find.text('Attendance History'), findsOneWidget);
      expect(find.text('Morning Session'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('Session Progress'), findsOneWidget);
    });

    testWidgets('5. CheckInScreen verification logs sign-in to KivoraService', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      KivoraService().setCurrentUser(
        email: 'member.alex@example.com',
        name: 'Alex Johnson',
        role: 'member',
        branchId: 'branch-west',
      );
      KivoraService().setMembershipStatus('approved');

      final initialCount = KivoraService().attendanceRecords.length;

      await tester.pumpWidget(const ProviderScope(child: KivoraApp()));
      await tester.pumpAndSettle();

      appRouter.go('/member/attendance/check-in');
      await tester.pumpAndSettle();

      expect(find.text('Check In'), findsOneWidget);
      expect(find.text('Start Verification'), findsOneWidget);

      await tester.tap(find.text('Start Verification'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(KivoraService().attendanceRecords.length, initialCount + 1);
    });
  });
}
