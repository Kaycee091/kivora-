import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';
import 'storage_service.dart';

enum FieldType {
  text,
  longText,
  phone,
  email,
  date,
  photo,
}

class IdFormFieldModel {
  final String id;
  String label;
  FieldType type;
  bool isRequired;
  bool isEnabled;
  int order;

  IdFormFieldModel({
    required this.id,
    required this.label,
    required this.type,
    this.isRequired = true,
    this.isEnabled = true,
    required this.order,
  });

  IdFormFieldModel copyWith({
    String? label,
    FieldType? type,
    bool? isRequired,
    bool? isEnabled,
    int? order,
  }) {
    return IdFormFieldModel(
      id: id,
      label: label ?? this.label,
      type: type ?? this.type,
      isRequired: isRequired ?? this.isRequired,
      isEnabled: isEnabled ?? this.isEnabled,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'type': type.name,
    'isRequired': isRequired,
    'isEnabled': isEnabled,
    'order': order,
  };

  factory IdFormFieldModel.fromJson(Map<String, dynamic> json) => IdFormFieldModel(
    id: json['id'] as String,
    label: json['label'] as String,
    type: FieldType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => FieldType.text,
    ),
    isRequired: json['isRequired'] as bool? ?? true,
    isEnabled: json['isEnabled'] as bool? ?? true,
    order: json['order'] as int? ?? 0,
  );
}

class BranchModel {
  final String id;
  final String name;
  final String organizationType;
  final String address;
  final String contactPhone;
  final String contactEmail;
  final String description;
  final String inviteCode;
  final bool isActive;
  final String managerId;

  BranchModel({
    required this.id,
    required this.name,
    required this.organizationType,
    required this.address,
    required this.contactPhone,
    this.contactEmail = '',
    this.description = '',
    required this.inviteCode,
    this.isActive = true,
    this.managerId = 'mgr-001',
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      organizationType: json['organization_type'] as String? ?? json['organizationType'] as String? ?? 'School',
      address: json['address'] as String? ?? '',
      contactPhone: json['contact_phone'] as String? ?? json['contactPhone'] as String? ?? '',
      contactEmail: json['contact_email'] as String? ?? json['contactEmail'] as String? ?? '',
      description: json['description'] as String? ?? '',
      inviteCode: json['branch_code'] as String? ?? json['inviteCode'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
      managerId: json['created_by'] as String? ?? json['managerId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'organizationType': organizationType,
    'address': address,
    'contactPhone': contactPhone,
    'contactEmail': contactEmail,
    'description': description,
    'inviteCode': inviteCode,
    'isActive': isActive,
    'managerId': managerId,
  };
}

enum InviteCodeStatus {
  valid,
  invalid,
  expired,
  revoked,
  exhausted,
  wrongBranch,
  disallowedRole,
  connectionError,
}

class BranchInviteCodeModel {
  final String id;
  final String branchId;
  final String code;
  final String? createdBy;
  final List<String> allowedRoles;
  final int? maxUses;
  final int usedCount;
  final DateTime? expiresAt;
  final bool isRevoked;
  final DateTime? createdAt;

  BranchInviteCodeModel({
    required this.id,
    required this.branchId,
    required this.code,
    this.createdBy,
    this.allowedRoles = const ['member'],
    this.maxUses = 50,
    this.usedCount = 0,
    this.expiresAt,
    this.isRevoked = false,
    this.createdAt,
  });

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isExhausted => maxUses != null && usedCount >= maxUses!;
  bool get isActive => !isRevoked && !isExpired && !isExhausted;

  String get statusDisplay {
    if (isRevoked) return 'Revoked';
    if (isExpired) return 'Expired';
    if (isExhausted) return 'Exhausted';
    return 'Active';
  }

  factory BranchInviteCodeModel.fromJson(Map<String, dynamic> json) {
    DateTime? exp;
    if (json['expires_at'] != null) {
      exp = DateTime.tryParse(json['expires_at'].toString());
    }
    DateTime? created;
    if (json['created_at'] != null) {
      created = DateTime.tryParse(json['created_at'].toString());
    }
    List<String> roles = ['member'];
    if (json['allowed_roles'] is List) {
      roles = (json['allowed_roles'] as List).map((e) => e.toString()).toList();
    }

    return BranchInviteCodeModel(
      id: json['id'] as String? ?? '',
      branchId: json['branch_id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      createdBy: json['created_by'] as String?,
      allowedRoles: roles,
      maxUses: json['max_uses'] as int?,
      usedCount: json['used_count'] as int? ?? 0,
      expiresAt: exp,
      isRevoked: json['is_revoked'] as bool? ?? false,
      createdAt: created,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'branch_id': branchId,
    'code': code,
    'created_by': createdBy,
    'allowed_roles': allowedRoles,
    'max_uses': maxUses,
    'used_count': usedCount,
    'expires_at': expiresAt?.toIso8601String(),
    'is_revoked': isRevoked,
    'created_at': createdAt?.toIso8601String(),
  };

  BranchInviteCodeModel copyWith({
    String? id,
    String? branchId,
    String? code,
    String? createdBy,
    List<String>? allowedRoles,
    int? maxUses,
    bool clearMaxUses = false,
    int? usedCount,
    DateTime? expiresAt,
    bool clearExpiresAt = false,
    bool? isRevoked,
    DateTime? createdAt,
  }) {
    return BranchInviteCodeModel(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      code: code ?? this.code,
      createdBy: createdBy ?? this.createdBy,
      allowedRoles: allowedRoles ?? this.allowedRoles,
      maxUses: clearMaxUses ? null : (maxUses ?? this.maxUses),
      usedCount: usedCount ?? this.usedCount,
      expiresAt: clearExpiresAt ? null : (expiresAt ?? this.expiresAt),
      isRevoked: isRevoked ?? this.isRevoked,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class InviteValidationResult {
  final bool isValid;
  final BranchModel? branch;
  final String? inviteCodeId;
  final String code;
  final InviteCodeStatus status;
  final String? errorMessage;

  const InviteValidationResult({
    required this.isValid,
    this.branch,
    this.inviteCodeId,
    required this.code,
    required this.status,
    this.errorMessage,
  });
}

class BranchDraftModel {
  final String draftId;
  String name;
  String organizationType;
  String address;
  String contactPhone;
  String description;
  String adminName;
  String adminEmail;
  String adminPhone;
  String adminRole;

  BranchDraftModel({
    required this.draftId,
    this.name = '',
    this.organizationType = 'School',
    this.address = '',
    this.contactPhone = '',
    this.description = '',
    this.adminName = '',
    this.adminEmail = '',
    this.adminPhone = '',
    this.adminRole = 'Branch Manager',
  });

  Map<String, dynamic> toJson() => {
    'draftId': draftId,
    'name': name,
    'organizationType': organizationType,
    'address': address,
    'contactPhone': contactPhone,
    'description': description,
    'adminName': adminName,
    'adminEmail': adminEmail,
    'adminPhone': adminPhone,
    'adminRole': adminRole,
  };

  factory BranchDraftModel.fromJson(Map<String, dynamic> json) => BranchDraftModel(
    draftId: json['draftId'] as String? ?? 'draft-${DateTime.now().millisecondsSinceEpoch}',
    name: json['name'] as String? ?? '',
    organizationType: json['organizationType'] as String? ?? 'School',
    address: json['address'] as String? ?? '',
    contactPhone: json['contactPhone'] as String? ?? '',
    description: json['description'] as String? ?? '',
    adminName: json['adminName'] as String? ?? '',
    adminEmail: json['adminEmail'] as String? ?? '',
    adminPhone: json['adminPhone'] as String? ?? '',
    adminRole: json['adminRole'] as String? ?? 'Branch Manager',
  );
}

class MembershipApplicationModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String branchId;
  final String branchName;
  final String inviteCode;
  final String? inviteCodeId;
  final Map<String, dynamic> submittedData;
  final bool photoAttached;
  final String? photoUrl;
  String status; // 'pending', 'approved', 'rejected'
  final DateTime submittedAt;
  DateTime? reviewedAt;
  String? reviewerNotes;

  MembershipApplicationModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.branchId,
    required this.branchName,
    required this.inviteCode,
    this.inviteCodeId,
    required this.submittedData,
    this.photoAttached = false,
    this.photoUrl,
    this.status = 'pending',
    required this.submittedAt,
    this.reviewedAt,
    this.reviewerNotes,
  });
}

class AttendanceRecordModel {
  final String id;
  final String memberId;
  final String memberName;
  final String memberEmail;
  final String branchId;
  final DateTime signInTime;
  final String verificationMethod;

  AttendanceRecordModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.memberEmail,
    required this.branchId,
    required this.signInTime,
    required this.verificationMethod,
  });
}

class MemberProfileModel {
  final String memberId;
  final String name;
  final String email;
  final String phone;
  final String branchId;
  final String branchName;
  final String role;
  String status; // 'Active', 'Pending', 'Rejected'
  final bool photoAttached;
  final Map<String, dynamic> submittedFields;
  final DateTime joinedAt;

  MemberProfileModel({
    required this.memberId,
    required this.name,
    required this.email,
    required this.phone,
    required this.branchId,
    required this.branchName,
    this.role = 'Student',
    this.status = 'Active',
    this.photoAttached = true,
    required this.submittedFields,
    required this.joinedAt,
  });
}

/// Standard RFC 4122 v4 UUID generator (pure Dart, zero external plugin dependencies)
String generateUuidV4() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(256));
  values[6] = (values[6] & 0x0f) | 0x40; // Version 4
  values[8] = (values[8] & 0x3f) | 0x80; // Variant 10
  return '${values.sublist(0, 4).map((b) => b.toRadixString(16).padLeft(2, '0')).join()}-'
      '${values.sublist(4, 6).map((b) => b.toRadixString(16).padLeft(2, '0')).join()}-'
      '${values.sublist(6, 8).map((b) => b.toRadixString(16).padLeft(2, '0')).join()}-'
      '${values.sublist(8, 10).map((b) => b.toRadixString(16).padLeft(2, '0')).join()}-'
      '${values.sublist(10, 16).map((b) => b.toRadixString(16).padLeft(2, '0')).join()}';
}

class KivoraService extends ChangeNotifier {
  static final KivoraService _instance = KivoraService._internal();
  factory KivoraService() => _instance;

