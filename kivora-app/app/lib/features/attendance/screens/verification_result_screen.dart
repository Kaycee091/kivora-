import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/kivora_theme.dart';
import '../../../core/widgets/kivora_components.dart';

class VerificationResultScreen extends StatelessWidget {
  final bool isSuccess;
  final String status;

  const VerificationResultScreen({
    super.key,
    required this.isSuccess,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isSuccess ? KivoraColors.success : KivoraColors.error;
    final surfaceColor = isSuccess ? KivoraColors.successSurface : KivoraColors.errorSurface;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              // Big Outcome Badge
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: surfaceColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSuccess ? Icons.check : Icons.close,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isSuccess ? 'Verification Successful!' : 'Verification Failed',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: KivoraColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isSuccess
                    ? 'Your attendance has been recorded for today\'s session.'
                    : 'We couldn\'t verify your attendance. Please try again or contact your branch administrator.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: KivoraColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 36),

              // Factor verification outcome pills
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: KivoraColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _FactorOutcome(
                      icon: Icons.location_on,
                      label: 'Location',
                      isSuccess: isSuccess,
                    ),
                    _FactorOutcome(
                      icon: Icons.wifi,
                      label: 'Wi-Fi',
                      isSuccess: isSuccess,
                    ),
                    _FactorOutcome(
                      icon: Icons.fingerprint,
                      label: 'Biometric',
                      isSuccess: isSuccess,
                    ),
                  ],
                ),
              ),

              const Spacer(),
              if (isSuccess) ...[
                KivoraButton(
                  text: 'View Details',
                  onPressed: () => context.push('/member/attendance/history'),
                ),
                const SizedBox(height: 12),
                KivoraButton(
                  text: 'Back to Dashboard',
                  isOutline: true,
                  onPressed: () => context.go('/member/home'),
                ),
              ] else ...[
                KivoraButton(
                  text: 'Try Again',
                  onPressed: () => context.go('/member/attendance/check-in'),
                ),
                const SizedBox(height: 12),
                KivoraButton(
                  text: 'Contact Support',
                  isOutline: true,
                  onPressed: () => context.push('/member/settings/help'),
                ),
              ],
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _FactorOutcome extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSuccess;

  const _FactorOutcome({
    required this.icon,
    required this.label,
    required this.isSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSuccess ? KivoraColors.success : KivoraColors.error;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSuccess ? KivoraColors.successSurface : KivoraColors.errorSurface,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: KivoraColors.textPrimary),
        ),
        Text(
          isSuccess ? 'Verified' : 'Failed',
          style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
