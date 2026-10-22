import 'package:flutter/material.dart';
import '../theme/kivora_theme.dart';

/// Primary / Outline action button with pill shape matching design references
class KivoraButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutline;
  final Widget? icon;

  const KivoraButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutline = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutline) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: KivoraColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[icon!, const SizedBox(width: 8)],
                  Text(
                    text,
                    style: const TextStyle(
                      color: KivoraColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(text),
                if (icon != null) ...[const SizedBox(width: 8), icon!],
              ],
            ),
    );
  }
}

/// Status Chip for Present, Late, Absent, Pending, Reviewed
class KivoraStatusChip extends StatelessWidget {
  final String status;

  const KivoraStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (status.toLowerCase()) {
      case 'present':
      case 'passed':
      case 'active':
      case 'approved':
        bg = KivoraColors.successSurface;
        fg = KivoraColors.success;
        break;
      case 'late':
      case 'needs_review':
      case 'pending':
      case 'half_day':
        bg = KivoraColors.warningSurface;
        fg = KivoraColors.warning;
        break;
      case 'absent':
      case 'failed':
      case 'rejected':
      case 'suspended':
        bg = KivoraColors.errorSurface;
        fg = KivoraColors.error;
        break;
      default:
        bg = KivoraColors.surfaceMuted;
        fg = KivoraColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Verification factor checklist item (M10, M11, M13)
class KivoraVerificationItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String status; // 'ready', 'verifying', 'passed', 'failed'

  const KivoraVerificationItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.status = 'ready',
  });

  @override
  Widget build(BuildContext context) {
    Widget trailing;
    if (status == 'verifying') {
      trailing = const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2, color: KivoraColors.primary),
      );
    } else if (status == 'passed') {
      trailing = const Icon(Icons.check_circle, color: KivoraColors.success, size: 22);
    } else if (status == 'failed') {
      trailing = const Icon(Icons.cancel, color: KivoraColors.error, size: 22);
    } else {
      trailing = const Icon(Icons.check_circle_outline, color: KivoraColors.textMuted, size: 22);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KivoraColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: KivoraColors.primarySubtle,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: KivoraColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: KivoraColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: KivoraColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
