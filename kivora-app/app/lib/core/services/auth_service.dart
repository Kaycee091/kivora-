import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'storage_service.dart';

enum AppMode {
  live,
  demo,
}

class AuthResult {
  final bool isSuccess;
  final String? errorMessage;
  final String? successMessage;
  final String? email;
  final bool isUnconfigured;
  final bool needsEmailVerification;

  const AuthResult._({
    required this.isSuccess,
    this.errorMessage,
    this.successMessage,
    this.email,
    this.isUnconfigured = false,
    this.needsEmailVerification = false,
  });

  factory AuthResult.success({String? message, String? email}) {
    return AuthResult._(
      isSuccess: true,
      successMessage: message,
      email: email,
    );
  }

  factory AuthResult.failure(String error) {
    return AuthResult._(
      isSuccess: false,
      errorMessage: error,
    );
  }

  factory AuthResult.emailNotVerified(String email) {
    return AuthResult._(
      isSuccess: false,
      errorMessage: 'Please verify your email address to continue.',
      email: email,
      needsEmailVerification: true,
    );
  }

  factory AuthResult.unconfigured(String message) {
    return AuthResult._(
      isSuccess: false,
      errorMessage: message,
      isUnconfigured: true,
    );
  }
}

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Explicit App Mode: LIVE by default
  AppMode _appMode = AppMode.live;
  AppMode get appMode => _appMode;
  bool get isLiveMode => _appMode == AppMode.live;
  bool get isDemoMode => _appMode == AppMode.demo;

  bool _isLiveBackendConfigured = false;
  bool get isLiveBackendConfigured => _isLiveBackendConfigured;

  String? _liveInitError;
  String? get liveInitError => _liveInitError;

  // Active OTP expiration and tracking for demo mode
  String? _demoEmail;
  String? get demoEmail => _demoEmail;
  String _demoOtp = '123456';
  DateTime? _demoOtpExpiresAt;

  void setAppMode(AppMode mode) {
    _appMode = mode;
    notifyListeners();
  }

  void switchToDemoMode() {
    _appMode = AppMode.demo;
    notifyListeners();
  }

  void switchToLiveMode() {
    _appMode = AppMode.live;
    notifyListeners();
  }

  void setLiveBackendConfigured(bool configured) {
    _isLiveBackendConfigured = configured;
    if (configured) {
      _liveInitError = null;
    }
    notifyListeners();
  }

  void setLiveInitError(String? error) {
    _liveInitError = error;
    notifyListeners();
  }

  /// Check if Supabase client is actually initialized and responsive
  bool checkSupabaseReady() {
    if (!_isLiveBackendConfigured) return false;
    try {
      final _ = Supabase.instance.client;
      return true;
    } catch (_) {
      _isLiveBackendConfigured = false;
      return false;
    }
  }

  User? get currentSupabaseUser {
    if (checkSupabaseReady()) {
      return Supabase.instance.client.auth.currentUser;
    }
    return null;
  }

  String? get currentUserId => currentSupabaseUser?.id;
  String? get currentUserEmail => currentSupabaseUser?.email ?? _demoEmail;

  /// Kivora web server that sends verification email through Brevo SMTP.
  static const String apiBaseUrl = String.fromEnvironment(
    'KIVORA_API_URL',
    defaultValue: 'http://localhost:3000',
  );

  // Held in memory only, so the user is signed in right after verifying.
  String? _pendingEmail;
  String? _pendingPassword;

  void _rememberPendingCredentials(String email, String password) {
    _pendingEmail = email;
    _pendingPassword = password;
  }

  Future<AuthResult> _postToEmailApi(String path, Map<String, String> body, String fallbackError) async {
    try {
      final response = await http
          .post(
            Uri.parse('$apiBaseUrl$path'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      Map<String, dynamic> data = {};
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) data = decoded;
      } catch (_) {}

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return AuthResult.success(
          message: data['message'] as String?,
          email: data['email'] as String? ?? body['email'],
        );
      }
      return AuthResult.failure(data['error'] as String? ?? fallbackError);
    } on TimeoutException {
      return AuthResult.failure('The email service took too long to respond. Please try again.');
    } catch (e) {
      return AuthResult.failure('Could not reach the Kivora email service at $apiBaseUrl: $e');
    }
  }

  /// Request registration and email verification code
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    // 1. LIVE Mode
    if (isLiveMode) {
      if (!checkSupabaseReady()) {
        return AuthResult.unconfigured(
          _liveInitError ??
              'Email verification service is not configured: Live Supabase backend is not configured. Please supply SUPABASE_URL and SUPABASE_ANON_KEY (or SUPABASE_PUBLISHABLE_KEY) or switch to Demo Mode.',
        );
      }

      final result = await _postToEmailApi(
        '/api/auth/register',
        {'email': cleanEmail, 'password': password, 'fullName': fullName.trim()},
        'Registration failed. Please verify your details.',
      );
      if (result.isSuccess) {
        _rememberPendingCredentials(cleanEmail, password);
      }
      return result;
    }

    // 2. DEMO Mode
    return startDemoRegistration(email: cleanEmail, fullName: fullName);
  }

  /// Sign in with password
  Future<AuthResult> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    // 1. LIVE Mode
    if (isLiveMode) {
      if (!checkSupabaseReady()) {
        return AuthResult.unconfigured(
          _liveInitError ??
              'Cannot sign in in LIVE mode: Live Supabase backend is not configured. Please supply SUPABASE_URL and SUPABASE_ANON_KEY (or SUPABASE_PUBLISHABLE_KEY) or switch to Demo Mode.',
        );
      }

      try {
        final res = await Supabase.instance.client.auth.signInWithPassword(
          email: cleanEmail,
          password: password,
        );

        if (res.user != null) {
          return AuthResult.success(
            message: 'Signed in successfully',
            email: cleanEmail,
          );
        } else {
          return AuthResult.failure('Invalid email or password.');
        }
      } on AuthException catch (e) {
        if (e.code == 'email_not_confirmed' || e.message.toLowerCase().contains('email not confirmed')) {
          _rememberPendingCredentials(cleanEmail, password);
          return AuthResult.emailNotVerified(cleanEmail);
        }
        return AuthResult.failure(e.message);
      } catch (e) {
        return AuthResult.failure('Authentication network failure: $e');
      }
    }

    // 2. DEMO Mode
    if (password.length >= 6) {
      return AuthResult.success(
        message: '[Demo Mode] Signed in successfully in demo mode',
        email: cleanEmail,
      );
    }
    return AuthResult.failure('Invalid demo password (must be at least 6 characters).');
  }

  VoidCallback? _onSignOutCallback;

  /// Register a callback invoked when the user signs out
  void registerSignOutHandler(VoidCallback handler) {
    _onSignOutCallback = handler;
  }

  /// Sign out
  Future<void> signOut() async {
    if (checkSupabaseReady()) {
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (_) {}
    }
    await StorageService().clearSession();
    _onSignOutCallback?.call();
    notifyListeners();
  }

  /// Restore active session from Supabase on reload
  Future<String?> restoreSession() async {
    if (isLiveMode && checkSupabaseReady()) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        return user.email;
      }
    }
    return null;
  }

  /// Explicit Demo Mode registration (clearly separated from live auth)
  AuthResult startDemoRegistration({
    required String email,
    required String fullName,
  }) {
    final cleanEmail = email.trim().toLowerCase();
    _demoEmail = cleanEmail;
    _demoOtp = '123456';
    _demoOtpExpiresAt = DateTime.now().add(const Duration(minutes: 10));

    return AuthResult.success(
      message: '[Demo Mode] Demo verification session initialized for $cleanEmail. Test OTP is 123456.',
      email: cleanEmail,
    );
  }

  /// Verify 6-digit OTP code against real auth provider or strict demo mode
  Future<AuthResult> verifyOtp({
    required String email,
    required String token,
    bool isDemoMode = false,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanToken = token.trim();

    if (cleanToken.length != 6) {
      return AuthResult.failure('Verification code must be exactly 6 digits.');
    }

    // 1. LIVE Mode
    if (isLiveMode && !isDemoMode) {
      if (!checkSupabaseReady()) {
        return AuthResult.unconfigured(
          _liveInitError ?? 'Authentication backend is not configured to verify codes in LIVE mode.',
        );
      }

      final result = await _postToEmailApi(
        '/api/auth/verify-email',
        {'email': cleanEmail, 'code': cleanToken},
        'Invalid or expired verification code.',
      );
      if (!result.isSuccess) return result;

      // Email is confirmed server-side; open a session with the password from registration.
      final password = _pendingEmail == cleanEmail ? _pendingPassword : null;
      _pendingEmail = null;
      _pendingPassword = null;
      if (password != null) {
        final signIn = await signInWithPassword(email: cleanEmail, password: password);
        if (signIn.isSuccess) return AuthResult.success(email: cleanEmail);
      }
      return AuthResult.success(
        message: 'Email verified. Please sign in to continue.',
        email: cleanEmail,
      );
    }

    // 2. DEMO Mode
    if (_demoOtpExpiresAt != null && DateTime.now().isAfter(_demoOtpExpiresAt!)) {
      return AuthResult.failure('Verification code has expired. Please request a new code.');
    }

    if (cleanToken == _demoOtp) {
      return AuthResult.success(
        message: 'Email successfully verified in demo mode.',
        email: cleanEmail,
      );
    } else {
      return AuthResult.failure('Invalid verification code. (In Demo Mode, the valid code is 123456)');
    }
  }

  /// Resend verification code
  Future<AuthResult> resendOtp({
    required String email,
    bool isDemoMode = false,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    if (isLiveMode && !isDemoMode) {
      if (!checkSupabaseReady()) {
        return AuthResult.unconfigured('Email delivery provider is not configured in LIVE mode.');
      }

      return _postToEmailApi(
        '/api/auth/resend-code',
        {'email': cleanEmail},
        'Failed to resend code.',
      );
    }

    _demoOtp = '123456';
    _demoOtpExpiresAt = DateTime.now().add(const Duration(minutes: 10));
    return AuthResult.success(
      message: '[Demo Mode] A new demo verification code has been generated: 123456',
      email: cleanEmail,
    );
  }
}
