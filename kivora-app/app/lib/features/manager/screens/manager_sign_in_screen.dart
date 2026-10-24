import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/kivora_service.dart';

class ManagerSignInScreen extends StatefulWidget {
  const ManagerSignInScreen({super.key});

  @override
  State<ManagerSignInScreen> createState() => _ManagerSignInScreenState();
}

class _ManagerSignInScreenState extends State<ManagerSignInScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  String? _emailError;
  String? _passError;
  bool _rememberMe = true;
  bool _isLoading = false;

  void _handleSignIn() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    setState(() {
      _emailError = null;
      _passError = null;
    });

    bool hasError = false;
    if (email.isEmpty) {
      _emailError = 'Please enter your email address';
      hasError = true;
    } else if (!email.contains('@') || !email.contains('.')) {
      _emailError = 'Please enter a valid email address';
      hasError = true;
    }

    if (pass.isEmpty) {
      _passError = 'Please enter your password';
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    setState(() => _isLoading = true);

    if (AuthService().isLiveBackendConfigured) {
      final res = await AuthService().signInWithPassword(email: email, password: pass);
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (!res.isSuccess) {
        setState(() {
          _passError = res.errorMessage ?? 'Invalid manager credentials.';
        });
        return;
      }

      // Look up the manager's actual branch; do not default to a demo branch
      final managerBranch = KivoraService().branches
          .cast<BranchModel?>()
          .firstWhere((b) => b?.managerId == email, orElse: () => null);

      KivoraService().setCurrentUser(
        email: email,
        name: 'Branch Manager',
        role: 'manager',
        branchId: managerBranch?.id,
      );
      context.go('/manager/dashboard');
      return;
    }

    // Demo Mode execution
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _isLoading = false);
        // Look up the manager's actual branch; do not default to a demo branch
        final managerBranch = KivoraService().branches
            .cast<BranchModel?>()
            .firstWhere((b) => b?.managerId == email, orElse: () => null);
        KivoraService().setCurrentUser(
          email: email,
          name: 'Branch Manager',
          role: 'manager',
          branchId: managerBranch?.id,
        );
        context.go('/manager/dashboard');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => context.go('/welcome'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text(
                          'K',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Kivora',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Manage. Track. Grow.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF0D9488), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              const Text(
                'Branch Manager Sign In',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 6),
              const Text(
                'Access your branch dashboard and manage your organization.',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),

              const SizedBox(height: 28),

              // Email
              const Text('Email address', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
              const SizedBox(height: 6),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) {
                  if (_emailError != null) setState(() => _emailError = null);
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email_outlined, size: 18, color: Color(0xFF94A3B8)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  errorText: _emailError,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                ),
              ),

              const SizedBox(height: 16),

              // Password
              const Text('Password', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
              const SizedBox(height: 6),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                onChanged: (_) {
                  if (_passError != null) setState(() => _passError = null);
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline, size: 18, color: Color(0xFF94A3B8)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  errorText: _passError,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                ),
              ),

              const SizedBox(height: 14),

              // Remember Me & Forgot Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        activeColor: const Color(0xFF0D9488),
                        onChanged: (val) => setState(() => _rememberMe = val ?? true),
                      ),
                      const Text('Remember me', style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Reset Manager Password'),
                          content: const Text('A manager password recovery link will be sent to your administrative email address.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Manager password reset instructions sent.'),
                                    backgroundColor: Color(0xFF0D9488),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488)),
                              child: const Text('Send Reset Link', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Forgot password?', style: TextStyle(fontSize: 12, color: Color(0xFF0D9488))),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Sign In Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Sign In', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),

              const SizedBox(height: 24),

              // Create branch footer
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ", style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                    GestureDetector(
                      onTap: () => context.push('/manager/branch-gateway'),
                      child: const Text(
                        'Create Branch',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
