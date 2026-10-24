import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/kivora_service.dart';
import '../../../core/theme/kivora_theme.dart';
import '../../../core/widgets/kivora_components.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _generalError;
  bool _isUnconfiguredBackend = false;

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    bool isValid = true;
    setState(() {
      _nameError = null;
      _emailError = null;
      _passwordError = null;
      _generalError = null;
      _isUnconfiguredBackend = false;
    });

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty) {
      setState(() => _nameError = 'Full name is required');
      isValid = false;
    } else if (name.length < 2) {
      setState(() => _nameError = 'Please enter your complete name.');
      isValid = false;
    }

    if (email.isEmpty) {
      setState(() => _emailError = 'Email address is required');
      isValid = false;
    } else {
      final emailRegex = RegExp(r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$');
      if (!emailRegex.hasMatch(email)) {
        setState(() => _emailError = 'Please enter a valid email address');
        isValid = false;
      }
    }

    if (password.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      isValid = false;
    } else if (password.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      isValid = false;
    }

    return isValid;
  }

  Future<void> _handleRegister() async {
    if (!_validateInputs()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    setState(() {
      _isLoading = true;
      _generalError = null;
      _isUnconfiguredBackend = false;
    });

    try {
      final result = await AuthService().signUp(
        email: email,
        password: password,
        fullName: name,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.isSuccess) {
        // Save user registration state in KivoraService
        KivoraService().setCurrentUser(
          email: email,
          name: name,
          role: 'guest',
        );

        final encodedEmail = Uri.encodeComponent(email);
        context.go('/auth/verify-email?email=$encodedEmail', extra: {
          'email': email,
          'isDemo': false,
        });
      } else if (result.isUnconfigured) {
        setState(() {
          _isUnconfiguredBackend = true;
          _generalError = result.errorMessage;
        });
      } else {
        setState(() {
          _generalError = result.errorMessage ?? 'Registration request failed. Please try again.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _generalError = 'An unexpected error occurred during registration. Please try again.';
      });
    }
  }

  void _handleDemoRegistration() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();

    AuthService().startDemoRegistration(
      email: email,
      fullName: name,
    );

    KivoraService().setCurrentUser(
      email: email,
      name: name,
      role: 'guest',
    );

    final encodedEmail = Uri.encodeComponent(email);
    context.go('/auth/verify-email?email=$encodedEmail', extra: {
      'email': email,
      'isDemo': true,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/welcome'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Create Account', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: KivoraColors.textPrimary)),
              const SizedBox(height: 6),
              const Text('Fill in your details to get started.', style: TextStyle(color: KivoraColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 24),

              if (_generalError != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isUnconfiguredBackend ? const Color(0xFFFFFBEB) : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isUnconfiguredBackend ? const Color(0xFFFDE68A) : const Color(0xFFFCA5A5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            _isUnconfiguredBackend ? Icons.info_outline : Icons.error_outline,
                            size: 20,
                            color: _isUnconfiguredBackend ? const Color(0xFFD97706) : const Color(0xFFDC2626),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _generalError!,
                              style: TextStyle(
                                fontSize: 13,
                                color: _isUnconfiguredBackend ? const Color(0xFF92400E) : const Color(0xFFDC2626),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_isUnconfiguredBackend) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.play_circle_outline, size: 18),
                            label: const Text('Continue in Demo Mode (Offline Preview)'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0D9488),
                              side: const BorderSide(color: Color(0xFF0D9488)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onPressed: _handleDemoRegistration,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name *',
                  hintText: 'Enter your full name',
                  errorText: _nameError,
                  prefixIcon: const Icon(Icons.person_outline, color: KivoraColors.textMuted),
                ),
                onChanged: (_) {
                  if (_nameError != null) setState(() => _nameError = null);
                },
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address *',
                  hintText: 'example@domain.com',
                  errorText: _emailError,
                  prefixIcon: const Icon(Icons.email_outlined, color: KivoraColors.textMuted),
                ),
                onChanged: (_) {
                  if (_emailError != null) setState(() => _emailError = null);
                },
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password *',
                  hintText: 'Create a password (min 6 characters)',
                  errorText: _passwordError,
                  prefixIcon: const Icon(Icons.lock_outline, color: KivoraColors.textMuted),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: KivoraColors.textMuted),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                onChanged: (_) {
                  if (_passwordError != null) setState(() => _passwordError = null);
                },
              ),
              const SizedBox(height: 32),

              KivoraButton(
                text: 'Create Account',
                isLoading: _isLoading,
                icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                onPressed: _isLoading ? null : _handleRegister,
              ),

              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? ', style: TextStyle(color: KivoraColors.textSecondary)),
                  GestureDetector(
                    onTap: () => context.go('/auth/sign-in'),
                    child: const Text('Sign In', style: TextStyle(color: KivoraColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
