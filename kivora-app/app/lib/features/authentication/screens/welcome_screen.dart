import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/kivora_service.dart';
import '../../../core/theme/kivora_theme.dart';
import '../../../core/widgets/kivora_components.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 12),
              // Brand & Logo Area
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: KivoraColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'K',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Kivora',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: KivoraColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Every presence counts.',
                    style: TextStyle(
                      fontSize: 16,
                      color: KivoraColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // App Mode Indicator Chip
                  ListenableBuilder(
                    listenable: AuthService(),
                    builder: (context, _) {
                      final isDemo = AuthService().isDemoMode;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDemo ? const Color(0xFFFEF3C7) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDemo ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
                          ),
                        ),
                        child: Text(
                          isDemo ? 'MODE: DEMO (Isolated Sample Data)' : 'MODE: LIVE (Production Database)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDemo ? const Color(0xFFB45309) : const Color(0xFF475569),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              // Visual Decorative Center
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: KivoraColors.primaryLight.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: const BoxDecoration(
                      color: KivoraColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.fingerprint,
                      size: 72,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Action Buttons
              Column(
                children: [
                  KivoraButton(
                    text: 'Get Started',
                    icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                    onPressed: () => context.go('/auth/register'),
                  ),
                  const SizedBox(height: 12),
                  KivoraButton(
                    text: 'Sign In',
                    isOutline: true,
                    onPressed: () => context.go('/auth/sign-in'),
                  ),
                  const SizedBox(height: 14),

                  // Explicit Demo Mode Selector
                  ListenableBuilder(
                    listenable: AuthService(),
                    builder: (context, _) {
                      final isDemo = AuthService().isDemoMode;
                      if (isDemo) {
                        return TextButton.icon(
                          onPressed: () {
                            AuthService().switchToLiveMode();
                            KivoraService().initializeLiveMode();
                          },
                          icon: const Icon(Icons.cloud_outlined, size: 16, color: Color(0xFF0D9488)),
                          label: const Text(
                            'Switch to Live Database Mode',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF0D9488)),
                          ),
                        );
                      }
                      return TextButton.icon(
                        onPressed: () {
                          AuthService().switchToDemoMode();
                          KivoraService().initializeDemoMode();
                          context.go('/branch/gateway');
                        },
                        icon: const Icon(Icons.science_outlined, size: 16, color: Color(0xFF64748B)),
                        label: const Text(
                          'Explore in Demo Mode (Mock Data)',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                        ),
                      );
                    },
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
