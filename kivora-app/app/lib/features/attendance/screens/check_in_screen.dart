import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/kivora_theme.dart';
import '../../../core/widgets/kivora_components.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  bool _isVerifying = false;
  String _gpsStatus = 'ready';
  String _wifiStatus = 'ready';
  String _bioStatus = 'ready';

  void _startVerification() async {
    setState(() {
      _isVerifying = true;
      _gpsStatus = 'verifying';
      _wifiStatus = 'verifying';
      _bioStatus = 'verifying';
    });

    // Step 1: GPS check completes
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _gpsStatus = 'passed');

    // Step 2: Wi-Fi check completes
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _wifiStatus = 'passed');

    // Step 3: Biometric prompt completes
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _bioStatus = 'passed');

    // Transition to Success Result
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    context.go('/member/attendance/result', extra: {'isSuccess': true, 'status': 'PASSED'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check In'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/member/home'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Big Fingerprint Target
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: KivoraColors.primarySubtle,
                  shape: BoxShape.circle,
                  border: Border.all(color: KivoraColors.primaryLight, width: 3),
                ),
                child: const Center(
                  child: Icon(
                    Icons.fingerprint,
                    size: 80,
                    color: KivoraColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Ready for verification',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: KivoraColors.textPrimary),
              ),
              const SizedBox(height: 6),
              const Text(
                'Use your fingerprint to check in for today\'s session.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: KivoraColors.textSecondary),
              ),
              const SizedBox(height: 32),

              // Verification Factor Items
              KivoraVerificationItem(
                title: 'Location (GPS)',
                subtitle: _gpsStatus == 'passed' ? 'Inside branch boundary' : 'Verifying your location...',
                icon: Icons.location_on_outlined,
                status: _gpsStatus,
              ),
              KivoraVerificationItem(
                title: 'Wi-Fi Network',
                subtitle: _wifiStatus == 'passed' ? 'Connected to campus Wi-Fi' : 'Checking network connection...',
                icon: Icons.wifi,
                status: _wifiStatus,
              ),
              KivoraVerificationItem(
                title: 'Biometric',
                subtitle: _bioStatus == 'passed' ? 'Fingerprint verified' : 'Tap to scan fingerprint',
                icon: Icons.fingerprint,
                status: _bioStatus,
              ),

              const Spacer(),
              KivoraButton(
                text: _isVerifying ? 'Verifying...' : 'Start Verification',
                isLoading: _isVerifying,
                onPressed: _isVerifying ? null : _startVerification,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