  KivoraService._internal() {
    AuthService().registerSignOutHandler(() => clearSession());
    if (AuthService().isDemoMode) {
      initializeDemoMode();
    } else {
      initializeLiveMode();
    }
  }

  // Active branches
  final List<BranchModel> _branches = [];
  List<BranchModel> get branches => List.unmodifiable(_branches);

  // In-progress branch wizard draft
  BranchDraftModel? _branchDraft;
  BranchDraftModel? get branchDraft => _branchDraft;

  // Last successfully created branch in this session (idempotency token)
  BranchModel? _lastCreatedBranch;
  BranchModel? get lastCreatedBranch => _lastCreatedBranch;

  // Per-branch form configurations: branchId -> List<IdFormFieldModel>
  final Map<String, List<IdFormFieldModel>> _idFormConfigs = {};

  // Membership applications
  final List<MembershipApplicationModel> _applications = [];
  List<MembershipApplicationModel> get applications => List.unmodifiable(_applications);

  // Branch invite codes
  final List<BranchInviteCodeModel> _inviteCodes = [];
  List<BranchInviteCodeModel> get inviteCodes => List.unmodifiable(_inviteCodes);

  // Attendance sign-in records
  final List<AttendanceRecordModel> _attendanceRecords = [];
  List<AttendanceRecordModel> get attendanceRecords => List.unmodifiable(_attendanceRecords);

  // Member profiles
  final Map<String, MemberProfileModel> _members = {};
  List<MemberProfileModel> get members => _members.values.toList();

  // Current session/user state
  String _currentUserId = 'usr-current';
  String _currentUserEmail = '';
  String _currentUserName = '';
  String _currentRole = 'guest'; // 'guest', 'member', 'manager', 'admin'
  String? _currentBranchId;
  MembershipApplicationModel? _currentApplication;

  bool _isAuthenticated = false;
  bool _isEmailVerified = true;
  String _membershipStatus = 'none'; // 'none', 'pending', 'approved', 'rejected'
  bool _isAuthLoading = false;
  String? _lastError;

  bool get isAuthenticated => _isAuthenticated || _currentUserEmail.isNotEmpty;
  bool get isEmailVerified => _isEmailVerified;
  String get membershipStatus => _membershipStatus;
  bool get isAuthLoading => _isAuthLoading;
  String? get lastError => _lastError;

  void clearLastError() => _lastError = null;

  /// Returns true if the given role string represents an authorized management role
  /// (branch_manager, branch_admin, web_admin, manager, admin).
  static bool isManagementRole(String? role) {
    if (role == null) return false;
    final r = role.toLowerCase().trim();
    return r == 'branch_manager' ||
        r == 'branch_admin' ||
        r == 'web_admin' ||
        r == 'manager' ||
        r == 'admin';
  }

  /// Whether the currently signed-in user holds a management role.
  bool get isManagerOrAdmin => isManagementRole(_currentRole);

  void setAuthLoading(bool loading) {
    _isAuthLoading = loading;
    notifyListeners();
  }

  String get currentUserId => _currentUserId;
  String get currentUserEmail => _currentUserEmail;
  String get currentUserName => _currentUserName;
  String get currentRole => _currentRole;
  String? get currentBranchId => _currentBranchId;
  MembershipApplicationModel? get currentApplication => _currentApplication;

  void setCurrentBranchId(String? branchId) {
    _currentBranchId = branchId;
    notifyListeners();
  }

  // --- Explicit Mode Initialization ---

  /// Initializes LIVE mode with zero mock branches, zero mock applications, and zero mock users.
  void initializeLiveMode() {
    _branches.clear();
    _inviteCodes.clear();
    _idFormConfigs.clear();
    _applications.clear();
    _attendanceRecords.clear();
    _members.clear();
    _currentBranchId = null;
    _lastCreatedBranch = null;
    notifyListeners();
  }

