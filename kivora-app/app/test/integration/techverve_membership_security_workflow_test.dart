import 'package:flutter_test/flutter_test.dart';
import 'package:kivora_app/core/services/auth_service.dart';
import 'package:kivora_app/core/services/kivora_service.dart';
import 'package:kivora_app/core/services/storage_service.dart';

void main() {
  group('Techverve Membership Security Workflow & Routing Verification', () {
    late AuthService auth;
    late KivoraService kivora;

    setUp(() {
      StorageService.useMemoryOnlyForTests();
      auth = AuthService();
      kivora = KivoraService();
      auth.switchToDemoMode();
      kivora.resetToDefaults();
    });

    test('1. Role Resolution: Distinguishes Manager and Member routing correctly', () {
      // Branch Manager role resolution
      expect(KivoraService.isManagementRole('branch_manager'), isTrue);
      expect(KivoraService.isManagementRole('branch_admin'), isTrue);
      expect(KivoraService.isManagementRole('web_admin'), isTrue);
      expect(KivoraService.isManagementRole('member'), isFalse);

      // Simulate Techverve Manager state
      kivora.setCurrentUser(
        email: 'asogwakenechukwu284@gmail.com',
        name: 'Kenechukwu Asogwa (Manager)',
        role: 'branch_manager',
        branchId: '73cf9e88-8dca-47d7-84b7-89a62107bb43',
      );
      expect(kivora.isManagerOrAdmin, isTrue, reason: 'Manager should route to Manager Dashboard');
      expect(kivora.currentRole, 'branch_manager');

      // Simulate Techverve Member state (unassigned / fresh onboarding)
      kivora.setCurrentUser(
        email: 'kenechukwuasogwa284@gmail.com',
        name: 'Kenechukwu Asogwa (Member)',
        role: 'member',
        branchId: null,
      );
      expect(kivora.isManagerOrAdmin, isFalse, reason: 'Member should route to Gateway/Home');
      expect(kivora.currentBranchId, isNull);
    });

    test('2. Branch Gateway: Validates valid, invalid, and empty invite codes', () async {
      // Valid Techverve invite code
      final validBranch = await kivora.validateInviteCode('KAYCEE2006');
      expect(validBranch, isNotNull);
      expect(validBranch!.name, 'Techverve');

      // Lowercase valid invite code (case insensitivity)
      final validLower = await kivora.validateInviteCode('kaycee2006');
      expect(validLower, isNotNull);
      expect(validLower!.name, 'Techverve');

      // Invalid code
      final invalidBranch = await kivora.validateInviteCode('INVALID_CODE_999');
      expect(invalidBranch, isNull);

      // Empty / whitespace code
      final emptyBranch = await kivora.validateInviteCode('   ');
      expect(emptyBranch, isNull);
    });

    test('3. Membership Submission: Persists form fields, photo, and sets status to pending', () {
      final app = kivora.submitApplication(
        branchId: '73cf9e88-8dca-47d7-84b7-89a62107bb43',
        inviteCode: 'KAYCEE2006',
        userName: 'Kenechukwu Asogwa',
        userEmail: 'kenechukwuasogwa284@gmail.com',
        submittedData: {
          'full_name': 'Kenechukwu Asogwa',
          'email': 'kenechukwuasogwa284@gmail.com',
          'phone': '+2348012345678',
          'student_id': 'TV-2026-0042',
        },
        photoAttached: true,
        photoUrl: 'https://bbgecpfqfoqlmzzbfeyu.supabase.co/storage/v1/object/public/id-documents/d27832ee-9656-46dc-9677-08bb6df01261/id_1700000000.jpg',
      );

      expect(app.id, isNotEmpty);
      expect(app.status, 'pending');
      expect(app.branchId, '73cf9e88-8dca-47d7-84b7-89a62107bb43');
      expect(app.photoAttached, isTrue);
      expect(app.photoUrl, contains('id-documents'));
      expect(app.submittedData['student_id'], 'TV-2026-0042');
    });

    test('4. Manager Approval: Updates request status and provisions member assignment', () {
      final app = kivora.submitApplication(
        branchId: '73cf9e88-8dca-47d7-84b7-89a62107bb43',
        inviteCode: 'KAYCEE2006',
        userName: 'Kenechukwu Asogwa',
        userEmail: 'kenechukwuasogwa284@gmail.com',
        submittedData: {'full_name': 'Kenechukwu Asogwa'},
        photoAttached: true,
      );

      // Approve application
      kivora.approveApplication(app.id);

      final applications = kivora.getApplicationsForBranch('73cf9e88-8dca-47d7-84b7-89a62107bb43');
      final approvedApp = applications.firstWhere((a) => a.id == app.id);
      expect(approvedApp.status, 'approved');

      // Verify member is now in branch member list
      final members = kivora.members;
      expect(members.any((m) => m.email == 'kenechukwuasogwa284@gmail.com' && m.branchId == '73cf9e88-8dca-47d7-84b7-89a62107bb43'), isTrue);
    });

    test('5. Manager Rejection: Sets status to rejected without granting active assignment', () {
      final app = kivora.submitApplication(
        branchId: '73cf9e88-8dca-47d7-84b7-89a62107bb43',
        inviteCode: 'KAYCEE2006',
        userName: 'Rejected Applicant',
        userEmail: 'rejected@example.com',
        submittedData: {'full_name': 'Rejected Applicant'},
        photoAttached: false,
      );

      // Reject application
      kivora.rejectApplication(app.id, reason: 'Invalid ID credentials provided');

      final applications = kivora.getApplicationsForBranch('73cf9e88-8dca-47d7-84b7-89a62107bb43');
      final rejectedApp = applications.firstWhere((a) => a.id == app.id);
      expect(rejectedApp.status, 'rejected');

      // Confirm no active member assignment was created
      final members = kivora.members;
      expect(members.any((m) => m.email == 'rejected@example.com'), isFalse);
    });
  });
}
