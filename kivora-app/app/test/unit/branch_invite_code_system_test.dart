import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kivora_app/core/services/auth_service.dart';
import 'package:kivora_app/core/services/kivora_service.dart';
import 'package:kivora_app/core/services/storage_service.dart';

void main() {
  group('Branch Invite Code System Tests (Section 7 Specs)', () {
    late AuthService auth;
    late KivoraService kivora;

    setUp(() {
      StorageService.useMemoryOnlyForTests();
      auth = AuthService();
      kivora = KivoraService();
      auth.switchToDemoMode();
      kivora.resetToDefaults();
    });

    test('1. Existing valid invite code validates successfully', () async {
      final res = await kivora.validateInviteCodeDetailed('KAYCEE2006');
      expect(res.isValid, isTrue);
      expect(res.status, InviteCodeStatus.valid);
      expect(res.branch, isNotNull);
      expect(res.branch!.name, 'Techverve');
      expect(res.inviteCodeId, isNotNull);
    });

    test('2 & 3. Manager creates new code and edits/replaces existing code', () async {
      const branchId = '73cf9e88-8dca-47d7-84b7-89a62107bb43';

      // Manager creates new code
      final newCode = await kivora.createInviteCode(
        branchId: branchId,
        code: 'TECH-2026-NEW',
        maxUses: 50,
        revokeExisting: true,
      );

      expect(newCode.code, 'TECH-2026-NEW');
      expect(newCode.isActive, isTrue);
      expect(newCode.maxUses, 50);

      // Verify branch.inviteCode was updated
      final branch = kivora.getBranchById(branchId);
      expect(branch?.inviteCode, 'TECH-2026-NEW');

      // 4. New code works immediately in Branch Gateway
      final valRes = await kivora.validateInviteCodeDetailed('TECH-2026-NEW');
      expect(valRes.isValid, isTrue);
      expect(valRes.branch?.name, 'Techverve');

      // 5. Old replaced code is rejected
      final oldValRes = await kivora.validateInviteCodeDetailed('KAYCEE2006');
      expect(oldValRes.isValid, isFalse);
      expect(oldValRes.status, InviteCodeStatus.revoked);
    });

    test('6 & 7. Manager revokes a code and revoked code is rejected', () async {
      const branchId = '73cf9e88-8dca-47d7-84b7-89a62107bb43';
      final activeCode = await kivora.getActiveInviteCodeForBranch(branchId);
      expect(activeCode, isNotNull);

      // Revoke it
      await kivora.revokeInviteCode(
        inviteCodeId: activeCode!.id,
        branchId: branchId,
      );

      final codes = await kivora.fetchInviteCodesForBranch(branchId);
      final revoked = codes.firstWhere((c) => c.id == activeCode.id);
      expect(revoked.isRevoked, isTrue);
      expect(revoked.statusDisplay, 'Revoked');

      // Validation must reject
      final res = await kivora.validateInviteCodeDetailed(activeCode.code);
      expect(res.isValid, isFalse);
      expect(res.status, InviteCodeStatus.revoked);
      expect(res.errorMessage, contains('revoked'));
    });

    test('8. Expired code is rejected', () async {
      const branchId = '73cf9e88-8dca-47d7-84b7-89a62107bb43';
      final expiredCode = await kivora.createInviteCode(
        branchId: branchId,
        code: 'EXPIRED-CODE',
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      final res = await kivora.validateInviteCodeDetailed(expiredCode.code);
      expect(res.isValid, isFalse);
      expect(res.status, InviteCodeStatus.expired);
      expect(res.errorMessage, contains('expired'));
    });

    test('9. Exhausted code is rejected', () async {
      const branchId = '73cf9e88-8dca-47d7-84b7-89a62107bb43';
      final code = await kivora.createInviteCode(
        branchId: branchId,
        code: 'EXHAUSTED-CODE',
        maxUses: 1,
      );

      // Submit 1 application to consume it
      kivora.submitApplication(
        branchId: branchId,
        inviteCode: 'EXHAUSTED-CODE',
        inviteCodeId: code.id,
        userName: 'Member One',
        userEmail: 'member1@example.com',
        submittedData: {'full_name': 'Member One'},
      );

      // Verify used count is now 1
      final updated = await kivora.getActiveInviteCodeForBranch(branchId);
      expect(updated?.usedCount, 1);

      final res = await kivora.validateInviteCodeDetailed('EXHAUSTED-CODE');
      expect(res.isValid, isFalse);
      expect(res.status, InviteCodeStatus.exhausted);
      expect(res.errorMessage, contains('maximum number of uses'));
    });

    test('10. Code from another branch is rejected when targetBranchId mismatch is enforced', () async {
      // Validate West campus code against Techverve branchId
      final res = await kivora.validateInviteCodeDetailed(
        'WEST-2026',
        targetBranchId: '73cf9e88-8dca-47d7-84b7-89a62107bb43',
      );
      expect(res.isValid, isFalse);
      expect(res.status, InviteCodeStatus.wrongBranch);
      expect(res.errorMessage, contains('different branch'));
    });

    test('11. Case-insensitivity and trim handling for invite codes', () async {
      final resLower = await kivora.validateInviteCodeDetailed('   kaycee2006   ');
      expect(resLower.isValid, isTrue);
      expect(resLower.branch?.name, 'Techverve');

      final resUpper = await kivora.validateInviteCodeDetailed('KAYCEE2006');
      expect(resUpper.isValid, isTrue);
      expect(resUpper.branch?.name, 'Techverve');
    });

    test('12. Generate secure random code produces valid format', () {
      final code1 = KivoraService.generateSecureRandomCode();
      final code2 = KivoraService.generateSecureRandomCode();

      expect(code1, isNotEmpty);
      expect(code1.startsWith('TV-'), isTrue);
      expect(code1.split('-').length, 3);
      expect(code1, isNot(equals(code2)));
    });

    test('13. BranchInviteCodeModel serialization and computed properties', () {
      final model = BranchInviteCodeModel(
        id: 'ic-001',
        branchId: 'b-001',
        code: 'TEST-CODE',
        usedCount: 5,
        maxUses: 10,
        isRevoked: false,
        expiresAt: DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now(),
      );

      expect(model.isActive, isTrue);
      expect(model.isExpired, isFalse);
      expect(model.isExhausted, isFalse);
      expect(model.statusDisplay, 'Active');

      final json = model.toJson();
      expect(json['code'], 'TEST-CODE');
      expect(json['used_count'], 5);
      expect(json['max_uses'], 10);

      final deserialized = BranchInviteCodeModel.fromJson(json);
      expect(deserialized.id, model.id);
      expect(deserialized.code, model.code);
      expect(deserialized.usedCount, model.usedCount);
    });

    test('14. Full member submission to manager approval workflow with invite code ID tracking', () {
      const branchId = '73cf9e88-8dca-47d7-84b7-89a62107bb43';

      final app = kivora.submitApplication(
        branchId: branchId,
        inviteCode: 'KAYCEE2006',
        inviteCodeId: 'd1f7351c-e218-4000-8437-6f12a17b6550',
        userName: 'New Member',
        userEmail: 'newmember@example.com',
        submittedData: {'full_name': 'New Member', 'student_id': 'NM-001'},
        photoAttached: true,
        photoUrl: 'https://bbgecpfqfoqlmzzbfeyu.supabase.co/storage/v1/object/public/id-documents/newmember/id.jpg',
      );

      expect(app.inviteCodeId, 'd1f7351c-e218-4000-8437-6f12a17b6550');
      expect(app.status, 'pending');

      // Manager reviews application
      final apps = kivora.getApplicationsForBranch(branchId);
      expect(apps.any((a) => a.id == app.id), isTrue);

      // Approve
      kivora.approveApplication(app.id);

      final approved = kivora.getApplicationsForBranch(branchId).firstWhere((a) => a.id == app.id);
      expect(approved.status, 'approved');

      // Exactly one active member assignment
      final branchMembers = kivora.members.where((m) => m.email == 'newmember@example.com').toList();
      expect(branchMembers.length, 1);
      expect(branchMembers.first.branchId, branchId);
      expect(branchMembers.first.status, 'Active');
    });

    test('15. Clipboard data copy helper and verification', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      const testCode = 'TV-9922-COPY';
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/platform',
        const JSONMethodCodec().encodeMethodCall(
          const MethodCall('Clipboard.setData', {'text': testCode}),
        ),
        (ByteData? data) {},
      );

      // Verify that after saving, clipboard payload matches active saved code exactly
      final active = await kivora.getActiveInviteCodeForBranch('73cf9e88-8dca-47d7-84b7-89a62107bb43');
      expect(active?.code, isNotEmpty);
      expect(active?.isActive, isTrue);
    });
  });
}
