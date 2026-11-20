import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Lightweight persistent storage service with an immediate in-memory cache.
/// Works seamlessly across Web, Mobile, and unit test environments.
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final Map<String, String> _memoryCache = {};
  FlutterSecureStorage? _secureStorage;

  FlutterSecureStorage get _storage {
    _secureStorage ??= const FlutterSecureStorage();
    return _secureStorage!;
  }

  // --- Core Key-Value Operations ---

  static bool _memoryOnlyOverride = false;

  /// Whether the current environment is a Flutter test run.
  /// When true, all operations use the in-memory cache only (no platform channels or pending timers).
  static bool get _isTestEnvironment {
    if (_memoryOnlyOverride) return true;
    try {
      final binding = WidgetsBinding.instance;
      if (binding.runtimeType.toString().contains('Test')) return true;
    } catch (_) {}
    return false;
  }

  /// Explicitly force in-memory storage mode.
  static void useMemoryOnlyForTests() => _memoryOnlyOverride = true;

  Future<void> setString(String key, String value) async {
    _memoryCache[key] = value;
    if (_isTestEnvironment) return;
    try {
      await _storage.write(key: key, value: value).timeout(
        const Duration(seconds: 2),
        onTimeout: () => debugPrint('StorageService write timed out for key "$key" (using memory cache).'),
      );
    } catch (e) {
      // Platform channels may not be available in flutter_test or unsupported web wasm;
      // memory cache preserves state for the active runtime.
      debugPrint('StorageService write fallback to memory for key "$key": $e');
    }
  }

  Future<String?> getString(String key) async {
    if (_memoryCache.containsKey(key)) {
      return _memoryCache[key];
    }
    if (_isTestEnvironment) return null;
    try {
      final value = await _storage.read(key: key).timeout(
        const Duration(seconds: 2),
        onTimeout: () => null,
      );
      if (value != null) {
        _memoryCache[key] = value;
      }
      return value;
    } catch (e) {
      debugPrint('StorageService read fallback for key "$key": $e');
      return null;
    }
  }

  Future<void> remove(String key) async {
    _memoryCache.remove(key);
    if (_isTestEnvironment) return;
    try {
      await _storage.delete(key: key).timeout(const Duration(seconds: 2), onTimeout: () {});
    } catch (_) {}
  }

  Future<void> clearAll() async {
    _memoryCache.clear();
    if (_isTestEnvironment) return;
    try {
      await _storage.deleteAll().timeout(const Duration(seconds: 2), onTimeout: () {});
    } catch (_) {}
  }

  // --- Specialized Persistence Helpers ---

  // 1. Branch Wizard Draft
  static const String _branchDraftKey = 'kivora_branch_wizard_draft';

  Future<void> saveBranchDraft(Map<String, dynamic> draftData) async {
    final encoded = jsonEncode(draftData);
    await setString(_branchDraftKey, encoded);
  }

  Future<Map<String, dynamic>?> getBranchDraft() async {
    final raw = await getString(_branchDraftKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearBranchDraft() async {
    await remove(_branchDraftKey);
  }

  // 2. Session & Active Branch Persistence
  static const String _currentBranchIdKey = 'kivora_active_branch_id';
  static const String _currentUserEmailKey = 'kivora_session_email';
  static const String _currentUserNameKey = 'kivora_session_name';
  static const String _currentRoleKey = 'kivora_session_role';
  static const String _membershipStatusKey = 'kivora_membership_status';
  static const String _appModeKey = 'kivora_app_mode';

  Future<void> saveSession({
    String? branchId,
    String? email,
    String? name,
    String? role,
    String? membershipStatus,
    String? appMode,
  }) async {
    if (branchId != null) await setString(_currentBranchIdKey, branchId);
    if (email != null) await setString(_currentUserEmailKey, email);
    if (name != null) await setString(_currentUserNameKey, name);
    if (role != null) await setString(_currentRoleKey, role);
    if (membershipStatus != null) await setString(_membershipStatusKey, membershipStatus);
    if (appMode != null) await setString(_appModeKey, appMode);
  }

  Future<Map<String, String?>> getSession() async {
    return {
      'branchId': await getString(_currentBranchIdKey),
      'email': await getString(_currentUserEmailKey),
      'name': await getString(_currentUserNameKey),
      'role': await getString(_currentRoleKey),
      'membershipStatus': await getString(_membershipStatusKey),
      'appMode': await getString(_appModeKey),
    };
  }

  Future<void> clearSession() async {
    await remove(_currentBranchIdKey);
    await remove(_currentUserEmailKey);
    await remove(_currentUserNameKey);
    await remove(_currentRoleKey);
    await remove(_membershipStatusKey);
  }
}
