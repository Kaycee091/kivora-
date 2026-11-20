import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/kivora_service.dart';
import '../../../core/theme/kivora_theme.dart';
import '../../../core/widgets/kivora_components.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    bool isValid = true;
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      setState(() => _emailError = 'Please enter your email or student ID');
      isValid = false;
    } else if (email.contains('@') && !email.contains('.')) {
      setState(() => _emailError = 'Please enter a valid email address.');
      isValid = false;
    }

    if (password.isEmpty) {
      setState(() => _passwordError = 'Please enter your password');
      isValid = false;
    } else if (password.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters.');
      isValid = false;
    }

    return isValid;
  }

  void _handleSignIn() async {
    if (!_validateInputs()) return;

    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;
    setState(() => _isLoading = true);

    if (AuthService().isLiveMode) {
      if (!AuthService().isLiveBackendConfigured) {
        setState(() {
          _isLoading = false;
          _passwordError = AuthService().liveInitError ??
              'Cannot sign in: Live Supabase backend is not configured. Please switch to Demo Mode to test without credentials.';
        });
        return;
      }

      final res = await AuthService().signInWithPassword(email: email, password: password);
      if (!mounted) return;

      if (!res.isSuccess) {
        setState(() {
          _isLoading = false;
          _passwordError = res.errorMessage ?? 'Invalid email or password.';
        });
        return;
      }

      // Resolve live user state directly from database tables
      try {
        await KivoraService().resolveLiveUserState();
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _passwordError = 'Unable to load branch assignments: $e';
        });
        return;
      }

      if (!mounted) return;
      setState(() => _isLoading = false);

      final service = KivoraService();
      if (service.isManagerOrAdmin) {
        context.go('/manager/dashboard');
      } else if (service.membershipStatus == 'approved' && service.currentBranchId != null) {
        context.go('/member/home');
      } else if (service.membershipStatus == 'pending' || service.membershipStatus == 'rejected') {
        context.go('/branch/status');
      } else {
        context.go('/branch/gateway');
      }
      return;
    }

    // Demo Mode execution
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _isLoading = false);

      final isManager = email.contains('manager') || email.contains('admin');
      final isPending = email.contains('pending') ||
          KivoraService().applications.any((a) => a.userEmail.toLowerCase() == email && a.status == 'pending');
      final hasNoBranch = email.contains('new');

      // Check if this demo user maps to an existing demo member profile
      final demoMember = KivoraService().members.cast<MemberProfileModel?>().firstWhere(
        (m) => m?.email.toLowerCase() == email,
        orElse: () => null,
      );
      final memberBranchId = demoMember?.branchId ??
          KivoraService().branches.firstWhere((b) => b.id == 'branch-west', orElse: () => KivoraService().branches.first).id;

      if (isManager) {
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
      } else if (isPending) {
        KivoraService().setCurrentUser(email: email, name: 'Applicant', role: 'guest', branchId: memberBranchId);
        context.go('/branch/status');
      } else if (hasNoBranch) {
        KivoraService().setCurrentUser(email: email, name: 'New User', role: 'guest');
        context.go('/branch/gateway');
      } else {
        // Returning active member in demo
        final memberName = demoMember?.name ?? 'Alex Johnson';
        KivoraService().setCurrentUser(email: email, name: memberName, role: 'member', branchId: memberBranchId);
        context.go('/member/home');
      }
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
              // Logo Header
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: KivoraColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text('K', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text('Kivora', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Sign In', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: KivoraColors.textPrimary)),
              const SizedBox(height: 6),
              const Text('Welcome back! Please sign in to your account.', style: TextStyle(color: KivoraColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 32),

              // Form Inputs
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email or Student ID *',
                  hintText: 'name@domain.com',
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
                  hintText: 'Enter password',
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
              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Reset Password'),
                        content: const Text('A password reset link will be sent to your registered email address.'),
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
                                  content: Text('Password reset instructions sent to your email.'),
                                  backgroundColor: KivoraColors.primary,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: KivoraColors.primary),
                            child: const Text('Send Reset Link', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Forgot password?', style: TextStyle(color: KivoraColors.primary, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 24),

              KivoraButton(
                text: 'Sign In',
                isLoading: _isLoading,
                icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                onPressed: _isLoading ? null : _handleSignIn,
              ),

              const SizedBox(height: 16),
              Center(
                child: TextButton.icon(
                  onPressed: () => context.go('/branch/gateway'),
                  icon: const Icon(Icons.domain, size: 16, color: KivoraColors.primary),
                  label: const Text(
                    'Setup or Switch Branch',
                    style: TextStyle(color: KivoraColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ", style: TextStyle(color: KivoraColors.textSecondary)),
                  GestureDetector(
                    onTap: () => context.go('/auth/register'),
                    child: const Text('Create account', style: TextStyle(color: KivoraColors.primary, fontWeight: FontWeight.bold)),
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
