import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthResult {
  final bool isSuccess;
  final String? errorMessage;
  final String? successMessage;
  final String? email;
  final bool isUnconfigured;

  const AuthResult._({
    required this.isSuccess,
    this.errorMessage,
    this.successMessage,
    this.email,
    this.isUnconfigured = false,
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

  bool _isLiveBackendConfigured = false;
  bool get isLiveBackendConfigured => _isLiveBackendConfigured;

  // Active OTP expiration and tracking for demo mode
  String? _demoEmail;
  String? get demoEmail => _demoEmail;
  String _demoOtp = '123456';
  DateTime? _demoOtpExpiresAt;

  void setLiveBackendConfigured(bool configured) {
    _isLiveBackendConfigured = configured;
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

  /// Request registration and email verification code
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    // 1. If Live Supabase Backend is available
    if (checkSupabaseReady()) {
      try {
        final response = await Supabase.instance.client.auth.signUp(
          email: cleanEmail,
          password: password,
          data: {'full_name': fullName.trim()},
        );

        if (response.user != null) {
          return AuthResult.success(
            message: 'Verification code sent to $cleanEmail',
            email: cleanEmail,
          );
        } else {
          return AuthResult.failure('Registration failed. Please verify your details.');
        }
      } on AuthException catch (e) {
        return AuthResult.failure(e.message);
      } catch (e) {
        return AuthResult.failure('Authentication network failure: $e');
      }
    }

    // 2. If Live Backend is NOT configured
    return AuthResult.unconfigured(
      'Email verification service is not configured. Real verification codes require an active Supabase backend with SMTP/Email provider settings.',
    );
  }

  /// Sign in with password against real Supabase Auth
  Future<AuthResult> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    if (checkSupabaseReady()) {
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
        return AuthResult.failure(e.message);
      } catch (e) {
        return AuthResult.failure('Authentication network failure: $e');
      }
    }

    return AuthResult.unconfigured(
      'Live authentication backend is not configured.',
    );
  }

  /// Sign out
  Future<void> signOut() async {
    if (checkSupabaseReady()) {
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (_) {}
    }
  }

  /// Restore active session from Supabase on reload
  Future<String?> restoreSession() async {
    if (checkSupabaseReady()) {
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

    // 1. If Live Supabase Backend is active
    if (checkSupabaseReady() && !isDemoMode) {
      try {
        final res = await Supabase.instance.client.auth.verifyOTP(
          email: cleanEmail,
          token: cleanToken,
          type: OtpType.signup,
        );

        if (res.session != null || res.user != null) {
          return AuthResult.success(email: cleanEmail);
        } else {
          return AuthResult.failure('Invalid or expired verification code.');
        }
      } on AuthException catch (e) {
        return AuthResult.failure(e.message);
      } catch (e) {
        return AuthResult.failure('Verification request failed: $e');
      }
    }

    // 2. If in Demo Mode, strictly validate against the assigned demo code
    if (isDemoMode) {
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

    return AuthResult.unconfigured(
      'Authentication backend is not configured to verify codes.',
    );
  }

  /// Resend verification code
  Future<AuthResult> resendOtp({
    required String email,
    bool isDemoMode = false,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    if (checkSupabaseReady() && !isDemoMode) {
      try {
        await Supabase.instance.client.auth.resend(
          type: OtpType.signup,
          email: cleanEmail,
        );
        return AuthResult.success(
          message: 'A new verification code has been sent to $cleanEmail',
          email: cleanEmail,
        );
      } on AuthException catch (e) {
        return AuthResult.failure(e.message);
      } catch (e) {
        return AuthResult.failure('Failed to resend code: $e');
      }
    }

    if (isDemoMode) {
      _demoOtp = '123456';
      _demoOtpExpiresAt = DateTime.now().add(const Duration(minutes: 10));
      return AuthResult.success(
        message: '[Demo Mode] A new demo verification code has been generated: 123456',
        email: cleanEmail,
      );
    }

    return AuthResult.unconfigured('Email delivery provider is not configured.');
  }
}
