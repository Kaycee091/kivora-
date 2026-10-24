import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BiometricVerificationScreen extends StatefulWidget {
  const BiometricVerificationScreen({super.key});

  @override
  State<BiometricVerificationScreen> createState() => _BiometricVerificationScreenState();
}

class _BiometricVerificationScreenState extends State<BiometricVerificationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Simulate biometric check then navigate to verification result
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        setState(() => _isSuccess = true);
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) {
            context.go(
              '/member/attendance/result',
              extra: {'isSuccess': true, 'status': 'PASSED'},
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
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
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Biometric Verification',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Prominent Fingerprint graphic
              Center(
                child: AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF0D9488).withOpacity(0.08 + (_animController.value * 0.12)),
                        border: Border.all(
                          color: _isSuccess ? const Color(0xFF10B981) : const Color(0xFF0D9488),
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          _isSuccess ? Icons.check_circle : Icons.fingerprint,
                          size: 72,
                          color: _isSuccess ? const Color(0xFF10B981) : const Color(0xFF0F766E),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 36),
              Text(
                _isSuccess ? 'Fingerprint Recognized!' : 'Place your finger on the sensor',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Make sure your finger is clean and\nproperly placed on the scanner.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              // Linear Progress Indicator
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 180,
                  height: 6,
                  child: LinearProgressIndicator(
                    backgroundColor: const Color(0xFFE2E8F0),
                    color: _isSuccess ? const Color(0xFF10B981) : const Color(0xFF0D9488),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
