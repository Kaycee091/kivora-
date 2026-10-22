import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
              const SizedBox(height: 20),
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
                ],
              ),

              // Visual Decorative Center
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: KivoraColors.primaryLight.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: const BoxDecoration(
                      color: KivoraColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.fingerprint,
                      size: 80,
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