  /// Initializes DEMO mode with clearly labeled demo mock data.
  void initializeDemoMode() {
    _branches.clear();
    _inviteCodes.clear();
    _idFormConfigs.clear();
    _applications.clear();
    _attendanceRecords.clear();
    _members.clear();
    _lastCreatedBranch = null;

    final now = DateTime.now();

    // Seed default Techverve invite code record
    _inviteCodes.add(
      BranchInviteCodeModel(
        id: 'd1f7351c-e218-4000-8437-6f12a17b6550',
        branchId: '73cf9e88-8dca-47d7-84b7-89a62107bb43',
        code: 'KAYCEE2006',
        createdBy: '511e1b7e-5cdf-4619-99a0-7e2fa9beafb4',
        allowedRoles: const ['member'],
        maxUses: 100,
        usedCount: 0,
        expiresAt: DateTime.now().add(const Duration(days: 730)),
        isRevoked: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    );
    _inviteCodes.add(
      BranchInviteCodeModel(
        id: 'ic-west-001',
        branchId: 'branch-west',
        code: 'WEST-2026',
        createdBy: 'mgr-001',
        allowedRoles: const ['member'],
        maxUses: 50,
        usedCount: 0,
        expiresAt: DateTime.now().add(const Duration(days: 30)),
        isRevoked: false,
        createdAt: DateTime.now(),
      ),
    );
    _inviteCodes.add(
      BranchInviteCodeModel(
        id: 'ic-east-001',
        branchId: 'branch-east',
        code: 'EAST-2026',
        createdBy: 'mgr-002',
        allowedRoles: const ['member'],
        maxUses: 50,
        usedCount: 0,
        expiresAt: DateTime.now().add(const Duration(days: 30)),
        isRevoked: false,
        createdAt: DateTime.now(),
      ),
    );

    // Seed branches (Techverve primary branch preserved)
    _branches.addAll([
      BranchModel(
        id: '73cf9e88-8dca-47d7-84b7-89a62107bb43',
        name: 'Techverve',
        organizationType: 'Organization',
        address: 'Techverve Main Campus',
        contactPhone: '+234 801 234 5678',
        contactEmail: 'asogwakenechukwu284@gmail.com',
        inviteCode: 'KAYCEE2006',
        isActive: true,
        managerId: '511e1b7e-5cdf-4619-99a0-7e2fa9beafb4',
      ),
      BranchModel(
        id: 'branch-west',
        name: 'West Campus',
        organizationType: 'School',
        address: '12 Education Road, Lagos, Nigeria',
        contactPhone: '+234 801 234 5678',
        contactEmail: 'westcampus@kivora.edu.ng',
        inviteCode: 'WEST-2026',
        isActive: true,
        managerId: 'mgr-001',
      ),
      BranchModel(
        id: 'branch-east',
        name: 'East Campus',
        organizationType: 'College',
        address: '45 Independence Layout, Enugu, Nigeria',
        contactPhone: '+234 802 345 6789',
        contactEmail: 'eastcampus@kivora.edu.ng',
        inviteCode: 'EAST-2026',
        isActive: true,
        managerId: 'mgr-002',
      ),
      BranchModel(
        id: 'branch-north',
        name: 'North Campus',
        organizationType: 'Institute',
        address: '88 Bompai Road, Kano, Nigeria',
        contactPhone: '+234 803 456 7890',
        contactEmail: 'northcampus@kivora.edu.ng',
        inviteCode: 'NORTH-2026',
        isActive: true,
        managerId: 'mgr-003',
      ),
    ]);

    // Demo ID Form Configs
    _idFormConfigs['73cf9e88-8dca-47d7-84b7-89a62107bb43'] = [
      IdFormFieldModel(id: 'photo', label: 'Identity Photo', type: FieldType.photo, isRequired: true, isEnabled: true, order: 0),
      IdFormFieldModel(id: 'full_name', label: 'Full Name', type: FieldType.text, isRequired: true, isEnabled: true, order: 1),
      IdFormFieldModel(id: 'email', label: 'Email Address', type: FieldType.email, isRequired: true, isEnabled: true, order: 2),
      IdFormFieldModel(id: 'phone', label: 'Phone Number', type: FieldType.phone, isRequired: true, isEnabled: true, order: 3),
      IdFormFieldModel(id: 'student_id', label: 'Student / Employee ID', type: FieldType.text, isRequired: true, isEnabled: true, order: 4),
    ];
    _idFormConfigs['branch-west'] = [
      IdFormFieldModel(id: 'photo', label: 'Identity Photo', type: FieldType.photo, isRequired: true, isEnabled: true, order: 0),
      IdFormFieldModel(id: 'full_name', label: 'Full Name', type: FieldType.text, isRequired: true, isEnabled: true, order: 1),
      IdFormFieldModel(id: 'email', label: 'Email Address', type: FieldType.email, isRequired: true, isEnabled: true, order: 2),
      IdFormFieldModel(id: 'phone', label: 'Phone Number', type: FieldType.phone, isRequired: true, isEnabled: true, order: 3),
      IdFormFieldModel(id: 'student_id', label: 'Student / Employee ID', type: FieldType.text, isRequired: true, isEnabled: true, order: 4),
      IdFormFieldModel(id: 'nin_id', label: 'National ID (NIN)', type: FieldType.text, isRequired: false, isEnabled: true, order: 5),
    ];

    _idFormConfigs['branch-east'] = [
      IdFormFieldModel(id: 'photo', label: 'Profile Photo', type: FieldType.photo, isRequired: true, isEnabled: true, order: 0),
      IdFormFieldModel(id: 'full_name', label: 'Full Name', type: FieldType.text, isRequired: true, isEnabled: true, order: 1),
      IdFormFieldModel(id: 'email', label: 'Email Address', type: FieldType.email, isRequired: true, isEnabled: true, order: 2),
      IdFormFieldModel(id: 'phone', label: 'Phone Number', type: FieldType.phone, isRequired: true, isEnabled: true, order: 3),
      IdFormFieldModel(id: 'student_id', label: 'Matriculation Number', type: FieldType.text, isRequired: true, isEnabled: true, order: 4),
    ];

    // Demo Member Profiles
    _members['usr-001'] = MemberProfileModel(
      memberId: 'usr-001',
      name: 'Alex Johnson',
      email: 'alex.johnson@kivora.edu.ng',
      phone: '+234 801 234 5678',
      branchId: 'branch-west',
      branchName: 'West Campus',
      role: 'Student',
      status: 'Active',
      photoAttached: true,
      submittedFields: {
        'Full Name': 'Alex Johnson',
        'Email Address': 'alex.johnson@kivora.edu.ng',
        'Phone Number': '+234 801 234 5678',
        'Student / Employee ID': 'KIV-2026-0891',
        'National ID (NIN)': 'NIN-99482710492',
      },
      joinedAt: DateTime(now.year, now.month - 2, 12),
    );

    _members['usr-002'] = MemberProfileModel(
      memberId: 'usr-002',
      name: 'Michael Brown',
      email: 'michael.brown@kivora.edu.ng',
      phone: '+234 802 345 6789',
      branchId: 'branch-west',
      branchName: 'West Campus',
      role: 'Teacher',
      status: 'Active',
      photoAttached: true,
      submittedFields: {
        'full_name': 'Michael Brown',
        'email': 'michael.brown@kivora.edu.ng',
        'phone': '+234 802 345 6789',
        'student_id': 'STAFF-042',
      },
      joinedAt: DateTime(now.year, now.month - 3, 5),
    );

    _members['usr-003'] = MemberProfileModel(
      memberId: 'usr-003',
      name: 'Emily Davis',
      email: 'emily.davis@kivora.edu.ng',
      phone: '+234 803 456 7890',
      branchId: 'branch-west',
      branchName: 'West Campus',
      role: 'Staff',
      status: 'Active',
      photoAttached: true,
      submittedFields: {
        'full_name': 'Emily Davis',
        'email': 'emily.davis@kivora.edu.ng',
        'phone': '+234 803 456 7890',
        'student_id': 'STAFF-088',
      },
      joinedAt: DateTime(now.year, now.month - 1, 20),
    );

    // Demo Attendance Records
    _attendanceRecords.addAll([
      AttendanceRecordModel(
        id: 'att-101',
        memberId: 'usr-001',
        memberName: 'Alex Johnson',
        memberEmail: 'alex.johnson@kivora.edu.ng',
        branchId: 'branch-west',
        signInTime: DateTime(now.year, now.month, now.day, 8, 14),
        verificationMethod: 'Biometric (Fingerprint)',
      ),
      AttendanceRecordModel(
        id: 'att-102',
        memberId: 'usr-002',
        memberName: 'Michael Brown',
        memberEmail: 'michael.brown@kivora.edu.ng',
        branchId: 'branch-west',
        signInTime: DateTime(now.year, now.month, now.day, 8, 22),
        verificationMethod: 'GPS Geofence',
      ),
      AttendanceRecordModel(
        id: 'att-103',
        memberId: 'usr-003',
        memberName: 'Emily Davis',
        memberEmail: 'emily.davis@kivora.edu.ng',
        branchId: 'branch-west',
        signInTime: DateTime(now.year, now.month, now.day, 8, 30),
        verificationMethod: 'Wi-Fi Network',
      ),
    ]);

    // Demo Pending Applications
    _applications.add(
      MembershipApplicationModel(
        id: 'app-001',
        userId: 'usr-david',
        userName: 'David Wilson',
        userEmail: 'david.wilson@kivora.edu.ng',
        branchId: 'branch-west',
        branchName: 'West Campus',
        inviteCode: 'WEST-2026',
        photoAttached: true,
        submittedData: {
          'photo': 'attached',
          'full_name': 'David Wilson',
          'email': 'david.wilson@kivora.edu.ng',
          'phone': '+234 809 111 2233',
          'student_id': 'STU00456',
          'nin_id': 'NIN-1092837465',
        },
        status: 'pending',
        submittedAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    );

    notifyListeners();
  }

  void resetToDefaults() {
    _branches.clear();
    _idFormConfigs.clear();
    _applications.clear();
    _attendanceRecords.clear();
    _members.clear();
    _branchDraft = null;
    _lastCreatedBranch = null;
    clearSession();
    if (AuthService().isDemoMode) {
      initializeDemoMode();
    } else {
      initializeLiveMode();
    }
  }

  // --- Session & State Restoration ---

  Future<void> restorePersistedState() async {
    _isAuthLoading = true;
    try {
      final draftJson = await StorageService().getBranchDraft();
      if (draftJson != null) {
        _branchDraft = BranchDraftModel.fromJson(draftJson);
      }

      final session = await StorageService().getSession();
      if (session['branchId'] != null && session['branchId']!.isNotEmpty) {
        _currentBranchId = session['branchId'];
      }
      if (session['email'] != null && session['email']!.isNotEmpty) {
        _currentUserEmail = session['email']!;
        _currentUserName = session['name'] ?? '';
        _currentRole = session['role'] ?? 'guest';
        _membershipStatus = session['membershipStatus'] ?? 'none';
        _isAuthenticated = true;
      }

      if (AuthService().isLiveMode && AuthService().checkSupabaseReady()) {
        await resolveLiveUserState();
      } else if (AuthService().isLiveMode && _currentBranchId != null) {
        try {
          await fetchBranch(_currentBranchId!);
        } catch (_) {}
      }
    } finally {
      _isAuthLoading = false;
      notifyListeners();
    }
  }

  /// Resolves the authenticated user's role, branch assignment, and membership status
  /// directly from live database tables (user_branch_assignments, branches, profiles, branch_membership_requests).
  /// Recognizes branch_manager, branch_admin, and web_admin as management roles.
  /// Never hardcodes emails, credentials, or test values.
  Future<void> resolveLiveUserState() async {
    if (!AuthService().isLiveMode || !AuthService().checkSupabaseReady()) return;

    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    final userId = user?.id ?? AuthService().currentSupabaseUser?.id;
    if (userId == null) {
      return;
    }

    _currentUserId = userId;
    _currentUserEmail = user?.email ?? AuthService().currentSupabaseUser?.email ?? _currentUserEmail;
    _isAuthenticated = true;
    _isEmailVerified = user?.emailConfirmedAt != null || (AuthService().currentSupabaseUser?.emailConfirmedAt != null);

    // 1. Fetch user profile for full name (non-blocking for role assignment)
    try {
      final profile = await client
          .from('profiles')
          .select('full_name, role')
          .eq('id', userId)
          .maybeSingle();
      if (profile != null) {
        _currentUserName = (profile['full_name'] as String?)?.trim() ?? '';
        if (_currentUserName.isEmpty) {
          _currentUserName = _currentUserEmail.split('@').first;
        }
        final profileRole = profile['role'] as String?;
        if (isManagementRole(profileRole)) {
          _currentRole = 'manager';
        }
      } else {
        _currentUserName = _currentUserEmail.split('@').first;
      }
    } catch (e) {
      debugPrint('[Kivora] Profile fetch notice: $e');
      if (_currentUserName.isEmpty) {
        _currentUserName = _currentUserEmail.split('@').first;
      }
    }

    // 2. Query active branch assignments using authenticated user ID
    // Explicitly recognizes branch_manager, branch_admin, web_admin as management roles
    final List<dynamic> assignmentRes;
    try {
      assignmentRes = await client
          .from('user_branch_assignments')
          .select('branch_id, role, is_active')
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('created_at', ascending: false);
    } catch (e) {
      debugPrint('[Kivora] Error querying user_branch_assignments: $e');
      _lastError = 'Failed to load branch assignments: $e';
      // DO NOT silently overwrite user role to unassigned member on query failure!
      rethrow;
    }

    if (assignmentRes.isNotEmpty) {
      // Find management assignment first (branch_manager, branch_admin, web_admin)
      final mgmt = assignmentRes.cast<Map<String, dynamic>?>().firstWhere(
            (a) => isManagementRole(a?['role'] as String?),
            orElse: () => null,
          );

      final selected = mgmt ?? (assignmentRes.first as Map<String, dynamic>);
      final assignedRole = selected['role'] as String? ?? 'member';
      final branchId = selected['branch_id'] as String;

      _currentBranchId = branchId;
      _membershipStatus = 'approved';

      if (isManagementRole(assignedRole)) {
        _currentRole = 'manager';
      } else {
        _currentRole = 'member';
      }

      try {
        await fetchBranch(branchId);
      } catch (e) {
        debugPrint('[Kivora] fetchBranch notice: $e');
        if (!_branches.any((b) => b.id == branchId)) {
          String activeCode = '';
          try {
            final icRes = await client
                .from('branch_invite_codes')
                .select('code')
                .eq('branch_id', branchId)
                .eq('is_revoked', false)
                .order('created_at', ascending: false)
                .limit(1)
                .maybeSingle();
            if (icRes != null && icRes['code'] != null) {
              activeCode = icRes['code'] as String;
            }
          } catch (_) {}

          _updateOrAddBranch(BranchModel(
            id: branchId,
            name: 'Techverve',
            organizationType: 'Organization',
            address: '',
            contactPhone: '',
            inviteCode: activeCode,
            managerId: userId,
          ));
        }
      }

      await _persistCurrentSession();
      notifyListeners();
      return;
    }

    // 3. Check if user is the creator of any branch
    try {
      final createdBranch = await client
          .from('branches')
          .select()
          .eq('created_by', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (createdBranch != null) {
        final branch = BranchModel.fromJson(createdBranch);
        _currentBranchId = branch.id;
        _currentRole = 'manager';
        _membershipStatus = 'approved';
        _updateOrAddBranch(branch);
        await _persistCurrentSession();
        notifyListeners();
        return;
      }
    } catch (e) {
      debugPrint('[Kivora] Created branch fetch notice: $e');
    }

    // 4. Check branch_membership_requests for pending or rejected status
    try {
      final req = await client
          .from('branch_membership_requests')
          .select('branch_id, status, requested_role')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (req != null) {
        final status = req['status'] as String? ?? 'none';
        _membershipStatus = status;
        _currentBranchId = req['branch_id'] as String?;

        if (status == 'approved') {
          final reqRole = req['requested_role'] as String? ?? 'member';
          _currentRole = isManagementRole(reqRole) ? 'manager' : 'member';
          if (_currentBranchId != null) {
            try {
              await fetchBranch(_currentBranchId!);
            } catch (_) {}
          }
        } else {
          _currentRole = 'guest';
        }

        await _persistCurrentSession();
        notifyListeners();
        return;
      }
    } catch (e) {
      debugPrint('[Kivora] Membership request fetch notice: $e');
    }

    // 5. True unassigned member (query succeeded, confirmed 0 assignments, no created branch, no requests)
    _currentRole = 'member';
    _currentBranchId = null;
    _membershipStatus = 'none';
    await _persistCurrentSession();
    notifyListeners();
  }

  Future<void> _persistCurrentSession() async {
    await StorageService().saveSession(
      branchId: _currentBranchId,
      email: _currentUserEmail,
      name: _currentUserName,
      role: _currentRole,
      membershipStatus: _membershipStatus,
    );
  }

  void setEmailVerified(bool verified) {
    _isEmailVerified = verified;
    notifyListeners();
  }

  void setMembershipStatus(String status) {
    _membershipStatus = status;
    StorageService().saveSession(
      membershipStatus: status,
    );
    notifyListeners();
  }

  void setCurrentUser({
    required String email,
    required String name,
    required String role,
    String? branchId,
    bool isEmailVerified = true,
  }) {
    _isAuthenticated = true;
    _isEmailVerified = isEmailVerified;
    _currentUserEmail = email;
    _currentUserId = email.isNotEmpty ? email : 'usr-current';
    _currentUserName = name;
    _currentRole = role;
    _currentBranchId = branchId;
    _isAuthLoading = false;
    _currentApplication = _applications.cast<MembershipApplicationModel?>().firstWhere(
      (app) => app?.userEmail.toLowerCase() == email.toLowerCase(),
      orElse: () => null,
    );

    if (_currentApplication != null) {
      _membershipStatus = _currentApplication!.status;
    } else if (isManagementRole(role)) {
      _membershipStatus = 'approved';
    } else if (role == 'member') {
      _membershipStatus = branchId != null ? 'approved' : 'none';
    } else {
      _membershipStatus = 'none';
    }

    StorageService().saveSession(
      email: email,
      name: name,
      role: role,
      branchId: branchId,
      membershipStatus: _membershipStatus,
    );

    notifyListeners();
  }

  void clearSession() {
    _isAuthenticated = false;
    _currentUserEmail = '';
    _currentUserName = '';
    _currentRole = 'guest';
    _currentBranchId = null;
    _currentApplication = null;
    _isEmailVerified = false;
    _membershipStatus = 'none';
    StorageService().clearSession();
    notifyListeners();
  }

  // --- Branch Wizard Draft Management ---

  void updateBranchDraftDetails({
    required String name,
    required String organizationType,
    required String address,
    String? contactPhone,
    String? description,
  }) {
    _branchDraft ??= BranchDraftModel(
      draftId: 'draft-${DateTime.now().millisecondsSinceEpoch}',
    );
    _branchDraft!.name = name;
    _branchDraft!.organizationType = organizationType;
    _branchDraft!.address = address;
    _branchDraft!.contactPhone = contactPhone ?? '';
    _branchDraft!.description = description ?? '';

    StorageService().saveBranchDraft(_branchDraft!.toJson());
  }

  void updateBranchDraftAdmin({
    required String adminName,
    required String adminEmail,
    String? adminPhone,
    String? adminRole,
  }) {
    _branchDraft ??= BranchDraftModel(
      draftId: 'draft-${DateTime.now().millisecondsSinceEpoch}',
    );
    _branchDraft!.adminName = adminName;
    _branchDraft!.adminEmail = adminEmail;
    _branchDraft!.adminPhone = adminPhone ?? '';
    _branchDraft!.adminRole = adminRole ?? 'Branch Manager';

    StorageService().saveBranchDraft(_branchDraft!.toJson());
  }

  void clearBranchDraft() {
    _branchDraft = null;
    StorageService().clearBranchDraft();
    notifyListeners();
  }

  // --- Branch Validation & In-Memory Helpers ---

  BranchModel? get currentBranch => _currentBranchId != null ? getBranchById(_currentBranchId!) : null;

  BranchModel? validateInviteCodeSync(String code) {
    final clean = code.trim().toUpperCase();
    if (clean.isEmpty) return null;

    // Check in-memory invite codes first
    final icMatch = _inviteCodes.cast<BranchInviteCodeModel?>().firstWhere(
      (ic) => ic != null && ic.code.trim().toUpperCase() == clean,
      orElse: () => null,
    );
    if (icMatch != null) {
      if (!icMatch.isActive) return null;
      return getBranchById(icMatch.branchId);
    }

    // Fallback: check in-memory branches
    return _branches.cast<BranchModel?>().firstWhere(
      (b) => b?.isActive == true && b?.inviteCode.toUpperCase() == clean,
      orElse: () => null,
    );
  }

  /// Comprehensive invite-code validation with precise diagnostic status.
  Future<InviteValidationResult> validateInviteCodeDetailed(
    String code, {
    String? targetBranchId,
  }) async {
    final clean = code.trim().toUpperCase();
    if (clean.isEmpty || clean.length < 4) {
      return InviteValidationResult(
        isValid: false,
        code: clean,
        status: InviteCodeStatus.invalid,
        errorMessage: 'Please enter an invitation code (at least 4 characters).',
      );
    }

    // 1. In LIVE mode with Supabase connected: query server-side RPC validator
    if (AuthService().isLiveMode && AuthService().checkSupabaseReady()) {
      try {
        final client = Supabase.instance.client;

        try {
          final dynamic rpcRes = await client.rpc(
            'validate_branch_invite_code',
            params: {'invite_code': clean},
          );

          if (rpcRes != null && rpcRes is List && rpcRes.isNotEmpty) {
            final row = rpcRes.first as Map<String, dynamic>;
            final bId = row['branch_id'] as String?;
            final bName = row['branch_name'] as String? ?? 'Techverve';
            final icId = row['invite_code_id'] as String?;
            final isValid = row['is_valid'] as bool? ?? false;
            final statusStr = row['status'] as String? ?? (isValid ? 'valid' : 'invalid');

            // Verify requested branch ID if specified
            if (targetBranchId != null && bId != null && bId != targetBranchId) {
              return InviteValidationResult(
                isValid: false,
                code: clean,
                inviteCodeId: icId,
                status: InviteCodeStatus.wrongBranch,
                errorMessage: 'This invitation code belongs to a different branch.',
              );
            }

            if (isValid && bId != null) {
              final branch = BranchModel(
                id: bId,
                name: bName,
                organizationType: 'Organization',
                address: 'Branch Campus',
                contactPhone: '',
                contactEmail: '',
                inviteCode: clean,
                isActive: true,
              );
              _updateOrAddBranch(branch);
              _currentBranchId = bId;
              notifyListeners();

              return InviteValidationResult(
                isValid: true,
                branch: branch,
                inviteCodeId: icId,
                code: clean,
                status: InviteCodeStatus.valid,
              );
            } else {
              InviteCodeStatus codeStatus = InviteCodeStatus.invalid;
              String msg = 'Invalid, inactive, or expired invitation code. Please check with your branch manager.';
              if (statusStr == 'expired') {
                codeStatus = InviteCodeStatus.expired;
                msg = 'This invitation code has expired. Please request a new code from your branch manager.';
              } else if (statusStr == 'revoked') {
                codeStatus = InviteCodeStatus.revoked;
                msg = 'This invitation code has been revoked by the branch manager.';
              } else if (statusStr == 'exhausted') {
                codeStatus = InviteCodeStatus.exhausted;
                msg = 'This invitation code has reached its maximum number of uses.';
              } else if (statusStr == 'invalid_role') {
                codeStatus = InviteCodeStatus.disallowedRole;
                msg = 'This invitation code does not grant member access.';
              }
              return InviteValidationResult(
                isValid: false,
                inviteCodeId: icId,
                code: clean,
                status: codeStatus,
                errorMessage: msg,
              );
            }
          } else {
            return InviteValidationResult(
              isValid: false,
              code: clean,
              status: InviteCodeStatus.invalid,
              errorMessage: 'Invalid invitation code. Please check with your branch manager.',
            );
          }
        } catch (rpcErr) {
          debugPrint('validate_branch_invite_code RPC error: $rpcErr');
        }
      } catch (e) {
        debugPrint('Supabase connection error during invite validation: $e');
        return InviteValidationResult(
          isValid: false,
          code: clean,
          status: InviteCodeStatus.connectionError,
          errorMessage: 'Network or database connection failure. Please try again.',
        );
      }
    }

    // 2. Demo / Memory / In-Memory Mode
    final icMatch = _inviteCodes.cast<BranchInviteCodeModel?>().firstWhere(
      (ic) => ic != null && ic.code.trim().toUpperCase() == clean,
      orElse: () => null,
    );

    if (icMatch == null) {
      // Fallback check in demo branches
      final bMatch = _branches.cast<BranchModel?>().firstWhere(
        (b) => b?.inviteCode.trim().toUpperCase() == clean,
        orElse: () => null,
      );
      if (bMatch != null && bMatch.isActive) {
        return InviteValidationResult(
          isValid: true,
          branch: bMatch,
          inviteCodeId: 'd1f7351c-e218-4000-8437-6f12a17b6550',
          code: clean,
          status: InviteCodeStatus.valid,
        );
      }
      return InviteValidationResult(
        isValid: false,
        code: clean,
        status: InviteCodeStatus.invalid,
        errorMessage: 'Invalid, inactive, or expired invitation code. Please check with your branch manager.',
      );
    }

    // Check specific conditions on the matching invite code
    if (targetBranchId != null && icMatch.branchId != targetBranchId) {
      return InviteValidationResult(
        isValid: false,
        code: clean,
        inviteCodeId: icMatch.id,
        status: InviteCodeStatus.wrongBranch,
        errorMessage: 'This invitation code belongs to a different branch.',
      );
    }

    if (icMatch.isRevoked) {
      return InviteValidationResult(
        isValid: false,
        code: clean,
        inviteCodeId: icMatch.id,
        status: InviteCodeStatus.revoked,
        errorMessage: 'This invitation code has been revoked by the branch manager.',
      );
    }

    if (icMatch.isExpired) {
      return InviteValidationResult(
        isValid: false,
        code: clean,
        inviteCodeId: icMatch.id,
        status: InviteCodeStatus.expired,
        errorMessage: 'This invitation code has expired. Please request a new code from your branch manager.',
      );
    }

    if (icMatch.isExhausted) {
      return InviteValidationResult(
        isValid: false,
        code: clean,
        inviteCodeId: icMatch.id,
        status: InviteCodeStatus.exhausted,
        errorMessage: 'This invitation code has reached its maximum number of uses.',
      );
    }

    if (!icMatch.allowedRoles.contains('member')) {
      return InviteValidationResult(
        isValid: false,
        code: clean,
        inviteCodeId: icMatch.id,
        status: InviteCodeStatus.disallowedRole,
        errorMessage: 'This invitation code does not grant member access.',
      );
    }

    final branch = getBranchById(icMatch.branchId);
    if (branch != null) {
      _currentBranchId = branch.id;
      notifyListeners();
    }

    return InviteValidationResult(
      isValid: true,
      branch: branch,
      inviteCodeId: icMatch.id,
      code: clean,
      status: InviteCodeStatus.valid,
    );
  }

  /// Validates invite code and returns matching BranchModel if valid.
  Future<BranchModel?> validateInviteCode(String code) async {
    final result = await validateInviteCodeDetailed(code);
    return result.isValid ? result.branch : null;
  }

  // --- Branch Manager Invite Code Management Methods ---

  /// Fetches all invite codes for a branch.
  Future<List<BranchInviteCodeModel>> fetchInviteCodesForBranch(String branchId) async {
    if (AuthService().isLiveMode && AuthService().checkSupabaseReady()) {
      try {
        final client = Supabase.instance.client;
        final res = await client
            .from('branch_invite_codes')
            .select()
            .eq('branch_id', branchId)
            .order('created_at', ascending: false);

        final list = (res as List)
            .map((row) => BranchInviteCodeModel.fromJson(row as Map<String, dynamic>))
            .toList();
        _inviteCodes.removeWhere((ic) => ic.branchId == branchId);
        _inviteCodes.addAll(list);
        notifyListeners();
        return list;
      } catch (e) {
        debugPrint('[Kivora] fetchInviteCodesForBranch error: $e');
      }
    }
    return _inviteCodes.where((ic) => ic.branchId == branchId).toList();
  }

  /// Gets the current active invite code for a branch.
  Future<BranchInviteCodeModel?> getActiveInviteCodeForBranch(String branchId) async {
    final list = await fetchInviteCodesForBranch(branchId);
    return list.cast<BranchInviteCodeModel?>().firstWhere(
      (ic) => ic != null && ic.isActive,
      orElse: () => list.isNotEmpty ? list.first : null,
    );
  }

  /// Generates a cryptographically random, human-friendly invitation code.
  static String generateSecureRandomCode({String prefix = 'TV'}) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random.secure();
    final buffer = StringBuffer();
    for (int i = 0; i < 4; i++) {
      buffer.write(chars[rand.nextInt(chars.length)]);
    }
    final numSuffix = (1000 + rand.nextInt(9000)).toString();
    return '$prefix-$numSuffix-${buffer.toString()}';
  }

  /// Creates a new invite code for a branch.
  /// If [revokeExisting] is true, marks prior active codes for this branch as revoked.
  Future<BranchInviteCodeModel> createInviteCode({
    required String branchId,
    required String code,
    int? maxUses = 50,
    DateTime? expiresAt,
    List<String> allowedRoles = const ['member'],
    bool revokeExisting = true,
  }) async {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.length < 4) {
      throw ArgumentError('Invite code must be at least 4 characters.');
    }

    final newId = 'ic-${DateTime.now().millisecondsSinceEpoch}';
    final DateTime? expiry = expiresAt;

    final model = BranchInviteCodeModel(
      id: newId,
      branchId: branchId,
      code: cleanCode,
      createdBy: _currentUserId,
      allowedRoles: allowedRoles,
      maxUses: maxUses,
      usedCount: 0,
      expiresAt: expiry,
      isRevoked: false,
      createdAt: DateTime.now(),
    );

    if (AuthService().isLiveMode && AuthService().checkSupabaseReady()) {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id ?? _currentUserId;

      if (revokeExisting) {
        try {
          await client
              .from('branch_invite_codes')
              .update({'is_revoked': true})
              .eq('branch_id', branchId)
              .eq('is_revoked', false);
        } catch (e) {
          debugPrint('Revoke existing codes note: $e');
        }
      }

      final insertRes = await client.from('branch_invite_codes').insert({
        'branch_id': branchId,
        'code': cleanCode,
        'created_by': userId,
        'allowed_roles': allowedRoles,
        if (maxUses != null) 'max_uses': maxUses,
        if (expiry != null) 'expires_at': expiry.toIso8601String(),
        'used_count': 0,
        'is_revoked': false,
      }).select().single();

      final created = BranchInviteCodeModel.fromJson(insertRes);

      try {
        await client.from('branches').update({'branch_code': cleanCode}).eq('id', branchId);
      } catch (_) {}

      if (revokeExisting) {
        for (int i = 0; i < _inviteCodes.length; i++) {
          if (_inviteCodes[i].branchId == branchId) {
            _inviteCodes[i] = _inviteCodes[i].copyWith(isRevoked: true);
          }
        }
      }
      _inviteCodes.insert(0, created);
      _updateBranchInviteCode(branchId, cleanCode);
      notifyListeners();
      return created;
    }

    // Demo Mode
    if (revokeExisting) {
      for (int i = 0; i < _inviteCodes.length; i++) {
        if (_inviteCodes[i].branchId == branchId) {
          _inviteCodes[i] = _inviteCodes[i].copyWith(isRevoked: true);
        }
      }
    }
    _inviteCodes.insert(0, model);
    _updateBranchInviteCode(branchId, cleanCode);
    notifyListeners();
    return model;
  }

  /// Updates an existing invite code's settings (custom code text, revocation, max uses, expiry).
  Future<BranchInviteCodeModel> updateInviteCode({
    required String inviteCodeId,
    required String branchId,
    String? newCode,
    bool? isRevoked,
    int? maxUses,
    bool clearMaxUses = false,
    DateTime? expiresAt,
    bool clearExpiresAt = false,
  }) async {
    final cleanCode = newCode?.trim().toUpperCase();

    if (AuthService().isLiveMode && AuthService().checkSupabaseReady()) {
      final client = Supabase.instance.client;
      final updates = <String, dynamic>{};
      if (cleanCode != null) updates['code'] = cleanCode;
      if (isRevoked != null) updates['is_revoked'] = isRevoked;
      if (clearMaxUses) {
        updates['max_uses'] = null;
      } else if (maxUses != null) {
        updates['max_uses'] = maxUses;
      }
      if (clearExpiresAt) {
        updates['expires_at'] = null;
      } else if (expiresAt != null) {
        updates['expires_at'] = expiresAt.toIso8601String();
      }

      final res = await client
          .from('branch_invite_codes')
          .update(updates)
          .eq('id', inviteCodeId)
          .select()
          .single();

      final updated = BranchInviteCodeModel.fromJson(res);
      final idx = _inviteCodes.indexWhere((ic) => ic.id == inviteCodeId);
      if (idx != -1) {
        _inviteCodes[idx] = updated;
      }
      if (cleanCode != null && !updated.isRevoked) {
        _updateBranchInviteCode(branchId, cleanCode);
      }
      notifyListeners();
      return updated;
    }

    // Demo / In-Memory Mode
    final idx = _inviteCodes.indexWhere((ic) => ic.id == inviteCodeId);
    if (idx != -1) {
      final existing = _inviteCodes[idx];
      final updated = existing.copyWith(
        code: cleanCode ?? existing.code,
        isRevoked: isRevoked ?? existing.isRevoked,
        maxUses: maxUses,
        clearMaxUses: clearMaxUses,
        expiresAt: expiresAt,
        clearExpiresAt: clearExpiresAt,
      );
      _inviteCodes[idx] = updated;
      if (cleanCode != null && !updated.isRevoked) {
        _updateBranchInviteCode(branchId, cleanCode);
      }
      notifyListeners();
      return updated;
    }
    throw StateError('Invite code not found.');
  }

  /// Revokes an invite code, making it immediately rejected for all future applicants.
  Future<void> revokeInviteCode({
    required String inviteCodeId,
    required String branchId,
  }) async {
    await updateInviteCode(
      inviteCodeId: inviteCodeId,
      branchId: branchId,
      isRevoked: true,
    );
  }

  /// Reactivates a previously revoked invite code.
  Future<void> reactivateInviteCode({
    required String inviteCodeId,
    required String branchId,
  }) async {
    await updateInviteCode(
      inviteCodeId: inviteCodeId,
      branchId: branchId,
      isRevoked: false,
    );
  }

  void _updateBranchInviteCode(String branchId, String newCode) {
    final branch = getBranchById(branchId);
    if (branch != null) {
      final updated = BranchModel(
        id: branch.id,
        name: branch.name,
        organizationType: branch.organizationType,
        address: branch.address,
        contactPhone: branch.contactPhone,
        contactEmail: branch.contactEmail,
        description: branch.description,
        inviteCode: newCode,
        isActive: branch.isActive,
        managerId: branch.managerId,
      );
      _updateOrAddBranch(updated);
    }
  }

  BranchModel? getBranchById(String id) {
    return _branches.cast<BranchModel?>().firstWhere(
      (b) => b?.id == id,
      orElse: () => null,
    );
  }

  void _updateOrAddBranch(BranchModel branch) {
    final idx = _branches.indexWhere((b) => b.id == branch.id);
    if (idx != -1) {
      _branches[idx] = branch;
    } else {
      _branches.add(branch);
    }
  }

  BranchModel addBranch({
    required String name,
    required String organizationType,
    required String address,
    required String contactPhone,
    String contactEmail = '',
    String description = '',
  }) {
    final newId = 'branch-${DateTime.now().millisecondsSinceEpoch}';
    final codePrefix = name.trim().split(RegExp(r'\s+')).first.toUpperCase();
    final newCode = '$codePrefix-2026';

    final branch = BranchModel(
      id: newId,
      name: name,
      organizationType: organizationType,
      address: address,
      contactPhone: contactPhone,
      contactEmail: contactEmail,
      description: description,
      inviteCode: newCode,
      isActive: true,
      managerId: _currentUserEmail.isNotEmpty ? _currentUserEmail : _currentUserId,
    );
    _branches.add(branch);
    _currentBranchId = newId;

    _idFormConfigs[newId] = [
      IdFormFieldModel(id: 'photo', label: 'Photo Upload', type: FieldType.photo, isRequired: true, isEnabled: true, order: 0),
      IdFormFieldModel(id: 'full_name', label: 'Full Name', type: FieldType.text, isRequired: true, isEnabled: true, order: 1),
      IdFormFieldModel(id: 'email', label: 'Email Address', type: FieldType.email, isRequired: true, isEnabled: true, order: 2),
      IdFormFieldModel(id: 'phone', label: 'Phone Number', type: FieldType.phone, isRequired: true, isEnabled: true, order: 3),
      IdFormFieldModel(id: 'identifier', label: 'Identifier / ID Number', type: FieldType.text, isRequired: true, isEnabled: true, order: 4),
    ];

    notifyListeners();
    return branch;
  }

  // --- Real Branch Creation (Live Mode vs Demo Mode) ---

  /// Persists a new branch to Supabase in LIVE mode with real IDs and assignments.
  /// Throws clear errors on connection or schema failure. Never returns silent mock data in LIVE mode.
  Future<BranchModel> createBranch({
    required String name,
    required String organizationType,
    required String address,
    required String contactPhone,
    required String contactEmail,
    String description = '',
  }) async {
    // 1. LIVE MODE
    if (AuthService().isLiveMode) {
      if (!AuthService().checkSupabaseReady()) {
        throw StateError(
          'Live database is not connected or credentials are not configured. '
          'Please ensure SUPABASE_URL and SUPABASE_ANON_KEY (or SUPABASE_PUBLISHABLE_KEY) are set, or switch to Demo Mode.',
        );
      }

      final client = Supabase.instance.client;
      final currentUser = client.auth.currentUser;
      final userId = currentUser?.id;

      if (userId == null) {
        throw StateError(
          'Authentication required: An active Supabase user session is required to create a branch in LIVE mode.',
        );
      }

      // Deduplication check: if this exact branch was just created in this wizard session, return it
      if (_lastCreatedBranch != null &&
          _lastCreatedBranch!.name.trim().toLowerCase() == name.trim().toLowerCase() &&
          _lastCreatedBranch!.address.trim().toLowerCase() == address.trim().toLowerCase()) {
        return _lastCreatedBranch!;
      }

      try {
        final branchId = generateUuidV4();
        final orgId = generateUuidV4();

        final codePrefix = name.trim().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
        final safePrefix = codePrefix.isEmpty ? 'KIV' : (codePrefix.length > 5 ? codePrefix.substring(0, 5) : codePrefix);
        final uniqueSuffix = (Random().nextInt(9000) + 1000).toString();
        final inviteCode = '$safePrefix-$uniqueSuffix';

        // Step A: Insert organization
        await client.from('organizations').insert({
          'id': orgId,
          'name': '$name Organization',
          'organization_type': organizationType.toLowerCase(),
        });

        // Step B: Insert branch record
        await client.from('branches').insert({
          'id': branchId,
          'organization_id': orgId,
          'name': name,
          'branch_code': inviteCode,
          'description': description,
          'address': address,
          'contact_phone': contactPhone,
          'contact_email': contactEmail,
          'created_by': userId,
        });

        // Step C: Assign current user as initial branch manager
        await client.from('user_branch_assignments').insert({
          'user_id': userId,
          'branch_id': branchId,
          'role': 'branch_manager',
          'is_active': true,
        });

        // Step D: Create invite code entry
        try {
          await client.from('branch_invite_codes').insert({
            'branch_id': branchId,
            'code': inviteCode,
            'created_by': userId,
            'expires_at': DateTime.now().add(const Duration(days: 365)).toIso8601String(),
          });
        } catch (e) {
          debugPrint('branch_invite_codes insertion note: $e');
        }

        // Step E: Create default branch_id_form_configs entry
        try {
          await client.from('branch_id_form_configs').insert({
            'branch_id': branchId,
            'fields': [
              {'id': 'photo', 'label': 'Identity Photo', 'type': 'photo', 'isRequired': true, 'isEnabled': true, 'order': 0},
              {'id': 'full_name', 'label': 'Full Name', 'type': 'text', 'isRequired': true, 'isEnabled': true, 'order': 1},
              {'id': 'email', 'label': 'Email Address', 'type': 'email', 'isRequired': true, 'isEnabled': true, 'order': 2},
              {'id': 'phone', 'label': 'Phone Number', 'type': 'phone', 'isRequired': true, 'isEnabled': true, 'order': 3},
              {'id': 'student_id', 'label': 'Student / Employee ID', 'type': 'text', 'isRequired': true, 'isEnabled': true, 'order': 4},
            ],
          });
        } catch (e) {
          debugPrint('branch_id_form_configs insertion note: $e');
        }

        final created = BranchModel(
          id: branchId,
          name: name,
          organizationType: organizationType,
          address: address,
          contactPhone: contactPhone,
          contactEmail: contactEmail,
          description: description,
          inviteCode: inviteCode,
          isActive: true,
          managerId: currentUser?.email ?? userId,
        );

        _updateOrAddBranch(created);
        _currentBranchId = branchId;
        _lastCreatedBranch = created;

        await StorageService().saveSession(branchId: branchId);
        await StorageService().clearBranchDraft();
        _branchDraft = null;

        notifyListeners();
        return created;
      } catch (e) {
        debugPrint('Supabase branch creation error in LIVE mode: $e');
        rethrow;
      }
    }

    // 2. DEMO MODE
    // Deduplication check
    if (_lastCreatedBranch != null &&
        _lastCreatedBranch!.name.trim().toLowerCase() == name.trim().toLowerCase() &&
        _lastCreatedBranch!.address.trim().toLowerCase() == address.trim().toLowerCase()) {
      return _lastCreatedBranch!;
    }

    final newId = 'demo-branch-${DateTime.now().millisecondsSinceEpoch}';
    final codePrefix = name.trim().split(RegExp(r'\s+')).first.toUpperCase();
    final newCode = '$codePrefix-DEMO';

    final branch = BranchModel(
      id: newId,
      name: name,
      organizationType: organizationType,
      address: address,
      contactPhone: contactPhone,
      contactEmail: contactEmail,
      description: description,
      inviteCode: newCode,
      isActive: true,
      managerId: _currentUserEmail.isNotEmpty ? _currentUserEmail : _currentUserId,
    );

    _updateOrAddBranch(branch);
    _currentBranchId = newId;
    _lastCreatedBranch = branch;

    await StorageService().saveSession(branchId: newId);
    await StorageService().clearBranchDraft();
    _branchDraft = null;

    notifyListeners();
    return branch;
  }

  /// Fetches branch details by branch ID.
  /// In LIVE mode: queries Supabase directly and throws on connection error. Never returns mock data.
  /// In DEMO mode: returns from local demo branches.
  Future<BranchModel?> fetchBranch(String branchId) async {
    if (AuthService().isLiveMode) {
      if (!AuthService().checkSupabaseReady()) {
        throw StateError(
          'Live database is not configured or connected. Cannot fetch branch details.',
        );
      }

      try {
        final client = Supabase.instance.client;
        final res = await client
            .from('branches')
            .select()
            .eq('id', branchId)
            .maybeSingle();

        if (res != null) {
          final branch = BranchModel.fromJson(res);
          _updateOrAddBranch(branch);
          _currentBranchId = branch.id;
          notifyListeners();
          return branch;
        }
      } catch (e) {
        debugPrint('Supabase fetchBranch error: $e');
        rethrow;
      }
      return null;
    }

    return getBranchById(branchId);
  }

  /// Fetches the branch associated with the current authorized manager or member.
  /// In LIVE mode: checks active assignment in `user_branch_assignments` or created branches in `branches`.
  /// Never selects an arbitrary or first branch, and never silently substitutes sample data.
  Future<BranchModel?> fetchCurrentBranch() async {
    if (AuthService().isLiveMode) {
      if (!AuthService().checkSupabaseReady()) {
        throw StateError(
          'Live database is not configured or connected. Cannot fetch current branch.',
        );
      }

      try {
        final client = Supabase.instance.client;
        final userId = client.auth.currentUser?.id;

        if (userId != null) {
          // 1. Check verified branch assignment
          final assignments = await client
              .from('user_branch_assignments')
              .select('branch_id, role, is_active')
              .eq('user_id', userId)
              .eq('is_active', true)
              .order('created_at', ascending: false);

          if (assignments.isNotEmpty) {
            final mgmt = assignments.cast<Map<String, dynamic>?>().firstWhere(
                  (a) => isManagementRole(a?['role'] as String?),
                  orElse: () => null,
                );
            final sel = mgmt ?? assignments.first;
            if (sel['branch_id'] != null) {
              return await fetchBranch(sel['branch_id'] as String);
            }
          }

          // 2. Check branch created by current user
          final created = await client
              .from('branches')
              .select()
              .eq('created_by', userId)
              .order('created_at', ascending: false)
              .limit(1)
              .maybeSingle();

          if (created != null) {
            final branch = BranchModel.fromJson(created);
            _currentBranchId = branch.id;
            _updateOrAddBranch(branch);
            notifyListeners();
            return branch;
          }
        }
      } catch (e) {
        debugPrint('Supabase fetchCurrentBranch error: $e');
        rethrow;
      }
      return null;
    }

    // DEMO Mode
    if (_currentBranchId != null) {
      return getBranchById(_currentBranchId!);
    }
    return null;
  }

  // --- Identification Form Configuration Controls for Manager ---

  List<IdFormFieldModel> getIdFormConfig(String branchId) {
    final list = _idFormConfigs[branchId];
    if (list != null) {
      final sorted = List<IdFormFieldModel>.from(list);
      sorted.sort((a, b) => a.order.compareTo(b.order));
      return sorted;
    }
    // Default form configuration
    return [
      IdFormFieldModel(id: 'photo', label: 'Photo Upload', type: FieldType.photo, isRequired: true, isEnabled: true, order: 0),
      IdFormFieldModel(id: 'full_name', label: 'Full Name', type: FieldType.text, isRequired: true, isEnabled: true, order: 1),
      IdFormFieldModel(id: 'email', label: 'Email Address', type: FieldType.email, isRequired: true, isEnabled: true, order: 2),
      IdFormFieldModel(id: 'phone', label: 'Phone Number', type: FieldType.phone, isRequired: true, isEnabled: true, order: 3),
      IdFormFieldModel(id: 'student_id', label: 'Student / Employee ID', type: FieldType.text, isRequired: true, isEnabled: true, order: 4),
    ];
  }

  void saveIdFormConfig(String branchId, List<IdFormFieldModel> newFields) {
    _idFormConfigs[branchId] = List.from(newFields);
    notifyListeners();
  }

  void updateField(String branchId, IdFormFieldModel updatedField) {
    final list = _idFormConfigs[branchId] ?? getIdFormConfig(branchId);
    final idx = list.indexWhere((f) => f.id == updatedField.id);
    if (idx != -1) {
      list[idx] = updatedField;
      _idFormConfigs[branchId] = list;
      notifyListeners();
    }
  }

  void addCustomField(String branchId, {
    required String label,
    required FieldType type,
    bool isRequired = false,
  }) {
    final list = _idFormConfigs[branchId] ?? getIdFormConfig(branchId);
    final fieldId = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    list.add(
      IdFormFieldModel(
        id: fieldId,
        label: label,
        type: type,
        isRequired: isRequired,
        isEnabled: true,
        order: list.length,
      ),
    );
    _idFormConfigs[branchId] = list;
    notifyListeners();
  }

  void removeField(String branchId, String fieldId) {
    final list = _idFormConfigs[branchId] ?? getIdFormConfig(branchId);
    list.removeWhere((f) => f.id == fieldId);
    _idFormConfigs[branchId] = list;
    notifyListeners();
  }

  void reorderFields(String branchId, int oldIndex, int newIndex) {
    final list = _idFormConfigs[branchId] ?? getIdFormConfig(branchId);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    for (int i = 0; i < list.length; i++) {
      list[i].order = i;
    }
    _idFormConfigs[branchId] = list;
    notifyListeners();
  }

  // --- Membership Applications ---

  MembershipApplicationModel submitApplication({
    required String branchId,
    required String inviteCode,
    String? inviteCodeId,
    required String userName,
    required String userEmail,
    required Map<String, dynamic> submittedData,
    bool photoAttached = false,
    String? photoUrl,
  }) {
    final branch = getBranchById(branchId);
    final branchName = branch?.name ?? 'Branch';
    final assignedAppId = 'app-${DateTime.now().millisecondsSinceEpoch}';

    final app = MembershipApplicationModel(
      id: assignedAppId,
      userId: _currentUserId,
      userName: userName,
      userEmail: userEmail,
      branchId: branchId,
      branchName: branchName,
      inviteCode: inviteCode,
      inviteCodeId: inviteCodeId,
      submittedData: Map.from(submittedData),
      photoAttached: photoAttached,
      photoUrl: photoUrl,
      status: 'pending',
      submittedAt: DateTime.now(),
    );

    _applications.removeWhere((a) => a.userEmail.toLowerCase() == userEmail.toLowerCase() && a.branchId == branchId);
    _applications.add(app);
    _currentApplication = app;
    _currentBranchId = branchId;
    _membershipStatus = 'pending';

    // Increment usedCount in in-memory invite code (mirrors Supabase trigger in demo mode)
    final cleanCode = inviteCode.trim().toUpperCase();
    final icIndex = _inviteCodes.indexWhere((c) =>
        (inviteCodeId != null && c.id == inviteCodeId) ||
        (c.branchId == branchId && c.code.toUpperCase() == cleanCode));
    if (icIndex != -1) {
      final oldCode = _inviteCodes[icIndex];
      _inviteCodes[icIndex] = oldCode.copyWith(usedCount: oldCode.usedCount + 1);
    }

    notifyListeners();

    // In LIVE MODE: Asynchronously persist to Supabase in background
    if (AuthService().isLiveMode && AuthService().checkSupabaseReady()) {
      _persistMembershipRequestToSupabase(
        branchId: branchId,
        inviteCode: inviteCode,
        inviteCodeId: inviteCodeId,
        photoUrl: photoUrl,
        submittedData: submittedData,
      );
    }

    return app;
  }

  Future<void> _persistMembershipRequestToSupabase({
    required String branchId,
    required String inviteCode,
    String? inviteCodeId,
    String? photoUrl,
    Map<String, dynamic>? submittedData,
  }) async {
    try {
      final client = Supabase.instance.client;
      final currentUserId = client.auth.currentUser?.id ?? _currentUserId;

      // If inviteCodeId is not supplied, resolve via validateInviteCodeDetailed RPC
      String? resolvedInviteId = inviteCodeId;
      if (resolvedInviteId == null || resolvedInviteId.isEmpty) {
        final valRes = await validateInviteCodeDetailed(inviteCode, targetBranchId: branchId);
        resolvedInviteId = valRes.inviteCodeId;
      }

      final insertPayload = <String, dynamic>{
        'branch_id': branchId,
        'user_id': currentUserId,
        'requested_role': 'member',
        'status': 'pending',
        if (resolvedInviteId != null) 'invite_code_id': resolvedInviteId,
        if (photoUrl != null && photoUrl.isNotEmpty) 'photo_url': photoUrl,
        if (submittedData != null && submittedData.isNotEmpty) 'submitted_data': submittedData,
      };

      await client.from('branch_membership_requests').insert(insertPayload);
      debugPrint('[Kivora] Live membership request persisted to Supabase.');

      // If photoUrl is available, update profile avatar_url
      if (photoUrl != null && photoUrl.isNotEmpty) {
        try {
          await client.from('profiles').update({'avatar_url': photoUrl}).eq('id', currentUserId);
        } catch (e) {
          debugPrint('Profile avatar update note: $e');
        }
      }
    } catch (e) {
      debugPrint('Supabase _persistMembershipRequestToSupabase error: $e');
    }
  }

  Future<List<MembershipApplicationModel>> fetchApplicationsForBranch(String branchId) async {
    if (AuthService().isLiveMode && AuthService().checkSupabaseReady()) {
      try {
        final client = Supabase.instance.client;
        final res = await client
            .from('branch_membership_requests')
            .select('id, branch_id, user_id, invite_code_id, requested_role, status, photo_url, submitted_data, created_at, profiles(full_name, email, avatar_url), branches(name, branch_code), branch_invite_codes(code)')
            .eq('branch_id', branchId)
            .order('created_at', ascending: false);

        _applications.removeWhere((a) => a.branchId == branchId);
        for (final row in res) {
          final profile = row['profiles'] as Map<String, dynamic>?;
          final branchData = row['branches'] as Map<String, dynamic>?;
          final inviteData = row['branch_invite_codes'] as Map<String, dynamic>?;
          final avatarUrl = profile?['avatar_url'] as String?;
          final directPhoto = row['photo_url'] as String?;
          final photo = (directPhoto != null && directPhoto.isNotEmpty) ? directPhoto : avatarUrl;
          final code = inviteData?['code'] as String? ?? branchData?['branch_code'] as String? ?? '';
          final app = MembershipApplicationModel(
            id: row['id'] as String,
            userId: row['user_id'] as String,
            userName: profile?['full_name'] as String? ?? 'Prospective Member',
            userEmail: profile?['email'] as String? ?? '',
            branchId: row['branch_id'] as String,
            branchName: branchData?['name'] as String? ?? 'Techverve',
            inviteCode: code,
            inviteCodeId: row['invite_code_id'] as String?,
            submittedData: (row['submitted_data'] is Map) ? Map<String, dynamic>.from(row['submitted_data'] as Map) : {},
            photoAttached: photo != null && photo.isNotEmpty,
            photoUrl: photo,
            status: row['status'] as String? ?? 'pending',
            submittedAt: DateTime.tryParse(row['created_at']?.toString() ?? '') ?? DateTime.now(),
          );
          _applications.add(app);
        }
        notifyListeners();
      } catch (e) {
        debugPrint('Supabase fetchApplicationsForBranch error: $e');
      }
    }
    return getApplicationsForBranch(branchId);
  }

  /// Fetches real members belonging to the branch in LIVE mode
  Future<List<MemberProfileModel>> fetchBranchMembers(String branchId) async {
    if (AuthService().isLiveMode && AuthService().checkSupabaseReady()) {
      try {
        final client = Supabase.instance.client;
        final res = await client
            .from('user_branch_assignments')
            .select('id, user_id, role, is_active, created_at, profiles(full_name, email, phone_number, avatar_url), branches(name)')
            .eq('branch_id', branchId)
            .eq('is_active', true);

        _members.clear();
        for (final row in res) {
          final profile = row['profiles'] as Map<String, dynamic>?;
          final branchData = row['branches'] as Map<String, dynamic>?;
          final memId = row['id'] as String;
          final avatar = profile?['avatar_url'] as String?;
          final mem = MemberProfileModel(
            memberId: memId,
            name: profile?['full_name'] as String? ?? 'Member',
            email: profile?['email'] as String? ?? '',
            phone: profile?['phone_number'] as String? ?? '',
            branchId: branchId,
            branchName: branchData?['name'] as String? ?? 'Techverve',
            role: (row['role'] as String? ?? 'member').toUpperCase(),
            status: (row['is_active'] as bool? ?? true) ? 'Active' : 'Inactive',
            photoAttached: avatar != null && avatar.isNotEmpty,
            submittedFields: {},
            joinedAt: DateTime.tryParse(row['created_at']?.toString() ?? '') ?? DateTime.now(),
          );
          _members[memId] = mem;
        }
        notifyListeners();
        return _members.values.toList();
      } catch (e) {
        debugPrint('[Kivora] fetchBranchMembers note: $e');
      }
    }
    return _members.values.toList();
  }

  /// Updates authenticated user profile in Supabase and local state
  Future<void> updateUserProfile({
    required String name,
    String? phone,
    String? studentId,
  }) async {
    _currentUserName = name.trim();
    if (AuthService().isLiveMode && AuthService().checkSupabaseReady()) {
      try {
        final client = Supabase.instance.client;
        final userId = client.auth.currentUser?.id ?? _currentUserId;
        await client.from('profiles').update({
          'full_name': _currentUserName,
          if (phone != null && phone.isNotEmpty) 'phone_number': phone.trim(),
          if (studentId != null && studentId.isNotEmpty) 'identifier_code': studentId.trim(),
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', userId);
      } catch (e) {
        debugPrint('[Kivora] updateUserProfile Supabase error: $e');
      }
    }
    await _persistCurrentSession();
    notifyListeners();
  }

  List<MembershipApplicationModel> getApplicationsForBranch(String branchId) {
    return _applications.where((a) => a.branchId == branchId).toList();
  }

  String? getApplicationStatus(String appId) {
    return getApplicationById(appId)?.status;
  }

  List<MembershipApplicationModel> getPendingApplications(String branchId) {
    return _applications.where((a) => a.branchId == branchId && a.status == 'pending').toList();
  }

  MembershipApplicationModel? getApplicationById(String appId) {
    return _applications.cast<MembershipApplicationModel?>().firstWhere(
      (a) => a?.id == appId,
      orElse: () => null,
    );
  }

  Future<void> approveApplication(String applicationId) async {
    final app = getApplicationById(applicationId);
    if (app != null) {
      if (AuthService().isLiveMode && AuthService().checkSupabaseReady()) {
        try {
          final client = Supabase.instance.client;
          final reviewerId = client.auth.currentUser?.id;
          await client
              .from('branch_membership_requests')
              .update({
                'status': 'approved',
                'reviewed_by': reviewerId,
                'reviewed_at': DateTime.now().toIso8601String(),
              })
              .eq('id', applicationId);
          debugPrint('[Kivora] Supabase membership request approved: $applicationId');
        } catch (e) {
          debugPrint('Supabase approveApplication error: $e');
        }
      }

      app.status = 'approved';
      app.reviewedAt = DateTime.now();

      final memId = 'usr-${DateTime.now().millisecondsSinceEpoch}';
      final phone = app.submittedData['phone']?.toString() ?? '+234 800 000 0000';
      _members[memId] = MemberProfileModel(
        memberId: memId,
        name: app.userName,
        email: app.userEmail,
        phone: phone,
        branchId: app.branchId,
        branchName: app.branchName,
        role: 'Member',
        status: 'Active',
        photoAttached: app.photoAttached,
        submittedFields: Map.from(app.submittedData),
        joinedAt: DateTime.now(),
      );

      if (_currentUserEmail.toLowerCase() == app.userEmail.toLowerCase()) {
        _currentRole = 'member';
        _currentApplication = app;
        _membershipStatus = 'approved';
      }

      notifyListeners();
    }
  }

  Future<void> rejectApplication(String applicationId, {String? reason}) async {
    final app = getApplicationById(applicationId);
    if (app != null) {
      if (AuthService().isLiveMode && AuthService().checkSupabaseReady()) {
        try {
          final client = Supabase.instance.client;
          final reviewerId = client.auth.currentUser?.id;
          await client
              .from('branch_membership_requests')
              .update({
                'status': 'rejected',
                'decision_reason': reason ?? 'Application declined by manager',
                'reviewed_by': reviewerId,
                'reviewed_at': DateTime.now().toIso8601String(),
              })
              .eq('id', applicationId);
          debugPrint('[Kivora] Supabase membership request rejected: $applicationId');
        } catch (e) {
          debugPrint('Supabase rejectApplication error: $e');
        }
      }

      app.status = 'rejected';
      app.reviewedAt = DateTime.now();
      app.reviewerNotes = reason;
      if (_currentUserEmail.toLowerCase() == app.userEmail.toLowerCase()) {
        _currentApplication = app;
        _membershipStatus = 'rejected';
      }
      notifyListeners();
    }
  }

  // --- Attendance Record Logging ---

  void recordSignIn({
    required String memberId,
    required String memberName,
    required String memberEmail,
    required String branchId,
    required String verificationMethod,
  }) {
    final record = AttendanceRecordModel(
      id: 'att-${DateTime.now().millisecondsSinceEpoch}',
      memberId: memberId,
      memberName: memberName,
      memberEmail: memberEmail,
      branchId: branchId,
      signInTime: DateTime.now(),
      verificationMethod: verificationMethod,
    );
    _attendanceRecords.insert(0, record);
    notifyListeners();
  }

  MemberProfileModel? getMemberById(String memberId) {
    return _members[memberId];
  }

  /// Secure photo upload to Supabase Storage 'id-documents' bucket
  Future<String?> uploadPhotoToSupabase(Uint8List bytes, String filename) async {
    if (AuthService().isLiveBackendConfigured) {
      try {
        final user = Supabase.instance.client.auth.currentUser;
        final userId = user?.id ?? currentUserId;
        final path = '$userId/$filename';
        await Supabase.instance.client.storage.from('id-documents').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
        final signedUrl = await Supabase.instance.client.storage.from('id-documents').createSignedUrl(path, 3600);
        return signedUrl;
      } catch (e) {
        debugPrint('Failed to upload photo to Supabase storage: $e');
        return null;
      }
    }
    return 'demo_photo.jpg';
  }
}
