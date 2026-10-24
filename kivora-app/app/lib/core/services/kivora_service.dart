import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';

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

class MembershipApplicationModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String branchId;
  final String branchName;
  final String inviteCode;
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

class KivoraService extends ChangeNotifier {
  static final KivoraService _instance = KivoraService._internal();
  factory KivoraService() => _instance;

  KivoraService._internal() {
    _initializeData();
  }

  // Active branches
  final List<BranchModel> _branches = [];
  List<BranchModel> get branches => List.unmodifiable(_branches);

  // Per-branch form configurations: branchId -> List<IdFormFieldModel>
  final Map<String, List<IdFormFieldModel>> _idFormConfigs = {};

  // Membership applications
  final List<MembershipApplicationModel> _applications = [];
  List<MembershipApplicationModel> get applications => List.unmodifiable(_applications);

  // Attendance sign-in records (Strictly actual sign-in logs, no fake present/late/absent)
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

  bool get isAuthenticated => _isAuthenticated || _currentUserEmail.isNotEmpty;
  bool get isEmailVerified => _isEmailVerified;
  String get membershipStatus => _membershipStatus;

  String get currentUserId => _currentUserId;
  String get currentUserEmail => _currentUserEmail;
  String get currentUserName => _currentUserName;
  String get currentRole => _currentRole;
  String? get currentBranchId => _currentBranchId;
  MembershipApplicationModel? get currentApplication => _currentApplication;

  void setEmailVerified(bool verified) {
    _isEmailVerified = verified;
    notifyListeners();
  }

  void setMembershipStatus(String status) {
    _membershipStatus = status;
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
    _currentApplication = _applications.cast<MembershipApplicationModel?>().firstWhere(
      (app) => app?.userEmail.toLowerCase() == email.toLowerCase(),
      orElse: () => null,
    );

    if (_currentApplication != null) {
      _membershipStatus = _currentApplication!.status;
    } else if (role == 'member') {
      _membershipStatus = 'approved';
    } else {
      _membershipStatus = 'none';
    }

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
    notifyListeners();
  }

  void resetToDefaults() {
    _branches.clear();
    _idFormConfigs.clear();
    _applications.clear();
    _attendanceRecords.clear();
    _members.clear();
    clearSession();
    _initializeData();
  }

  List<MembershipApplicationModel> getApplicationsForBranch(String branchId) {
    return _applications.where((a) => a.branchId == branchId).toList();
  }

  String? getApplicationStatus(String appId) {
    return getApplicationById(appId)?.status;
  }

