import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  bool _obscurePassword = true;
  bool _isLoading = false;

  void _handleSignIn() {
    setState(() => _isLoading = true);
    // Simulate auth / route transition to member home
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _isLoading = false);
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
                decoration: const InputDecoration(
                  labelText: 'Email or Student ID',
                  hintText: 'name@domain.com',
                  prefixIcon: Icon(Icons.email_outlined, color: KivoraColors.textMuted),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter password',
                  prefixIcon: const Icon(Icons.lock_outline, color: KivoraColors.textMuted),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: KivoraColors.textMuted),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Forgot password?', style: TextStyle(color: KivoraColors.primary, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 24),

              KivoraButton(
                text: 'Sign In',
                isLoading: _isLoading,
                icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                onPressed: _handleSignIn,
              ),

              const SizedBox(height: 32),
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
