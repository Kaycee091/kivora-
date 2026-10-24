import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GpsVerificationScreen extends StatefulWidget {
  const GpsVerificationScreen({super.key});

  @override
  State<GpsVerificationScreen> createState() => _GpsVerificationScreenState();
}

class _GpsVerificationScreenState extends State<GpsVerificationScreen> {
  int _step = 0; // 0: GPS checking, 1: Wi-Fi checking, 2: Biometric check

  @override
  void initState() {
    super.initState();
    _startSequence();
  }

  void _startSequence() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) setState(() => _step = 1);
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) setState(() => _step = 2);
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            context.push('/member/attendance/biometric');
          }
        });
      });
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
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Verification in Progress',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Location Check Card
              _buildCheckItem(
                icon: Icons.location_on,
                title: 'Location (GPS)',
                subtitle: _step > 0 ? 'Location verified (Within West Campus)' : 'Checking coordinates against geofence...',
                isDone: _step > 0,
                isInProgress: _step == 0,
              ),
              const SizedBox(height: 16),
              // Wi-Fi Network Check Card
              _buildCheckItem(
                icon: Icons.wifi,
                title: 'Wi-Fi Network',
                subtitle: _step > 1 ? 'Connected to campus Wi-Fi' : 'Checking network connection...',
                isDone: _step > 1,
                isInProgress: _step == 1,
              ),
              const SizedBox(height: 16),
              // Biometric Check Card
              _buildCheckItem(
                icon: Icons.fingerprint,
                title: 'Biometric',
                subtitle: _step == 2 ? 'Initiating biometric scanner...' : 'Waiting for fingerprint...',
                isDone: false,
                isInProgress: _step == 2,
              ),

              const Spacer(),

              // Bottom reassurance banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFCCFBF1)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0D9488),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Please wait...',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
                          ),
                          Text(
                            'We are verifying your details to ensure a secure check-in.',
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDone,
    required bool isInProgress,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone ? const Color(0xFFCCFBF1) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDone
                  ? const Color(0xFFE0F2F1)
                  : isInProgress
                      ? const Color(0xFFE0F2FE)
                      : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isDone
                  ? const Color(0xFF0D9488)
                  : isInProgress
                      ? const Color(0xFF0284C7)
                      : const Color(0xFF94A3B8),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          if (isDone)
            const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 24)
          else if (isInProgress)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(color: Color(0xFF0D9488), strokeWidth: 2),
            )
          else
            const Icon(Icons.radio_button_unchecked, color: Color(0xFFCBD5E1), size: 22),
        ],
      ),
    );
  }
}