  void _initializeData() {
    // 1. Initial Branches
    _branches.addAll([
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

    // 2. Default ID Form Config for West Campus
    _idFormConfigs['branch-west'] = [
      IdFormFieldModel(id: 'photo', label: 'Identity Photo', type: FieldType.photo, isRequired: true, isEnabled: true, order: 0),
      IdFormFieldModel(id: 'full_name', label: 'Full Name', type: FieldType.text, isRequired: true, isEnabled: true, order: 1),
      IdFormFieldModel(id: 'email', label: 'Email Address', type: FieldType.email, isRequired: true, isEnabled: true, order: 2),
      IdFormFieldModel(id: 'phone', label: 'Phone Number', type: FieldType.phone, isRequired: true, isEnabled: true, order: 3),
      IdFormFieldModel(id: 'student_id', label: 'Student / Employee ID', type: FieldType.text, isRequired: true, isEnabled: true, order: 4),
      IdFormFieldModel(id: 'nin_id', label: 'National ID (NIN)', type: FieldType.text, isRequired: false, isEnabled: true, order: 5),
    ];

    // Default for other branches
    _idFormConfigs['branch-east'] = [
      IdFormFieldModel(id: 'photo', label: 'Profile Photo', type: FieldType.photo, isRequired: true, isEnabled: true, order: 0),
      IdFormFieldModel(id: 'full_name', label: 'Full Name', type: FieldType.text, isRequired: true, isEnabled: true, order: 1),
      IdFormFieldModel(id: 'email', label: 'Email Address', type: FieldType.email, isRequired: true, isEnabled: true, order: 2),
      IdFormFieldModel(id: 'phone', label: 'Phone Number', type: FieldType.phone, isRequired: true, isEnabled: true, order: 3),
      IdFormFieldModel(id: 'student_id', label: 'Matriculation Number', type: FieldType.text, isRequired: true, isEnabled: true, order: 4),
    ];

    // 3. Initial Member Profiles
    final now = DateTime.now();
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
        'student_id': 'STAFF-089',
      },
      joinedAt: DateTime(now.year, now.month - 1, 20),
    );

    // 4. Initial Actual Sign-In Attendance Logs (Strictly timestamped sign-ins)
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
        signInTime: DateTime(now.year, now.month, now.day, 8, 47),
        verificationMethod: 'Wi-Fi Network Verification',
      ),
    ]);

    // 5. Initial Pending Applications for Branch Manager to review
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
  }

  // --- Branch & Invite Code Validation ---

  BranchModel? validateInviteCode(String code) {
    final clean = code.trim().toUpperCase();
    if (clean.isEmpty) return null;
    return _branches.cast<BranchModel?>().firstWhere(
      (b) => b?.isActive == true && b?.inviteCode.toUpperCase() == clean,
      orElse: () => null,
    );
  }

  BranchModel? getBranchById(String id) {
    return _branches.cast<BranchModel?>().firstWhere(
      (b) => b?.id == id,
      orElse: () => null,
    );
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

    // Initialize default ID form fields for the new branch
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

  /// Persists a new branch to Supabase if live backend is configured,
  /// otherwise saves it into the local KivoraService repository.
  Future<BranchModel> createBranch({
    required String name,
    required String organizationType,
    required String address,
    required String contactPhone,
    required String contactEmail,
    String description = '',
  }) async {
    if (AuthService().checkSupabaseReady()) {
      try {
        final client = Supabase.instance.client;
        final currentUser = client.auth.currentUser;
        final userId = currentUser?.id;

        if (userId != null) {
          // 1. Create organization
          final orgRes = await client.from('organizations').insert({
            'name': '$name Organization',
            'organization_type': organizationType.toLowerCase(),
          }).select().single();
          final orgId = orgRes['id'] as String;

          // 2. Generate branch invite code
          final codePrefix = name.trim().split(RegExp(r'\s+')).first.toUpperCase();
          final inviteCode = '$codePrefix-2026';

          // 3. Insert branch record
          final branchRes = await client.from('branches').insert({
            'organization_id': orgId,
            'name': name,
            'branch_code': inviteCode,
            'description': description,
            'address': address,
            'contact_phone': contactPhone,
            'contact_email': contactEmail,
            'created_by': userId,
          }).select().single();

          final branchId = branchRes['id'] as String;

          // 4. Assign current user as initial branch manager
          await client.from('user_branch_assignments').insert({
            'user_id': userId,
            'branch_id': branchId,
            'role': 'branch_manager',
            'is_active': true,
          });

          // 5. Create invite code entry
          try {
            await client.from('branch_invite_codes').insert({
              'branch_id': branchId,
              'code': inviteCode,
              'created_by': userId,
              'expires_at': DateTime.now().add(const Duration(days: 365)).toIso8601String(),
            });
          } catch (e) {
            debugPrint('Note: branch_invite_codes insertion: $e');
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

          _branches.add(created);
          _currentBranchId = branchId;
          notifyListeners();
          return created;
        }
      } catch (e) {
        debugPrint('Supabase branch creation error: $e');
        rethrow;
      }
    }

    // Demo / offline fallback
    return addBranch(
      name: name,
      organizationType: organizationType,
      address: address,
      contactPhone: contactPhone,
      contactEmail: contactEmail,
      description: description,
    );
  }

  /// Fetches branch details by branch ID from Supabase if connected,
  /// otherwise from local KivoraService repository.
  Future<BranchModel?> fetchBranch(String branchId) async {
    if (AuthService().checkSupabaseReady()) {
      try {
        final client = Supabase.instance.client;
        final res = await client
            .from('branches')
            .select()
            .eq('id', branchId)
            .maybeSingle();

        if (res != null) {
          final branch = BranchModel.fromJson(res);
          final idx = _branches.indexWhere((b) => b.id == branch.id);
          if (idx != -1) {
            _branches[idx] = branch;
          } else {
            _branches.add(branch);
          }
          _currentBranchId = branch.id;
          notifyListeners();
          return branch;
        }
      } catch (e) {
        debugPrint('Supabase fetchBranch error: $e');
      }
      return null;
    }

    return getBranchById(branchId);
  }

  /// Fetches the branch associated with the current user or session.
  /// Never falls back silently to mock branch data when in live mode.
  Future<BranchModel?> fetchCurrentBranch() async {
    if (AuthService().checkSupabaseReady()) {
      try {
        final client = Supabase.instance.client;
        final userId = client.auth.currentUser?.id;
        if (userId != null) {
          // Check assignment
          final assignment = await client
              .from('user_branch_assignments')
              .select('branch_id')
              .eq('user_id', userId)
              .eq('is_active', true)
              .maybeSingle();

          if (assignment != null && assignment['branch_id'] != null) {
            return await fetchBranch(assignment['branch_id'] as String);
          }

          // Check branch created by user
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
            return branch;
          }
        }
      } catch (e) {
        debugPrint('Supabase fetchCurrentBranch error: $e');
      }
      return null;
    }

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
    // Fallback default
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
    required String userName,
    required String userEmail,
    required Map<String, dynamic> submittedData,
    bool photoAttached = false,
  }) {
    final branch = getBranchById(branchId);
    final branchName = branch?.name ?? 'Branch';

    final app = MembershipApplicationModel(
      id: 'app-${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUserId,
      userName: userName,
      userEmail: userEmail,
      branchId: branchId,
      branchName: branchName,
      inviteCode: inviteCode,
      submittedData: Map.from(submittedData),
      photoAttached: photoAttached,
      status: 'pending',
      submittedAt: DateTime.now(),
    );

    _applications.removeWhere((a) => a.userEmail.toLowerCase() == userEmail.toLowerCase() && a.branchId == branchId);
    _applications.add(app);
    _currentApplication = app;
    _currentBranchId = branchId;
    _membershipStatus = 'pending';
    notifyListeners();
    return app;
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

  void approveApplication(String applicationId) {
    final app = getApplicationById(applicationId);
    if (app != null) {
      app.status = 'approved';
      app.reviewedAt = DateTime.now();

      // Create or update active MemberProfile
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

      // If it's the currently signed in user, elevate state
      if (_currentUserEmail.toLowerCase() == app.userEmail.toLowerCase()) {
        _currentRole = 'member';
        _currentApplication = app;
        _membershipStatus = 'approved';
      }

      notifyListeners();
    }
  }

  void rejectApplication(String applicationId, {String? reason}) {
    final app = getApplicationById(applicationId);
    if (app != null) {
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
